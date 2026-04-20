import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/cart/cart_controller.dart';
import '../../../controllers/home/main_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../loyalty/loyalty_screen.dart';
import '../menu/menu_screen.dart';
import '../order/order_history_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController mainCtrl = Get.isRegistered<MainController>()
        ? Get.find<MainController>()
        : Get.put(MainController(), permanent: true);

    final screens = const [
      HomeScreen(),
      MenuScreen(),
      LoyaltyScreen(),
      OrderHistoryScreen(),
      ProfileScreen(),
    ];

    const tabs = [
      ('Home', Icons.home_outlined, Icons.home_rounded),
      ('Menu', Icons.local_cafe_outlined, Icons.local_cafe_rounded),
      (
        'Rewards',
        Icons.confirmation_number_outlined,
        Icons.confirmation_number,
      ),
      ('Orders', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
      ('Profile', Icons.person_outline_rounded, Icons.person_rounded),
    ];

    return GetBuilder<MainController>(
      init: mainCtrl,
      builder: (mainCtrl) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: screens[mainCtrl.tabIndex],
          floatingActionButton: GetBuilder<CartController>(
            builder: (cart) {
              final shouldShow =
                  (mainCtrl.tabIndex == 0 || mainCtrl.tabIndex == 1) &&
                  cart.cartItems.isNotEmpty;

              if (!shouldShow) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _FloatingCartBadge(
                  itemCount: cart.totalQty,
                  totalLabel: Formatters.currency(cart.subtotal),
                  onTap: () => Get.toNamed(AppRoutes.cart),
                ),
              );
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          bottomNavigationBar: _buildBottomNav(mainCtrl, tabs),
        );
      },
    );
  }

  Widget _buildBottomNav(
    MainController ctrl,
    List<(String, IconData, IconData)> tabs,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final active = ctrl.tabIndex == i;
              final (label, iconOff, iconOn) = tabs[i];

              return Expanded(
                child: GestureDetector(
                  onTap: () => ctrl.changeTab(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? iconOn : iconOff,
                        size: 22,
                        color: active
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _FloatingCartBadge extends StatelessWidget {
  final int itemCount;
  final String totalLabel;
  final VoidCallback onTap;

  const _FloatingCartBadge({
    required this.itemCount,
    required this.totalLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          constraints: const BoxConstraints(minWidth: 200),
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryDark.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // ICON
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.shopping_bag_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              // TEXT
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lihat Keranjang',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$itemCount item • $totalLabel',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Text(
                'Buka',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(width: 6),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
