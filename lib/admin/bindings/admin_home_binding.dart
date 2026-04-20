import 'package:get/get.dart';

import '../controllers/admin_home_controller.dart';
import '../data/datasources/admin_home_remote.dart';
import '../data/repositories/admin_home_repository.dart';

class AdminHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminHomeRemote>(() => AdminHomeRemote());
    Get.lazyPut<AdminHomeRepository>(
      () => AdminHomeRepository(Get.find<AdminHomeRemote>()),
    );
    Get.lazyPut<AdminHomeController>(
      () => AdminHomeController(Get.find<AdminHomeRepository>()),
    );
  }
}