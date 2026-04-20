import 'package:get/get.dart';

import '../../bindings/admin_branch_binding.dart';
import '../../bindings/admin_home_binding.dart';
import '../../bindings/admin_menu_binding.dart';
import '../../bindings/admin_order_binding.dart';
import '../../bindings/admin_voucher_binding.dart';
import '../../presentation/screens/admin_home_screen.dart';
import '../../presentation/screens/branch/admin_branch_form_screen.dart';
import '../../presentation/screens/branch/admin_branch_screen.dart';
import '../../presentation/screens/menu/admin_menu_form_screen.dart';
import '../../presentation/screens/menu/admin_menu_screen.dart';
import '../../presentation/screens/order/admin_order_detail_screen.dart';
import '../../presentation/screens/order/admin_order_screen.dart';
import '../../presentation/screens/voucher/admin_voucher_form_screen.dart';
import '../../presentation/screens/voucher/admin_voucher_screen.dart';
import 'admin_routes.dart';

class AdminPages {
  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    GetPage(
      name: AdminRoutes.home,
      page: () => const AdminHomeScreen(),
      binding: AdminHomeBinding(),
    ),
    GetPage(
      name: AdminRoutes.orders,
      page: () => const AdminOrderScreen(),
      binding: AdminOrderBinding(),
    ),
    GetPage(
      name: AdminRoutes.orderDetail,
      page: () => const AdminOrderDetailScreen(),
    ),
    GetPage(
      name: AdminRoutes.menus,
      page: () => const AdminMenuScreen(),
      binding: AdminMenuBinding(),
    ),
    GetPage(
      name: AdminRoutes.menuForm,
      page: () => const AdminMenuFormScreen(),
      binding: AdminMenuBinding(),
    ),
    GetPage(
      name: AdminRoutes.branches,
      page: () => const AdminBranchScreen(),
      binding: AdminBranchBinding(),
    ),
    GetPage(
      name: AdminRoutes.branchForm,
      page: () => const AdminBranchFormScreen(),
      binding: AdminBranchBinding(),
    ),
    GetPage(
      name: AdminRoutes.vouchers,
      page: () => const AdminVoucherScreen(),
      binding: AdminVoucherBinding(),
    ),
    GetPage(
      name: AdminRoutes.voucherForm,
      page: () => const AdminVoucherFormScreen(),
      binding: AdminVoucherBinding(),
    ),
  ];
}
