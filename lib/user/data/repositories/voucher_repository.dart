// lib/data/repositories/voucher_repository.dart

import '../datasources/voucher_remote.dart';
import '../models/voucher_model.dart';

class VoucherRepository {
  final VoucherRemote remote;

  VoucherRepository(this.remote);

  Future<Map<String, dynamic>?> validateVoucher(String code) {
    return remote.getVoucher(code);
  }

  Future<List<VoucherModel>> fetchAllVouchers() async {
    final res = await remote.getAllVouchers();
    final result = <VoucherModel>[];

    for (final e in res) {
      try {
        result.add(VoucherModel.fromMap(Map<String, dynamic>.from(e)));
      } catch (_) {}
    }
    return result;
  }

  // FUNGSI BARU: Menjalankan dua aksi sekaligus (Catat riwayat & Tambah hitungan)
  Future<void> markVoucherAsUsed({
    required String voucherId,
    required String userId,
    required String orderId,
  }) async {
    // 1. Tambah record di voucher_usages
    await remote.createVoucherUsage(
      voucherId: voucherId,
      userId: userId,
      orderId: orderId,
    );
    // 2. Increment used_count di tabel vouchers
    await remote.incrementVoucherUsedCount(voucherId);
  }

  Future<int> getUserUsageCount({
    required String voucherId,
    required String userId,
  }) {
    return remote.getUserUsageCount(voucherId: voucherId, userId: userId);
  }

  Future<Map<String, int>> getUserUsageCountMapByVoucherId(String userId) {
    return remote.getUserUsageCountMapByVoucherId(userId);
  }
}