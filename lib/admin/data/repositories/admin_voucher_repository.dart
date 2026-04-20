import '../datasources/admin_voucher_remote.dart';
import '../models/admin_voucher_model.dart';

class AdminVoucherRepository {
  final AdminVoucherRemote remote;

  AdminVoucherRepository(this.remote);

  Future<List<AdminVoucherModel>> fetchVouchers() {
    return remote.fetchVouchers();
  }

  Future<void> updateVoucherStatus({
    required String voucherId,
    required bool isActive,
  }) {
    return remote.updateVoucherStatus(
      voucherId: voucherId,
      isActive: isActive,
    );
  }

  Future<void> saveVoucher({
    String? voucherId,
    required Map<String, dynamic> payload,
  }) {
    return remote.saveVoucher(
      voucherId: voucherId,
      payload: payload,
    );
  }

  Future<void> deleteVoucher(String voucherId) {
    return remote.deleteVoucher(voucherId);
  }
}