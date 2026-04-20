import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../user/core/constants/app_colors.dart';
import '../../../../user/core/constants/app_text_styles.dart';
import '../../../controllers/admin_home_controller.dart';
import '../../../controllers/admin_voucher_controller.dart';
import '../../../core/routes/admin_routes.dart';
import '../../widgets/admin_drawer.dart';

class AdminVoucherScreen extends GetView<AdminVoucherController> {
  const AdminVoucherScreen({super.key});

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
                              const Text(
                                'KELOLA VOUCHER',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Voucher',
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
                                  branchName.isEmpty ? 'Voucher' : branchName,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        height: 54,
        child: FloatingActionButton.extended(
          heroTag: 'admin_voucher_fab',
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          onPressed: () {
            Get.toNamed(AdminRoutes.voucherForm);
          },
          icon: const Icon(Icons.add_rounded, size: 22),
          label: const Text(
            'Tambah Voucher',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          );
        }

        if (controller.vouchers.isEmpty) {
          return const _EmptyVoucherState();
        }

        final totalVoucher = controller.vouchers.length;
        final totalActive = controller.vouchers
            .where((e) => e['is_active'] == true)
            .length;
        final totalInactive = totalVoucher - totalActive;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            _VoucherSummaryCard(
              totalVoucher: totalVoucher,
              totalActive: totalActive,
              totalInactive: totalInactive,
            ),
            const SizedBox(height: 20),
            ...controller.vouchers.map((voucher) {
              final voucherId = (voucher['id'] ?? '').toString();
              final code = (voucher['code'] ?? '-').toString();
              final name = (voucher['name'] ?? '').toString();
              final minTransaction = voucher['min_order_value'] ?? 0;
              final expiryDate = (voucher['expiry_date'] ?? '-').toString();
              final isActive = voucher['is_active'] == true;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _VoucherCard(
                  code: code,
                  name: name,
                  discountText: controller.formatDiscount(voucher),
                  minTransactionText: _formatCurrency(minTransaction),
                  expiryDate: _formatDate(expiryDate),
                  isActive: isActive,
                  onEdit: () {
                    Get.toNamed(
                      AdminRoutes.voucherForm,
                      arguments: {'voucher': voucher},
                    );
                  },
                  onDelete: () {
                    Get.defaultDialog(
                      title: 'Hapus Voucher?',
                      middleText: 'Voucher ini akan dihapus permanen.',
                      textConfirm: 'Hapus',
                      textCancel: 'Batal',
                      confirmTextColor: Colors.white,
                      buttonColor: AppColors.primary,
                      onConfirm: () async {
                        final ok = await controller.deleteVoucher(voucherId);
                        if (ok) {
                          Get.back(closeOverlays: true);
                        }
                      },
                    );
                  },
                  onToggle: (_) {
                    controller.toggleVoucher(
                      voucherId: voucherId,
                      currentValue: isActive,
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

  static String _formatCurrency(dynamic value) {
    final number = int.tryParse(value.toString()) ?? 0;
    final text = number.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final positionFromEnd = text.length - i;
      buffer.write(text[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'Rp ${buffer.toString()}';
  }

  static String _formatDate(String raw) {
    if (raw.isEmpty || raw == '-') return '-';

    String dateOnly = raw.trim();

    if (dateOnly.contains('T')) {
      dateOnly = dateOnly.split('T').first;
    } else if (dateOnly.contains(' ')) {
      dateOnly = dateOnly.split(' ').first;
    }

    final parts = dateOnly.split('-');
    if (parts.length != 3) return raw;

    final year = parts[0];
    final month = int.tryParse(parts[1]) ?? 0;
    final day = parts[2];

    const monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    if (month < 1 || month > 12) return raw;
    return '$day ${monthNames[month]} $year';
  }
}

class _EmptyVoucherState extends StatelessWidget {
  const _EmptyVoucherState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.discount_outlined,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada voucher',
              style: AppTextStyles.heading3.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan voucher baru untuk mulai mengatur promo cabang.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary.copyWith(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoucherSummaryCard extends StatelessWidget {
  final int totalVoucher;
  final int totalActive;
  final int totalInactive;

  const _VoucherSummaryCard({
    required this.totalVoucher,
    required this.totalActive,
    required this.totalInactive,
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
            'Ringkasan Voucher',
            style: AppTextStyles.heading3.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pantau voucher aktif dan tidak aktif yang tersedia saat ini.',
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
                child: _SummaryChip(
                  icon: Icons.confirmation_number_outlined,
                  bgColor: AppColors.primarySoft,
                  iconColor: AppColors.primary,
                  text: '$totalVoucher total',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryChip(
                  icon: Icons.check_circle_outline_rounded,
                  bgColor: AppColors.success.withValues(alpha: 0.10),
                  iconColor: AppColors.success,
                  text: '$totalActive aktif',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryChip(
                  icon: Icons.pause_circle_outline_rounded,
                  bgColor: AppColors.warning.withValues(alpha: 0.10),
                  iconColor: AppColors.warning,
                  text: '$totalInactive nonaktif',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final String text;

  const _SummaryChip({
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

class _VoucherCard extends StatelessWidget {
  final String code;
  final String name;
  final String discountText;
  final String minTransactionText;
  final String expiryDate;
  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const _VoucherCard({
    required this.code,
    required this.name,
    required this.discountText,
    required this.minTransactionText,
    required this.expiryDate,
    required this.isActive,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = isActive ? AppColors.success : AppColors.warning;
    final accentColor = isActive ? AppColors.primary : AppColors.textHint;

    return Container(
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
            height: 7,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isActive ? 'AKTIF' : 'NONAKTIF',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: badgeColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: onEdit,
                        splashRadius: 20,
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') onDelete();
                      },
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      itemBuilder: (_) => const [
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Hapus'),
                        ),
                      ],
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.more_horiz_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  code.toUpperCase(),
                  style: AppTextStyles.heading3.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                    letterSpacing: -0.3,
                  ),
                ),
                if (name.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: AppTextStyles.bodySecondary.copyWith(
                      fontSize: 13,
                      height: 1.4,
                      color: isActive
                          ? AppColors.textSecondary
                          : AppColors.textHint,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  discountText,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isActive
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 14),
                _InfoRow(
                  label: 'Min. Transaksi',
                  value: minTransactionText,
                  isMuted: !isActive,
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  label: 'Tanggal Berakhir',
                  value: expiryDate,
                  isMuted: !isActive,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          isActive
                              ? 'Voucher sedang aktif'
                              : 'Voucher sedang dinonaktifkan',
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Switch.adaptive(
                        value: isActive,
                        activeColor: AppColors.primary,
                        onChanged: onToggle,
                      ),
                    ],
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMuted;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.isMuted,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = isMuted ? AppColors.textHint : AppColors.textSecondary;
    final valueColor = isMuted ? AppColors.textHint : AppColors.textPrimary;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySecondary.copyWith(
              fontSize: 14,
              color: labelColor,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor,
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
  final VoidCallback onTapVouchers;

  const _AdminBottomBar({
    required this.onTapDashboard,
    required this.onTapOrders,
    required this.onTapMenus,
    required this.onTapVouchers,
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
            label: 'VOUCHERS',
            icon: Icons.confirmation_number_rounded,
            active: true,
            onTap: onTapVouchers,
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
