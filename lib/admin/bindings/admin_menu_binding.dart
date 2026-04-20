import 'package:get/get.dart';

import '../controllers/admin_menu_controller.dart';
import '../data/datasources/admin_menu_remote.dart';
import '../data/repositories/admin_menu_repository.dart';

class AdminMenuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminMenuRemote>(() => AdminMenuRemote());
    Get.lazyPut<AdminMenuRepository>(
      () => AdminMenuRepository(Get.find<AdminMenuRemote>()),
    );
    Get.lazyPut<AdminMenuController>(
      () => AdminMenuController(Get.find<AdminMenuRepository>()),
    );
  }
}
