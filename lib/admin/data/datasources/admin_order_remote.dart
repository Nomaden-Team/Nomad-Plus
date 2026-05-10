import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../user/data/models/user_model.dart';
import '../../core/utils/admin_branch_scope.dart';
import '../models/admin_order_model.dart';

class AdminOrderRemote {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<AdminOrderModel>> fetchOrdersByStatus(String status) async {
    final branchId = await AdminBranchScope.requireBranchId();

    final response = await _supabase
        .from('orders')
        .select('''
            id,
            queue_number,
            status,
            subtotal,
            discount_amount,
            service_fee,
            grand_total,
            points_earned,
            points_used,
            voucher_code,
            order_type,
            notes,
            created_at,
            updated_at,
            users(name, email),
            branches(name),
            order_items(
              id,
              quantity,
              notes,
              price,
              menu_items(id, name, image_url)
            )
          ''')
        .eq('branch_id', branchId)
        .eq('status', status)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(
      response,
    ).map(AdminOrderModel.fromMap).toList();
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    final branchId = await AdminBranchScope.requireBranchId();
    final targetStatus = _normalizeStatus(newStatus);

    final orderData = await _supabase
        .from('orders')
        .select('id, user_id, branch_id, status, points_earned, points_used')
        .eq('id', orderId)
        .eq('branch_id', branchId)
        .single();

    final oldStatus = _normalizeStatus(orderData['status']);

    Get.log(
      '[ADMIN ORDER] updateOrderStatus orderId=$orderId '
      'oldStatus=$oldStatus targetStatus=$targetStatus '
      'pointsEarned=${orderData['points_earned']} '
      'pointsUsed=${orderData['points_used']}',
    );

    if (oldStatus == targetStatus) {
      Get.log('[ADMIN ORDER] Status sama, update dibatalkan.');
      return;
    }

    final isPaymentAccepted =
        oldStatus == 'menunggu' && targetStatus == 'diproses';

    if (isPaymentAccepted) {
      await _applyLoyaltyAfterPaymentAccepted(orderData);
    }

    await _supabase
        .from('orders')
        .update({
          'status': targetStatus,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', orderId)
        .eq('branch_id', branchId);

    Get.log('[ADMIN ORDER] Status order berhasil diubah ke $targetStatus.');
  }

  Future<void> _applyLoyaltyAfterPaymentAccepted(
    Map<String, dynamic> orderData,
  ) async {
    final userId = (orderData['user_id'] ?? '').toString();

    if (userId.trim().isEmpty) {
      throw StateError('[LOYALTY] user_id kosong pada order.');
    }

    final pointsEarned = _toInt(orderData['points_earned']);
    final pointsUsed = _toInt(orderData['points_used']);

    Get.log(
      '[LOYALTY] Start apply loyalty userId=$userId '
      'pointsEarned=$pointsEarned pointsUsed=$pointsUsed',
    );

    if (pointsEarned <= 0 && pointsUsed <= 0) {
      Get.log('[LOYALTY] Tidak ada poin yang perlu diproses.');
      return;
    }

    final userData = await _supabase
        .from('users')
        .select('id, loyalty_points, total_earned_points, membership_tier')
        .eq('id', userId)
        .single();

    final currentPoints = _toInt(userData['loyalty_points']);
    final currentTotalEarned = _toInt(userData['total_earned_points']);

    final usedToApply = pointsUsed > 0 ? pointsUsed : 0;

    // Kalau user memakai poin, user tidak mendapat reward poin.
    final earnedToApply = pointsUsed <= 0 && pointsEarned > 0
        ? pointsEarned
        : 0;

    final newPoints = (currentPoints - usedToApply + earnedToApply)
        .clamp(0, 1 << 31)
        .toInt();

    final newTotalEarned = currentTotalEarned + earnedToApply;
    final newTier = UserModel.getTier(newTotalEarned);

    Get.log(
      '[LOYALTY] currentPoints=$currentPoints '
      'usedToApply=$usedToApply '
      'earnedToApply=$earnedToApply '
      'newPoints=$newPoints '
      'currentTotalEarned=$currentTotalEarned '
      'newTotalEarned=$newTotalEarned '
      'newTier=$newTier',
    );

    final updatedUser = await _supabase
        .from('users')
        .update({
          'loyalty_points': newPoints,
          'total_earned_points': newTotalEarned,
          'membership_tier': newTier,
        })
        .eq('id', userId)
        .select('id, loyalty_points, total_earned_points, membership_tier')
        .maybeSingle();

    if (updatedUser == null) {
      throw StateError(
        '[LOYALTY] Update user gagal. Tidak ada row users yang berhasil diupdate.',
      );
    }

    final savedPoints = _toInt(updatedUser['loyalty_points']);
    final savedTotalEarned = _toInt(updatedUser['total_earned_points']);

    Get.log(
      '[LOYALTY] savedPoints=$savedPoints '
      'savedTotalEarned=$savedTotalEarned',
    );

    if (savedPoints != newPoints || savedTotalEarned != newTotalEarned) {
      throw StateError(
        '[LOYALTY] Update poin tidak sesuai. '
        'Expected points=$newPoints total=$newTotalEarned, '
        'saved points=$savedPoints total=$savedTotalEarned.',
      );
    }

    Get.log('[LOYALTY] Poin user berhasil diperbarui.');
  }

  String _normalizeStatus(dynamic value) {
    final raw = (value ?? '').toString().toLowerCase().trim();

    switch (raw) {
      case 'pending':
      case 'menunggu':
        return 'menunggu';
      case 'confirmed':
      case 'diproses':
        return 'diproses';
      case 'ready':
      case 'siap':
        return 'siap';
      case 'done':
      case 'selesai':
        return 'selesai';
      case 'cancelled':
      case 'dibatalkan':
        return 'dibatalkan';
      default:
        return raw.isEmpty ? 'menunggu' : raw;
    }
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }
}
