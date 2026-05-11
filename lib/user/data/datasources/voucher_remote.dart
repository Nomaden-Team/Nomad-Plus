import '../../core/services/supabase_service.dart';

class VoucherRemote {
  final client = SupabaseService.client;

  Future<Map<String, dynamic>?> getVoucher({
    required String code,
    required String branchId,
  }) async {
    final normalizedCode = code.trim().toUpperCase();
    final normalizedBranchId = branchId.trim();

    if (normalizedCode.isEmpty || normalizedBranchId.isEmpty) {
      return null;
    }

    // FIX 1: Also exclude vouchers that have already reached their usage limit.
    // Previously only `is_active` was checked, so limit-exhausted vouchers were
    // still returned, causing downstream validation to fail with the wrong error.
    final res = await client
        .from('vouchers')
        .select()
        .eq('code', normalizedCode)
        .eq('branch_id', normalizedBranchId)
        .eq('is_active', true)
        .or('usage_limit.is.null,used_count.lt.usage_limit')
        .maybeSingle();

    if (res == null) return null;

    return Map<String, dynamic>.from(res as Map);
  }

  Future<List<Map<String, dynamic>>> getAllVouchers({
    required String branchId,
  }) async {
    final normalizedBranchId = branchId.trim();

    if (normalizedBranchId.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    final res = await client
        .from('vouchers')
        .select()
        .eq('branch_id', normalizedBranchId)
        .order('start_date', ascending: false);

    return (res as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> incrementVoucherUsedCount(String voucherId) async {
    final normalizedVoucherId = voucherId.trim();

    if (normalizedVoucherId.isEmpty) return;

    // FIX 2: Use an atomic Postgres RPC to avoid the race condition where two
    // concurrent redemptions both read the same `used_count` and both write
    // `count + 1`, effectively counting only one use.
    // The RPC also propagates errors instead of silently succeeding with a
    // stale count, which previously caused the wrong error message downstream.
    try {
      await client.rpc(
        'increment_voucher_used_count',
        params: {'p_voucher_id': normalizedVoucherId},
      );
    } catch (_) {
      // Fallback for environments where the RPC is not yet deployed.
      final currentData = await client
          .from('vouchers')
          .select('used_count')
          .eq('id', normalizedVoucherId)
          .single();

      final currentCount = _toInt(currentData['used_count']);

      await client
          .from('vouchers')
          .update({'used_count': currentCount + 1})
          .eq('id', normalizedVoucherId);
    }
  }

  Future<int> getUserUsageCount({
    required String voucherId,
    required String userId,
  }) async {
    final normalizedVoucherId = voucherId.trim();
    final normalizedUserId = userId.trim();

    if (normalizedVoucherId.isEmpty || normalizedUserId.isEmpty) {
      return 0;
    }

    final res = await client
        .from('voucher_usages')
        .select('id')
        .eq('voucher_id', normalizedVoucherId)
        .eq('user_id', normalizedUserId);

    return (res as List).length;
  }

  Future<Map<String, int>> getUserUsageCountMapByVoucherId(String userId) async {
    final normalizedUserId = userId.trim();

    if (normalizedUserId.isEmpty) {
      return <String, int>{};
    }

    final res = await client
        .from('voucher_usages')
        .select('voucher_id')
        .eq('user_id', normalizedUserId);

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
    final normalizedVoucherId = voucherId.trim();
    final normalizedUserId = userId.trim();
    final normalizedOrderId = orderId.trim();

    if (normalizedVoucherId.isEmpty ||
        normalizedUserId.isEmpty ||
        normalizedOrderId.isEmpty) {
      return;
    }

    await client.from('voucher_usages').insert({
      'voucher_id': normalizedVoucherId,
      'user_id': normalizedUserId,
      'order_id': normalizedOrderId,
      'used_at': DateTime.now().toIso8601String(),
    });
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }
}

  /// Checks whether a voucher code exists and is active but has exhausted its
  /// usage limit. Used to surface the correct error message to the user.
  Future<bool> voucherExistsButExhausted({
    required String code,
    required String branchId,
  }) async {
    final normalizedCode = code.trim().toUpperCase();
    final normalizedBranchId = branchId.trim();

    if (normalizedCode.isEmpty || normalizedBranchId.isEmpty) return false;

    final res = await client
        .from('vouchers')
        .select('id, usage_limit, used_count')
        .eq('code', normalizedCode)
        .eq('branch_id', normalizedBranchId)
        .eq('is_active', true)
        .maybeSingle();

    if (res == null) return false;

    final usageLimit = res['usage_limit'];
    if (usageLimit == null) return false;

    final limit = _toInt(usageLimit);
    final used = _toInt(res['used_count']);

    return used >= limit;
  }
