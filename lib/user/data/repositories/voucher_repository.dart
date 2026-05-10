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

    try {
      await remote.incrementVoucherUsedCount(voucherId);
    } catch (_) {
    }
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
}