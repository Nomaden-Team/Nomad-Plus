// lib/data/datasources/voucher_remote.dart

import '../../core/services/supabase_service.dart';

class VoucherRemote {
  final client = SupabaseService.client;

  Future<Map<String, dynamic>?> getVoucher(String code) async {
    final normalized = code.trim().toUpperCase();

    final res = await client
        .from('vouchers')
        .select()
        .eq('code', normalized)
        .eq('is_active', true)
        .maybeSingle();

    return res;
  }

  Future<List<Map<String, dynamic>>> getAllVouchers() async {
    final res = await client
        .from('vouchers')
        .select()
        .order('start_date', ascending: false);

    return (res as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  // FUNGSI BARU: Update used_count di tabel vouchers
  Future<void> incrementVoucherUsedCount(String voucherId) async {
    // Mengambil nilai saat ini
    final currentData = await client
        .from('vouchers')
        .select('used_count')
        .eq('id', voucherId)
        .single();
    
    int currentCount = currentData['used_count'] ?? 0;

    // Update dengan nilai baru
    await client
        .from('vouchers')
        .update({'used_count': currentCount + 1})
        .eq('id', voucherId);
  }

  Future<int> getUserUsageCount({
    required String voucherId,
    required String userId,
  }) async {
    final res = await client
        .from('voucher_usages')
        .select('id')
        .eq('voucher_id', voucherId)
        .eq('user_id', userId);

    return (res as List).length;
  }

  Future<Map<String, int>> getUserUsageCountMapByVoucherId(String userId) async {
    final res = await client
        .from('voucher_usages')
        .select('voucher_id')
        .eq('user_id', userId);

    final map = <String, int>{};
    for (final row in (res as List)) {
      final voucherId = (row['voucher_id'] ?? '').toString();
      if (voucherId.isEmpty) continue;
      map[voucherId] = (map[voucherId] ?? 0) + 1;
    }
    return map;
  }

  Future<void> createVoucherUsage({
    required String voucherId,
    required String userId,
    required String orderId,
  }) async {
    await client.from('voucher_usages').insert({
      'voucher_id': voucherId,
      'user_id': userId,
      'order_id': orderId,
      'used_at': DateTime.now().toIso8601String(),
    });
  }
}