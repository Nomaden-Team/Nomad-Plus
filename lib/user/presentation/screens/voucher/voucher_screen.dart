import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controllers/voucher/voucher_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/voucher_model.dart';

class VoucherScreen extends StatelessWidget {
  const VoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VoucherController>();

    return Obx(() {
      final active = controller.activeVouchers;
      final expired = controller.expiredVouchers;

      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: controller.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: Get.back,
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Voucher Saya',
                              style: AppTextStyles.heading2.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                        children: [
                          const _VoucherHeroCard(),
                          const SizedBox(height: 18),
                          _SectionHeader(
                            title: 'Voucher Tersedia',
                            count: active.length,
                            isPrimary: true,
                          ),
                          const SizedBox(height: 12),
                          if (active.isEmpty)
                            const _EmptyVoucherState(
                              icon: Icons.local_offer_outlined,
                              title: 'Belum ada voucher aktif',
                              subtitle:
                                  'Voucher yang masih berlaku akan muncul di sini.',
                            )
                          else
                            ...active.map(
                              (voucher) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _VoucherCard(
                                  voucher: voucher,
                                  expired: false,
                                  used: controller.isUsedByCurrentUser(voucher),
                                ),
                              ),
                            ),
                          if (expired.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _SectionHeader(
                              title: 'Sudah Tidak Berlaku',
                              count: expired.length,
                            ),
                            const SizedBox(height: 12),
                            ...expired.map(
                              (voucher) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _VoucherCard(
                                  voucher: voucher,
                                  expired: true,
                                  used: controller.isUsedByCurrentUser(voucher),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}

class _VoucherHeroCard extends StatelessWidget {
  const _VoucherHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.gradientQueue,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: const Icon(
              Icons.discount_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VOUCHER & PENAWARAN',
                  style: AppTextStyles.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Promo terbaik untuk pesananmu',
                  style: AppTextStyles.heading2.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Voucher aktif dari database akan tampil di sini dan bisa dipakai saat checkout.',
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isPrimary;

  const _SectionHeader({
    required this.title,
    required this.count,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.heading3.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primarySoft : AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.captionBold.copyWith(
              fontSize: 11,
              color: isPrimary ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyVoucherState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyVoucherState({
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
            child: Icon(icon, size: 32, color: AppColors.textHint),
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

class _VoucherCard extends StatelessWidget {
  final VoucherModel voucher;
  final bool expired;
  final bool used;

  const _VoucherCard({
    required this.voucher,
    required this.expired,
    required this.used,
  });

  bool get _disabled => expired || used;

  Color get _badgeColor {
    if (expired) return AppColors.textSecondary;
    if (used) return AppColors.warning;
    return AppColors.success;
  }

  Color get _badgeBg {
    if (expired) return AppColors.surfaceSoft;
    if (used) return const Color(0xFFFFF4DE);
    return const Color(0xFFE8F8F0);
  }

  String get _badgeLabel {
    if (expired) return 'KADALUARSA';
    if (used) return 'SUDAH DIPAKAI';
    return 'AKTIF';
  }

  String get _discountLabel {
    switch (voucher.type) {
      case VoucherType.percent:
        return '${voucher.discountValue}%';
      case VoucherType.fixed:
      case VoucherType.birthday:
        return Formatters.currency(voucher.discountValue);
      case VoucherType.freeItem:
        return 'FREE';
    }
  }

  String get _discountSub {
    switch (voucher.type) {
      case VoucherType.percent:
        return 'DISKON PERSEN';
      case VoucherType.fixed:
        return 'POTONGAN LANGSUNG';
      case VoucherType.freeItem:
        return 'GRATIS ITEM';
      case VoucherType.birthday:
        return 'VOUCHER SPESIAL';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _disabled ? 0.62 : 1,
      child: Container(
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
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              decoration: BoxDecoration(
                gradient: _disabled
                    ? const LinearGradient(
                        colors: [Color(0xFF8E8E8E), Color(0xFFB0B0B0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : AppColors.gradientQueue,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          voucher.code,
                          style: AppTextStyles.label.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _discountLabel,
                          style: AppTextStyles.display.copyWith(
                            fontSize:
                                voucher.type == VoucherType.fixed ||
                                    voucher.type == VoucherType.birthday
                                ? 28
                                : 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _discountSub,
                          style: AppTextStyles.captionBold.copyWith(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.86),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Text(
                      _badgeLabel,
                      style: AppTextStyles.captionBold.copyWith(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voucher.name,
                    style: AppTextStyles.heading3.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    voucher.typeLabel,
                    style: AppTextStyles.bodySecondary.copyWith(
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MiniInfoChip(
                        icon: Icons.shopping_bag_outlined,
                        text: voucher.minOrderValue > 0
                            ? 'Min. belanja ${Formatters.currency(voucher.minOrderValue)}'
                            : 'Tanpa minimum belanja',
                      ),
                      _MiniInfoChip(
                        icon: Icons.calendar_today_outlined,
                        text: expired
                            ? 'Berakhir ${_formatDate(voucher.expiryDate)}'
                            : 'Berlaku sampai ${_formatDate(voucher.expiryDate)}',
                      ),
                    ],
                  ),
                  if (voucher.maxDiscount != null &&
                      voucher.type == VoucherType.percent) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Maksimal diskon ${Formatters.currency(voucher.maxDiscount!)}',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _disabled
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            color: _badgeBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                expired
                                    ? Icons.block_rounded
                                    : Icons.check_circle_rounded,
                                size: 16,
                                color: _badgeColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _badgeLabel,
                                style: AppTextStyles.captionBold.copyWith(
                                  fontSize: 12,
                                  color: _badgeColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: voucher.code),
                              );
                              Get.snackbar(
                                'Berhasil',
                                'Kode ${voucher.code} berhasil disalin',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.white,
                                colorText: AppColors.textPrimary,
                                borderColor: AppColors.cardBorder,
                                borderWidth: 1,
                                margin: const EdgeInsets.all(12),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            label: Text(
                              'Salin Kode ${voucher.code}',
                              style: AppTextStyles.button.copyWith(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniInfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
