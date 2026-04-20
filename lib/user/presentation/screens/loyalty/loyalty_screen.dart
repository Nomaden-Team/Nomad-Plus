import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../../../controllers/home/main_controller.dart';
import '../../../controllers/menu/menu_controller.dart';
import '../../../controllers/menu/menu_detail_controller.dart';
import '../../../core/app_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/models/user_model.dart';
import '../menu/menu_detail_sheet.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuController = Get.find<MenuController>();

    return GetBuilder<AppStateController>(
      builder: (appState) {
        final isLoggedIn = appState.isLoggedIn;
        final user = isLoggedIn
            ? appState.user
            : const UserModel(
                id: '',
                authId: '',
                name: 'Guest',
                email: '',
                phone: '',
                loyaltyPoints: 0,
                totalEarnedPoints: 0,
                membershipTier: 'bronze',
                role: 'user',
              );

        final points = user.loyaltyPoints;
        final tier = user.membershipTier.toLowerCase();
        final tierLabel = UserModel.getTierLabel(tier);
        final progressInfo = _nextTierInfo(
          tier: tier,
          totalEarnedPoints: user.totalEarnedPoints,
        );
        final tierAccent = _tierAccentColor(tier);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _CompactLoyaltyHeader(
                  user: user,
                  points: points,
                  tierLabel: tierLabel,
                  nextTierTitle: progressInfo.title,
                  nextTierSubtitle: progressInfo.subtitle,
                  progress: progressInfo.progress,
                  progressText: progressInfo.progressText,
                  tierAccent: tierAccent,
                  onProfileTap: _openProfileTab,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _QuickInfoCard(
                              title: 'Poin Aktif',
                              value: Formatters.commas(points),
                              subtitle: 'Siap digunakan',
                              icon: Icons.stars_rounded,
                              accentColor: AppColors.primary,
                              softColor: AppColors.primarySoft,
                              onTap: _showUsePointsInfo,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickInfoCard(
                              title: 'Membership',
                              value: tierLabel,
                              subtitle: 'Level saat ini',
                              icon: Icons.workspace_premium_rounded,
                              accentColor: tierAccent,
                              softColor: tierAccent.withValues(alpha: 0.14),
                              onTap: () => _showBenefitsInfo(tier),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const _SectionTitle(
                        title: 'Info Loyalty',
                        subtitle:
                            'Tap tiap kartu untuk melihat informasi lengkap seputar membership, poin, dan rewards.',
                      ),
                      const SizedBox(height: 14),
                      _InfoEntryCard(
                        icon: Icons.workspace_premium_rounded,
                        title: 'Benefit Membership',
                        subtitle:
                            'Lihat benefit aktif sesuai tier membership kamu.',
                        iconColor: tierAccent,
                        onTap: () => _showBenefitsInfo(tier),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _FeatureCard(
                              icon: Icons.shopping_bag_outlined,
                              title: 'Cara Mendapatkan',
                              subtitle:
                                  'Poin didapat dari transaksi selesai dan mengikuti nominal belanja.',
                              accentColor: AppColors.secondary,
                              onTap: _showEarnInfo,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _FeatureCard(
                              icon: Icons.account_balance_wallet_outlined,
                              title: 'Cara Menggunakan',
                              subtitle:
                                  'Gunakan poin untuk checkout atau tukarkan ke reward tertentu.',
                              accentColor: AppColors.primary,
                              onTap: _showUsePointsInfo,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoEntryCard(
                        icon: Icons.rule_folder_outlined,
                        title: 'Aturan Penting Loyalty',
                        subtitle:
                            'Ringkasan aturan penggunaan poin dan reward.',
                        iconColor: AppColors.textPrimary,
                        onTap: _showRulesInfo,
                      ),
                      _InfoEntryCard(
                        icon: Icons.info_outline_rounded,
                        title: 'Syarat & Ketentuan Poin',
                        subtitle:
                            'Masa berlaku, pembatalan transaksi, dan penyalahgunaan program.',
                        iconColor: AppColors.textSecondary,
                        onTap: _showTermsInfo,
                      ),
                      _InfoEntryCard(
                        icon: Icons.payments_outlined,
                        title: 'Aturan Voucher & Poin',
                        subtitle:
                            'Kombinasi promo, pembatasan penggunaan, dan alur checkout.',
                        iconColor: AppColors.textSecondary,
                        onTap: _showVoucherInfo,
                      ),
                      _InfoEntryCard(
                        icon: Icons.help_outline_rounded,
                        title: 'Panduan Program Rewards',
                        subtitle:
                            'Panduan cepat untuk memahami earn, use, dan redeem.',
                        iconColor: AppColors.textSecondary,
                        onTap: _showGuideInfo,
                      ),
                      const SizedBox(height: 26),
                      const _SectionTitle(
                        title: 'Menu Rewards',
                        subtitle:
                            'Tukarkan poinmu dengan menu favorit yang tersedia hari ini.',
                      ),
                      const SizedBox(height: 14),
                      Obx(() {
                        final menus = menuController.menus;

                        if (menuController.isLoading.value) {
                          return const SizedBox(
                            height: 214,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.secondary,
                              ),
                            ),
                          );
                        }

                        if (menus.isEmpty) {
                          return const _EmptyRewardsCard();
                        }

                        final displayMenus = menus
                            .where((menu) => menu.isAvailable)
                            .take(6)
                            .toList();

                        if (displayMenus.isEmpty) {
                          return const _EmptyRewardsCard();
                        }

                        return SizedBox(
                          height: 214,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: displayMenus.length,
                            itemBuilder: (context, index) {
                              final menu = displayMenus[index];
                              return _MenuRewardCard(menu: menu);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static _TierProgressInfo _nextTierInfo({
    required String tier,
    required int totalEarnedPoints,
  }) {
    if (tier == 'platinum') {
      return const _TierProgressInfo(
        title: 'Tier Tertinggi Tercapai',
        subtitle: 'Kamu sudah berada di level Platinum dengan benefit terbaik.',
        progress: 1,
        progressText: 'Platinum Member',
      );
    }

    if (tier == 'gold') {
      final remaining = (800 - totalEarnedPoints).clamp(0, 800);
      final currentProgress = ((totalEarnedPoints - 300) / 500)
          .clamp(0, 1)
          .toDouble();

      return _TierProgressInfo(
        title: 'Progress ke Platinum',
        subtitle: '$remaining poin lagi untuk naik ke Platinum.',
        progress: currentProgress,
        progressText:
            '${Formatters.commas(totalEarnedPoints)}/800 total earned',
      );
    }

    if (tier == 'silver') {
      final remaining = (300 - totalEarnedPoints).clamp(0, 300);
      final currentProgress = ((totalEarnedPoints - 100) / 200)
          .clamp(0, 1)
          .toDouble();

      return _TierProgressInfo(
        title: 'Progress ke Gold',
        subtitle: '$remaining poin lagi untuk naik ke Gold.',
        progress: currentProgress,
        progressText:
            '${Formatters.commas(totalEarnedPoints)}/300 total earned',
      );
    }

    final remaining = (100 - totalEarnedPoints).clamp(0, 100);
    final currentProgress = (totalEarnedPoints / 100).clamp(0, 1).toDouble();

    return _TierProgressInfo(
      title: 'Progress ke Silver',
      subtitle: '$remaining poin lagi untuk naik ke Silver.',
      progress: currentProgress,
      progressText: '${Formatters.commas(totalEarnedPoints)}/100 total earned',
    );
  }

  static Color _tierAccentColor(String tier) {
    switch (tier) {
      case 'silver':
        return const Color(0xFF6F7C8F);
      case 'gold':
        return const Color(0xFFB8892D);
      case 'platinum':
        return const Color(0xFF4F8FB3);
      default:
        return const Color(0xFF9A6133);
    }
  }

  static void _openProfileTab() {
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().changeTab(4);
    }
  }

  static int _rewardPointsFromPrice(int price) {
    if (price <= 0) return 0;
    return (price / 1000).ceil();
  }

  static void _showBenefitsInfo(String tier) {
    final title = 'Benefit ${UserModel.getTierLabel(tier)}';
    final items = _benefitsForTier(tier);

    _showInfoSheet(
      title: title,
      items: items,
      footer:
          'Benefit dapat berubah mengikuti kebijakan program loyalty yang berlaku.',
    );
  }

  static void _showEarnInfo() {
    _showInfoSheet(
      title: 'Cara Mendapatkan Poin',
      items: const [
        'Dapatkan 1 poin untuk setiap pembelanjaan Rp5.000.',
        'Poin dihitung dari total pembayaran akhir yang berhasil diselesaikan.',
        'Berlaku kelipatan sesuai nominal transaksi.',
        'Tier membership memengaruhi multiplier poin.',
        'Poin masuk setelah transaksi selesai dan tervalidasi.',
        'Transaksi yang memakai voucher atau poin tidak menambah poin baru.',
      ],
      footer: 'Multiplier tier: Bronze 1x, Silver 1x, Gold 1.5x, Platinum 2x.',
    );
  }

  static void _showUsePointsInfo() {
    _showInfoSheet(
      title: 'Cara Menggunakan Poin',
      items: const [
        '1 poin = Rp1.000 untuk potongan pembayaran saat checkout.',
        'Maksimal penggunaan poin adalah 10% dari subtotal transaksi.',
        'Poin tidak dapat digunakan bersamaan dengan voucher dalam satu transaksi.',
        'Transaksi yang memakai poin tidak menghasilkan poin baru.',
        'Poin juga dapat ditukar langsung dengan menu reward tertentu.',
      ],
      footer: 'Masa berlaku poin adalah 12 bulan sejak diperoleh.',
    );
  }

  static void _showRulesInfo() {
    _showInfoSheet(
      title: 'Aturan Penting Loyalty',
      items: const [
        'Penggunaan poin maksimal 10% dari subtotal transaksi.',
        'Voucher dan poin tidak dapat dipakai bersamaan.',
        'Transaksi yang memakai voucher atau poin tidak menghasilkan poin baru.',
        'Reward item maksimal 1 redeem per hari per akun.',
        'Poin berlaku selama 12 bulan sejak diperoleh.',
      ],
    );
  }

  static void _showTermsInfo() {
    _showInfoSheet(
      title: 'Syarat & Ketentuan Poin',
      items: const [
        'Poin berlaku selama 12 bulan sejak tanggal diperoleh.',
        'Poin tidak dapat diuangkan atau dipindahtangankan.',
        'Jika transaksi dibatalkan, poin yang digunakan akan dikembalikan dan poin yang didapat akan dibatalkan.',
        'Nomad berhak menyesuaikan atau menarik poin jika ditemukan penyalahgunaan program.',
      ],
    );
  }

  static void _showVoucherInfo() {
    _showInfoSheet(
      title: 'Aturan Voucher & Poin',
      items: const [
        'Voucher dan poin tidak dapat digunakan bersamaan dalam satu transaksi.',
        'Jika menggunakan voucher, transaksi tidak mendapatkan poin baru.',
        'Jika menggunakan poin, transaksi tidak mendapatkan poin baru.',
        'Voucher diprioritaskan untuk promo, sedangkan poin untuk reward loyalitas.',
      ],
    );
  }

  static void _showGuideInfo() {
    _showInfoSheet(
      title: 'Panduan Program Rewards',
      items: const [
        'Kumpulkan poin dari transaksi yang berhasil.',
        'Pantau progress membership untuk naik tier.',
        'Gunakan poin saat checkout sesuai aturan program.',
        'Tukarkan poin ke reward item yang tersedia.',
        'Pastikan memahami batasan voucher, poin, dan redeem harian.',
      ],
    );
  }

  static void _showInfoSheet({
    required String title,
    required List<String> items,
    String? footer,
  }) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 54,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontSize: 13,
                            height: 1.55,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (footer != null) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    footer,
                    style: AppTextStyles.captionBold.copyWith(
                      fontSize: 12.5,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static List<String> _benefitsForTier(String tier) {
    switch (tier) {
      case 'platinum':
        return const [
          'Multiplier poin 2x untuk transaksi yang memenuhi syarat.',
          'Prioritas tertinggi untuk benefit loyalty dan reward.',
          'Lebih cepat mencapai penukaran reward bernilai tinggi.',
        ];
      case 'gold':
        return const [
          'Multiplier poin 1.5x untuk transaksi yang memenuhi syarat.',
          'Akses benefit lebih tinggi dibanding Silver.',
          'Progress lebih cepat menuju Platinum.',
        ];
      case 'silver':
        return const [
          'Multiplier poin 1x untuk transaksi yang memenuhi syarat.',
          'Bisa menggunakan poin saat checkout sesuai aturan program.',
          'Bisa menukarkan poin ke menu reward yang tersedia.',
        ];
      default:
        return const [
          'Multiplier poin 1x untuk transaksi yang memenuhi syarat.',
          'Mulai kumpulkan poin dari setiap transaksi yang berhasil.',
          'Naik tier untuk membuka benefit loyalty yang lebih tinggi.',
        ];
    }
  }
}

class _TierProgressInfo {
  final String title;
  final String subtitle;
  final double progress;
  final String progressText;

  const _TierProgressInfo({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.progressText,
  });
}

class _CompactLoyaltyHeader extends StatelessWidget {
  final UserModel user;
  final int points;
  final String tierLabel;
  final String nextTierTitle;
  final String nextTierSubtitle;
  final double progress;
  final String progressText;
  final Color tierAccent;
  final VoidCallback onProfileTap;

  const _CompactLoyaltyHeader({
    required this.user,
    required this.points,
    required this.tierLabel,
    required this.nextTierTitle,
    required this.nextTierSubtitle,
    required this.progress,
    required this.progressText,
    required this.tierAccent,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.gradientQueue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LOYALTY',
              style: AppTextStyles.heading2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            _ProfileInlineCard(user: user, onTap: onProfileTap),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nomad Points',
                    style: AppTextStyles.bodySecondary.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.commas(points),
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          nextTierTitle,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: tierAccent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: tierAccent.withValues(alpha: 0.28),
                          ),
                        ),
                        child: Text(
                          '$tierLabel Member',
                          style: AppTextStyles.captionBold.copyWith(
                            color: tierAccent,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    nextTierSubtitle,
                    style: AppTextStyles.bodySecondary.copyWith(
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: AlwaysStoppedAnimation<Color>(tierAccent),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    progressText,
                    style: AppTextStyles.captionBold.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
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

class _ProfileInlineCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const _ProfileInlineCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final initial = user.name.trim().isNotEmpty
        ? user.name.trim()[0].toUpperCase()
        : 'N';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.surfaceSoft,
                  child: Text(
                    initial,
                    style: AppTextStyles.heading3.copyWith(
                      fontSize: 17,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading3.copyWith(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading2.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: AppTextStyles.bodySecondary.copyWith(
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _QuickInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color softColor;
  final VoidCallback onTap;

  const _QuickInfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.softColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: softColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accentColor, size: 21),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: AppTextStyles.captionBold.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.heading3.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.caption.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                color: accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: AppTextStyles.heading3.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodySecondary.copyWith(
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Lihat info',
                  style: AppTextStyles.captionBold.copyWith(
                    color: accentColor,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, size: 16, color: accentColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoEntryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _InfoEntryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRewardsCard extends StatelessWidget {
  const _EmptyRewardsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 126,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Center(
        child: Text(
          'Menu reward belum tersedia',
          style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
        ),
      ),
    );
  }
}

class _MenuRewardCard extends StatelessWidget {
  final MenuItem menu;

  const _MenuRewardCard({required this.menu});

  void _openRedeemSheet() {
    final appState = Get.find<AppStateController>();

    if (!appState.canRedeemToday()) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Reward Tidak Tersedia',
            style: AppTextStyles.heading3.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Kamu sudah menukar 1 reward hari ini. Silakan coba lagi besok.',
            style: AppTextStyles.bodySecondary.copyWith(
              fontSize: 13,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Tutup')),
          ],
        ),
      );
      return;
    }

    Get.bottomSheet(
      MenuDetailSheet(
        controller: MenuDetailController(item: menu, isRedeemMode: true),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  String _normalizeAssetPath(String raw) {
    final path = raw.trim();

    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    if (path.startsWith('assets/')) return path;
    if (path.startsWith('menu_images/')) return 'assets/$path';
    if (path.startsWith('promo/')) return 'assets/$path';
    return 'assets/menu_images/$path';
  }

  @override
  Widget build(BuildContext context) {
    final points = LoyaltyScreen._rewardPointsFromPrice(menu.price);
    final imagePath = _normalizeAssetPath(menu.imageUrl);

    return GestureDetector(
      onTap: _openRedeemSheet,
      child: Container(
        width: 156,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: imagePath.isEmpty
                  ? Container(
                      height: 86,
                      width: double.infinity,
                      color: AppColors.surfaceGrey,
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 22,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : imagePath.startsWith('http')
                  ? Image.network(
                      imagePath,
                      height: 86,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 86,
                        width: double.infinity,
                        color: AppColors.surfaceGrey,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 22,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  : Image.asset(
                      imagePath,
                      height: 86,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 86,
                        width: double.infinity,
                        color: AppColors.surfaceGrey,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 22,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              menu.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${Formatters.commas(points)} poin',
              style: AppTextStyles.captionBold.copyWith(
                fontSize: 12.5,
                color: AppColors.secondary,
              ),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                'Klaim',
                style: AppTextStyles.captionBold.copyWith(
                  color: AppColors.primary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
