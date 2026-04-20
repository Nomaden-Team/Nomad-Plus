import 'package:supabase_flutter/supabase_flutter.dart';

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

    return List<Map<String, dynamic>>.from(response)
        .map(AdminOrderModel.fromMap)
        .toList();
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    final branchId = await AdminBranchScope.requireBranchId();

    await _supabase
        .from('orders')
        .update({
          'status': newStatus,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', orderId)
        .eq('branch_id', branchId);
  }
}
