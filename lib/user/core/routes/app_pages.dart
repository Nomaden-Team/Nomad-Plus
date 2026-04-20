import 'package:get/get.dart';

import '../../controllers/auth/login_controller.dart';
import '../../controllers/auth/register_controller.dart';
import '../../controllers/cart/cart_controller.dart';
import '../../controllers/home/home_controller.dart';
import '../../controllers/home/main_controller.dart';
import '../../controllers/loyalty/loyalty_controller.dart';
import '../../controllers/menu/menu_controller.dart';
import '../../controllers/profile/profile_controller.dart';
import '../../controllers/splash/splash_controller.dart';
import '../../controllers/voucher/voucher_controller.dart';

import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/cart/cart_screen.dart';
import '../../presentation/screens/home/main_screen.dart';
import '../../presentation/screens/loyalty/loyalty_screen.dart';
import '../../presentation/screens/order/order_history_screen.dart';
import '../../presentation/screens/order/order_status_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/voucher/voucher_screen.dart';

import '../../../admin/core/routes/admin_pages.dart';
import 'app_routes.dart';

class AppPages {
  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    ...AdminPages.routes,

    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<SplashController>()) {
          Get.put(SplashController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<LoginController>()) {
          Get.put(LoginController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<RegisterController>()) {
          Get.put(RegisterController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const MainScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CartController>()) {
          Get.put(CartController());
        }
        if (!Get.isRegistered<MainController>()) {
          Get.put(MainController());
        }
        if (!Get.isRegistered<MenuController>()) {
          Get.put(MenuController());
        }
        if (!Get.isRegistered<HomeController>()) {
          Get.put(HomeController());
        }
      }),
    ),
    GetPage(name: AppRoutes.cart, page: () => const CartScreen()),
    GetPage(name: AppRoutes.orderStatus, page: () => const OrderStatusScreen()),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ProfileController>()) {
          Get.put(ProfileController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.loyalty,
      page: () => const LoyaltyScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<LoyaltyController>()) {
          Get.put(LoyaltyController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.voucher,
      page: () => const VoucherScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<VoucherController>()) {
          Get.put(VoucherController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.orderHistory,
      page: () => const OrderHistoryScreen(),
    ),
  ];
}
