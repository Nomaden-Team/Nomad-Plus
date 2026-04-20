import 'package:get/get.dart';

import '../controllers/admin_branch_controller.dart';
import '../data/datasources/admin_branch_remote.dart';
import '../data/repositories/admin_branch_repository.dart';

class AdminBranchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminBranchRemote>(() => AdminBranchRemote());
    Get.lazyPut<AdminBranchRepository>(
      () => AdminBranchRepository(Get.find<AdminBranchRemote>()),
    );
    Get.lazyPut<AdminBranchController>(
      () => AdminBranchController(Get.find<AdminBranchRepository>()),
    );
  }
}
