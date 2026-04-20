import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/admin_routes.dart';
import '../../../user/core/app_state.dart';
import '../../../user/core/routes/app_routes.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Get.find<AppStateController>();
    final currentRoute = Get.currentRoute;

    return Drawer(
      width: 290,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Container(
          color: const Color(0xFFF9F4F1),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nomad Admin',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFB31217),
                ),
              ),
              const SizedBox(height: 28),

              _DrawerMenuItem(
                icon: Icons.grid_view_rounded,
                title: 'Dashboard',
                selected: currentRoute == AdminRoutes.home,
                onTap: () => _goTo(AdminRoutes.home),
              ),
              const SizedBox(height: 8),

              _DrawerMenuItem(
                icon: Icons.receipt_long_outlined,
                title: 'Orders',
                selected:
                    currentRoute == AdminRoutes.orders ||
                    currentRoute == AdminRoutes.orderDetail,
                onTap: () => _goTo(AdminRoutes.orders),
              ),
              const SizedBox(height: 8),

              _DrawerMenuItem(
                icon: Icons.restaurant_menu_rounded,
                title: 'Menus',
                selected:
                    currentRoute == AdminRoutes.menus ||
                    currentRoute == AdminRoutes.menuForm,
                onTap: () => _goTo(AdminRoutes.menus),
              ),
              const SizedBox(height: 8),

              _DrawerMenuItem(
                icon: Icons.storefront_outlined,
                title: 'Branches',
                selected:
                    currentRoute == AdminRoutes.branches ||
                    currentRoute == AdminRoutes.branchForm,
                onTap: () => _goTo(AdminRoutes.branches),
              ),
              const SizedBox(height: 8),

              _DrawerMenuItem(
                icon: Icons.confirmation_number_outlined,
                title: 'Vouchers',
                selected:
                    currentRoute == AdminRoutes.vouchers ||
                    currentRoute == AdminRoutes.voucherForm,
                onTap: () => _goTo(AdminRoutes.vouchers),
              ),

              const Spacer(),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE9DFDA)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBEAEC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFB31217),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        appState.isLoggedIn ? 'Logout' : 'Kembali ke login',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2A2A2A),
                        ),
                      ),
                    ),
                  ],
                ),
              ).inkWell(
                onTap: () {
                  Get.back();
                  appState.logout();
                  Get.offAllNamed(AppRoutes.login);
                },
                borderRadius: BorderRadius.circular(18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goTo(String route) {
    Get.back();
    if (Get.currentRoute != route) {
      Get.offNamed(route);
    }
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = selected ? const Color(0xFFF8DDDD) : Colors.transparent;
    final iconColor = selected
        ? const Color(0xFFD62828)
        : const Color(0xFF6F6A72);
    final textColor = selected
        ? const Color(0xFFD62828)
        : const Color(0xFF5F5A61);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _InkWellExtension on Widget {
  Widget inkWell({required VoidCallback onTap, BorderRadius? borderRadius}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: borderRadius, child: this),
    );
  }
}
