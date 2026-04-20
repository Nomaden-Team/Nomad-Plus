import 'package:get/get.dart';

import '../controllers/admin_voucher_controller.dart';
import '../data/datasources/admin_voucher_remote.dart';
import '../data/repositories/admin_voucher_repository.dart';

class AdminVoucherBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminVoucherRemote>(() => AdminVoucherRemote());
    Get.lazyPut<AdminVoucherRepository>(
      () => AdminVoucherRepository(Get.find<AdminVoucherRemote>()),
    );
    Get.lazyPut<AdminVoucherController>(
      () => AdminVoucherController(Get.find<AdminVoucherRepository>()),
    );
  }
}
