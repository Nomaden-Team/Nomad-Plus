import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../user/core/constants/app_colors.dart';
import '../../../../user/core/constants/app_text_styles.dart';
import '../../../controllers/admin_order_controller.dart';
import '../../../core/routes/admin_routes.dart';
import '../../widgets/admin_drawer.dart';

class AdminOrderScreen extends GetView<AdminOrderController> {
  const AdminOrderScreen({super.key});

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
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Kelola Pesanan',
                      style: AppTextStyles.heading3.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.8,
                      ),
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _OrderSummaryHero(
              selectedStatus: controller.selectedStatus.value,
              totalCount: controller.orders.length,
              subtitle: 'Pantau pesanan yang sedang berjalan',
            ),
          ),
          const SizedBox(height: 18),
          _buildStatusTabs(),
          const SizedBox(height: 14),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                );
              }

              if (controller.errorMessage.value.isNotEmpty &&
                  controller.orders.isEmpty) {
                return _InfoOrderState(
                  icon: Icons.info_outline_rounded,
                  title: 'Pesanan belum tampil',
                  subtitle: controller.errorMessage.value,
                );
              }

              final orders = controller.orders;

              if (orders.isEmpty) {
                return const _EmptyOrderState();
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final order = orders[index];

                  final userData =
                      order['users'] as Map<String, dynamic>? ?? {};
                  final branchData =
                      order['branches'] as Map<String, dynamic>? ?? {};

                  final orderId = (order['id'] ?? '').toString();
                  final queueNumber = (order['queue_number'] ?? '-').toString();

                  final customerName =
                      (userData['name'] ?? '').toString().trim().isEmpty
                      ? 'Pelanggan'
                      : (userData['name'] ?? '').toString();

                  final branchName =
                      (branchData['name'] ?? '').toString().trim().isEmpty
                      ? 'Cabang tidak diketahui'
                      : (branchData['name'] ?? '').toString();

                  final totalValue = _toInt(order['grand_total']);
                  final status = (order['status'] ?? '-').toString();

                  return InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () =>
                        Get.toNamed(AdminRoutes.orderDetail, arguments: order),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondaryDark.withValues(
                              alpha: 0.04,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _topRow(queueNumber: queueNumber, status: status),
                          const SizedBox(height: 14),
                          _infoRow(
                            icon: Icons.person_outline_rounded,
                            text: customerName,
                            bold: true,
                          ),
                          const SizedBox(height: 8),
                          _infoRow(
                            icon: Icons.storefront_outlined,
                            text: branchName,
                          ),
                          const SizedBox(height: 8),
                          _infoRow(
                            icon: Icons.payments_outlined,
                            text: _formatPrice(totalValue),
                          ),
                          const SizedBox(height: 18),
                          _actionButtons(status: status, orderId: orderId),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs() {
    return Obx(() {
      final selected = controller.selectedStatus.value;
      final statuses = controller.statuses;

      return SizedBox(
        height: 42,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: statuses.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final status = statuses[index];
            final isSelected = selected == status;

            return GestureDetector(
              onTap: () => controller.changeFilter(status),
              child: Container(
                constraints: const BoxConstraints(minWidth: 102),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.cardBorder,
                  ),
                ),
                child: Text(
                  controller.formatStatusLabel(status),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _topRow({required String queueNumber, required String status}) {
    final badge = _statusStyle(status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'QUEUE NO.\n',
                  style: AppTextStyles.captionBold.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: badge.accent,
                    letterSpacing: 1.1,
                  ),
                ),
                TextSpan(
                  text: '#$queueNumber',
                  style: AppTextStyles.heading2.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: badge.bg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            badge.label,
            style: AppTextStyles.captionBold.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: badge.accent,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String text,
    bool bold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: bold ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButtons({required String status, required String orderId}) {
    final isBusy =
        controller.isUpdatingStatus.value &&
        controller.updatingOrderId.value == orderId;

    if (status == 'menunggu') {
      return Row(
        children: [
          Expanded(
            child: _primaryButton(
              label: isBusy ? 'Memproses...' : 'Terima Pembayaran',
              color: AppColors.primary,
              onTap: isBusy
                  ? null
                  : () {
                      controller.updateOrderStatus(
                        orderId: orderId,
                        newStatus: 'diproses',
                      );
                    },
            ),
          ),
        ],
      );
    }

    if (status == 'diproses') {
      return Row(
        children: [
          Expanded(
            child: _primaryButton(
              label: isBusy ? 'Memproses...' : 'Selesaikan Pesanan',
              color: AppColors.secondary,
              onTap: isBusy
                  ? null
                  : () {
                      controller.updateOrderStatus(
                        orderId: orderId,
                        newStatus: 'selesai',
                      );
                    },
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              controller.formatStatusLabel(status),
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _primaryButton({
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          disabledBackgroundColor: color.withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton({
    required String label,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceSoft,
          foregroundColor: AppColors.textSecondary,
          elevation: 0,
          disabledBackgroundColor: AppColors.surfaceSoft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  _StatusStyle _statusStyle(String status) {
    switch (status) {
      case 'menunggu':
        return const _StatusStyle(
          label: 'MENUNGGU',
          bg: Color(0xFFFBEAEC),
          accent: AppColors.primary,
        );
      case 'diproses':
        return const _StatusStyle(
          label: 'DIPROSES',
          bg: Color(0xFFE8F5F4),
          accent: AppColors.secondary,
        );
      case 'selesai':
        return const _StatusStyle(
          label: 'SELESAI',
          bg: Color(0xFFEAF7EC),
          accent: AppColors.success,
        );
      default:
        return const _StatusStyle(
          label: 'SELESAI',
          bg: Color(0xFFEAF7EC),
          accent: AppColors.success,
        );
    }
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  String _formatPrice(int value) {
    final raw = value.toString();
    final chars = raw.split('').reversed.toList();
    final buffer = StringBuffer();

    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(chars[i]);
    }

    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }
}

class _OrderSummaryHero extends StatelessWidget {
  final String selectedStatus;
  final int totalCount;
  final String subtitle;

  const _OrderSummaryHero({
    required this.selectedStatus,
    required this.totalCount,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedStatus.toUpperCase(),
                  style: AppTextStyles.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$totalCount pesanan',
                  style: AppTextStyles.heading2.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.white.withValues(alpha: 0.86),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoOrderState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoOrderState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: AppColors.textHint),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading2.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary.copyWith(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrderState extends StatelessWidget {
  const _EmptyOrderState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 72,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 18),
            Text(
              'Belum ada pesanan',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading2.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada order pada status ini.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary.copyWith(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0E7E2))),
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
            active: true,
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

class _StatusStyle {
  final String label;
  final Color bg;
  final Color accent;

  const _StatusStyle({
    required this.label,
    required this.bg,
    required this.accent,
  });
}
