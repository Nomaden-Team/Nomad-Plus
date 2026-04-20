import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../user/core/constants/app_colors.dart';
import '../../../user/core/constants/app_text_styles.dart';
import '../../controllers/admin_home_controller.dart';
import '../../core/routes/admin_routes.dart';
import '../widgets/admin_drawer.dart';

class AdminHomeScreen extends GetView<AdminHomeController> {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(82),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondaryDark,
                AppColors.secondary,
                AppColors.primaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const Icon(
                        Icons.menu_rounded,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  /// 🔥 BRANCH INFO
                  Expanded(
                    child: Obx(() {
                      final branchName = controller.branchName.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CABANG AKTIF',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            branchName.isEmpty ? 'Loading...' : branchName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.heading3.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final message = controller.errorMessage.value;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.loadDashboard,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                    ),
                  ),
                )
              else if (message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: _DashboardInfoCard(
                    icon: Icons.info_outline_rounded,
                    title: 'Data dashboard belum bisa ditampilkan',
                    subtitle: message,
                  ),
                )
              else ...[
                const _SectionTitle(title: 'Menu Cepat'),
                SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.12,
                  children: [
                    _ShortcutCard(
                      label: 'Pesanan',
                      subtitle: 'Kelola order masuk',
                      icon: Icons.receipt_long_rounded,
                      onTap: () => controller.openMenu(AdminRoutes.orders),
                    ),
                    _ShortcutCard(
                      label: 'Menu',
                      subtitle: 'Atur daftar produk',
                      icon: Icons.restaurant_rounded,
                      onTap: () => controller.openMenu(AdminRoutes.menus),
                    ),
                    _ShortcutCard(
                      label: 'Cabang',
                      subtitle: 'Pantau lokasi toko',
                      icon: Icons.storefront_rounded,
                      onTap: () => controller.openMenu(AdminRoutes.branches),
                    ),
                    _ShortcutCard(
                      label: 'Voucher',
                      subtitle: 'Atur promo aktif',
                      icon: Icons.confirmation_number_rounded,
                      onTap: () => controller.openMenu(AdminRoutes.vouchers),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const _SectionTitle(title: 'Ringkasan Hari Ini'),
                const SizedBox(height: 14),

                _TodayOrderSummarySection(
                  pending: controller.pendingOrders.value,
                  processing: controller.processingOrders.value,
                  ready: controller.readyOrders.value,
                  done: controller.doneOrdersToday.value,
                ),
              ],
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 2,
        onPressed: () => controller.openMenu(AdminRoutes.orders),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

class _DashboardInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DashboardInfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryDark.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, size: 32, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.heading3.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary.copyWith(
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryDark.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: AppTextStyles.bodySecondary.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.display.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _CompactInfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryDark.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: AppTextStyles.display.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.heading3.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1.2, color: AppColors.divider)),
      ],
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ShortcutCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryDark.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const Spacer(),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayOrderSummarySection extends StatelessWidget {
  final int pending;
  final int processing;
  final int ready;
  final int done;

  const _TodayOrderSummarySection({
    required this.pending,
    required this.processing,
    required this.ready,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryDark.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _StatusRow(
            label: 'Menunggu',
            value: pending,
            color: AppColors.primary,
            icon: Icons.schedule_rounded,
          ),
          const SizedBox(height: 14),
          _StatusRow(
            label: 'Diproses',
            value: processing,
            color: AppColors.secondary,
            icon: Icons.coffee_maker_outlined,
          ),
          const SizedBox(height: 14),
          _StatusRow(
            label: 'Selesai',
            value: ready,
            color: AppColors.warning,
            icon: Icons.notifications_active_outlined,
          ),
          const SizedBox(height: 14),
          _StatusRow(
            label: 'Selesai Hari Ini',
            value: done,
            color: AppColors.success,
            icon: Icons.check_circle_outline_rounded,
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatusRow({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          value.toString(),
          style: AppTextStyles.display.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _AdminBottomBar extends StatelessWidget {
  final VoidCallback onTapDashboard;
  final VoidCallback onTapOrders;
  final VoidCallback onTapMenus;
  final VoidCallback onTapBranches;

  const _AdminBottomBar({
    required this.onTapDashboard,
    required this.onTapOrders,
    required this.onTapMenus,
    required this.onTapBranches,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomItem(
            label: 'DASHBOARD',
            icon: Icons.grid_view_rounded,
            active: true,
            onTap: onTapDashboard,
          ),
          _BottomItem(
            label: 'ORDERS',
            icon: Icons.receipt_long_rounded,
            onTap: onTapOrders,
          ),
          _BottomItem(
            label: 'MENUS',
            icon: Icons.restaurant_rounded,
            onTap: onTapMenus,
          ),
          _BottomItem(
            label: 'BRANCHES',
            icon: Icons.storefront_rounded,
            onTap: onTapBranches,
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _BottomItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    if (active) {
      return InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 21),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.captionBold.copyWith(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 21),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.captionBold.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
