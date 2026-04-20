import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../user/core/constants/app_colors.dart';
import '../../../../user/core/constants/app_text_styles.dart';
import '../../../controllers/admin_branch_controller.dart';
import '../../../controllers/admin_home_controller.dart';
import '../../../core/routes/admin_routes.dart';
import '../../widgets/admin_drawer.dart';

class AdminBranchScreen extends GetView<AdminBranchController> {
  const AdminBranchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.isRegistered<AdminHomeController>()
        ? Get.find<AdminHomeController>()
        : null;

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
                  Expanded(
                    child: homeController == null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'CABANG AKTIF',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Cabang',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.heading3.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Obx(() {
                            final branchName = homeController.branchName.value
                                .trim();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 14,
                                      color: Colors.white70,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'CABANG AKTIF',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  branchName.isEmpty ? 'Cabang' : branchName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.heading3.copyWith(
                                    fontSize: 20,
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
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          );
        }

        if (controller.branches.isEmpty) {
          return const _EmptyBranchState();
        }

        final totalBranches = controller.branches.length;
        final totalOpen = controller.branches
            .where((e) => e['is_open'] == true)
            .length;
        final totalClosed = totalBranches - totalOpen;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            _BranchHeader(
              totalCount: totalBranches,
              activeCount: totalOpen,
              closedCount: totalClosed,
            ),
            const SizedBox(height: 20),
            ...controller.branches.map((branch) {
              final branchId = (branch['id'] ?? '').toString();
              final name = (branch['name'] ?? '-').toString();
              final address = (branch['address'] ?? branch['location'] ?? '-')
                  .toString();
              final openTime = (branch['open_time'] ?? '-').toString();
              final closeTime = (branch['close_time'] ?? '-').toString();
              final isOpen = branch['is_open'] == true;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _BranchCard(
                  name: name,
                  address: address,
                  openTime: openTime,
                  closeTime: closeTime,
                  isOpen: isOpen,
                  onEdit: () {
                    controller.fillForm(branch);
                    Get.toNamed(
                      AdminRoutes.branchForm,
                      arguments: {'id': branchId},
                    );
                  },
                  onToggle: (_) {
                    controller.toggleBranch(
                      branchId: branchId,
                      currentValue: isOpen,
                    );
                  },
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}

class _EmptyBranchState extends StatelessWidget {
  const _EmptyBranchState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(
                Icons.storefront_outlined,
                size: 42,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum ada data cabang',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading3.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Data cabang belum tersedia di sistem.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary.copyWith(
                fontSize: 14,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchHeader extends StatelessWidget {
  final int totalCount;
  final int activeCount;
  final int closedCount;

  const _BranchHeader({
    required this.totalCount,
    required this.activeCount,
    required this.closedCount,
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
          Text(
            'Ringkasan Cabang',
            style: AppTextStyles.heading3.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Menampilkan akumulasi seluruh cabang yang tercatat di sistem.',
            style: AppTextStyles.bodySecondary.copyWith(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatusCountChip(
                  icon: Icons.storefront_outlined,
                  bgColor: AppColors.primarySoft,
                  iconColor: AppColors.primary,
                  text: '$totalCount total',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatusCountChip(
                  icon: Icons.check_circle_outline_rounded,
                  bgColor: AppColors.success.withValues(alpha: 0.10),
                  iconColor: AppColors.success,
                  text: '$activeCount aktif',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatusCountChip(
                  icon: Icons.pause_circle_outline_rounded,
                  bgColor: AppColors.warning.withValues(alpha: 0.10),
                  iconColor: AppColors.warning,
                  text: '$closedCount tutup',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusCountChip extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final String text;

  const _StatusCountChip({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  final String name;
  final String address;
  final String openTime;
  final String closeTime;
  final bool isOpen;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggle;

  const _BranchCard({
    required this.name,
    required this.address,
    required this.openTime,
    required this.closeTime,
    required this.isOpen,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = isOpen ? AppColors.success : AppColors.warning;

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
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isOpen ? 'BUKA' : 'TUTUP',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: AppTextStyles.heading3.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  address,
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Jam Operasional',
                    style: AppTextStyles.captionBold.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  '$openTime - $closeTime',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text(
                      'Edit',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => onToggle(!isOpen),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    backgroundColor: AppColors.surfaceSoft,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isOpen ? 'Tutup' : 'Buka',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
            active: true,
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
