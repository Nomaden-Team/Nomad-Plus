import '../datasources/voucher_remote.dart';
import '../models/voucher_model.dart';

class VoucherRepository {
  final VoucherRemote remote;

  VoucherRepository(this.remote);

  Future<Map<String, dynamic>?> validateVoucher(
    String code, {
    required String branchId,
  }) {
    return remote.getVoucher(
      code: code,
      branchId: branchId,
    );
  }

  Future<List<VoucherModel>> fetchAllVouchers({
    required String branchId,
  }) async {
    final res = await remote.getAllVouchers(branchId: branchId);
    final result = <VoucherModel>[];

    for (final e in res) {
      try {
        result.add(VoucherModel.fromMap(Map<String, dynamic>.from(e)));
      } catch (_) {}
    }

    return result;
  }

  Future<void> markVoucherAsUsed({
    required String voucherId,
    required String userId,
    required String orderId,
  }) async {
    await remote.createVoucherUsage(
      voucherId: voucherId,
      userId: userId,
      orderId: orderId,
    );

    // FIX 3: No longer silently swallowing the increment error.
    // If incrementVoucherUsedCount fails, `used_count` stays stale in the DB,
    // which causes the next user's `validate()` to skip the limit check and
    // fall through to `minOrderValue`, producing the wrong error message.
    // Let the exception propagate so the caller (finalizeVoucherUsage) can log
    // and surface it, and the atomic RPC in voucher_remote handles the race.
    await remote.incrementVoucherUsedCount(voucherId);
  }

  Future<int> getUserUsageCount({
    required String voucherId,
    required String userId,
  }) {
    return remote.getUserUsageCount(
      voucherId: voucherId,
      userId: userId,
    );
  }

  Future<Map<String, int>> getUserUsageCountMapByVoucherId(String userId) {
    return remote.getUserUsageCountMapByVoucherId(userId);
  }

  /// Returns true if the voucher code exists and is active but has already
  /// reached its usage limit. Used to show the correct error message.
  Future<bool> voucherExistsButExhausted(
    String code, {
    required String branchId,
  }) {
    return remote.voucherExistsButExhausted(
      code: code,
      branchId: branchId,
    );
  }
}  // ← SATU kurung kurawal penutup class di sini
