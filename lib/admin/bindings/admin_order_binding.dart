import 'package:get/get.dart';

import '../controllers/admin_order_controller.dart';
import '../data/datasources/admin_order_remote.dart';
import '../data/repositories/admin_order_repository.dart';

class AdminOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminOrderRemote>(() => AdminOrderRemote());
    Get.lazyPut<AdminOrderRepository>(
      () => AdminOrderRepository(Get.find<AdminOrderRemote>()),
    );
    Get.lazyPut<AdminOrderController>(
      () => AdminOrderController(Get.find<AdminOrderRepository>()),
    );
  }
}
