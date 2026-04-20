import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/home/main_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/app_state.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _requireLogin() {
    Get.defaultDialog(
      title: 'Login Diperlukan',
      middleText: 'Kamu harus login dulu untuk mengakses fitur ini.',
      textConfirm: 'Login',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () {
        Get.back();
        Get.toNamed(AppRoutes.login);
      },
    );
  }

  int? _nextTierTarget(String tier) {
    switch (tier) {
      case 'bronze':
        return 100;
      case 'silver':
        return 300;
      case 'gold':
        return 800;
      default:
        return null;
    }
  }

  String _nextTierLabel(String tier) {
    switch (tier) {
      case 'bronze':
        return 'Silver';
      case 'silver':
        return 'Gold';
      case 'gold':
        return 'Platinum';
      default:
        return 'Max';
    }
  }

  String _currentTierFloorLabel(String tier) {
    switch (tier) {
      case 'silver':
        return '100 SILVER';
      case 'gold':
        return '300 GOLD';
      case 'platinum':
        return '800 PLATINUM';
      default:
        return '0 BRONZE';
    }
  }

  Color _tierColor(String tier) {
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

  @override
  Widget build(BuildContext context) {
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

        final pts = user.loyaltyPoints;
        final totalEarned = user.totalEarnedPoints;
        final tier = user.membershipTier.toLowerCase();
        final tierLabel = UserModel.getTierLabel(tier);
        final tierColor = _tierColor(tier);
        final nextTierPts = _nextTierTarget(tier);
        final nextTierLabel = _nextTierLabel(tier);

        final progressValue = nextTierPts == null
            ? 1.0
            : (totalEarned / nextTierPts).clamp(0.0, 1.0);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.gradientQueue,
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              'Profil',
                              style: AppTextStyles.heading2.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () {
                              if (isLoggedIn) {
                                Get.toNamed(AppRoutes.editProfile);
                              } else {
                                _requireLogin();
                              }
                            },
                            child: Container(
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.10),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : 'N',
                                  style: AppTextStyles.display.copyWith(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            user.name,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.heading2.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user.email.isNotEmpty ? user.email : 'Belum login',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySecondary.copyWith(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.82),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.24),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.workspace_premium_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${tierLabel.toUpperCase()} MEMBER',
                                  style: AppTextStyles.captionBold.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.loyalty),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(22),
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
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'SALDO POIN',
                                          style: AppTextStyles.label.copyWith(
                                            fontSize: 10,
                                            letterSpacing: 1,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              Formatters.commas(pts),
                                              style: AppTextStyles.display
                                                  .copyWith(
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.w900,
                                                    color:
                                                        AppColors.textPrimary,
                                                    height: 1,
                                                  ),
                                            ),
                                            const SizedBox(width: 4),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 4,
                                              ),
                                              child: Text(
                                                'Poin',
                                                style: AppTextStyles
                                                    .bodySecondary
                                                    .copyWith(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: tierColor.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'TARGET BERIKUTNYA',
                                          style: AppTextStyles.label.copyWith(
                                            fontSize: 10,
                                            color: tierColor,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          nextTierLabel,
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.textPrimary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: progressValue,
                                  minHeight: 8,
                                  backgroundColor: AppColors.surfaceGrey,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    tierColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _currentTierFloorLabel(tier),
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    nextTierPts == null
                                        ? 'MAX TIER'
                                        : '${Formatters.commas(nextTierPts)} ${nextTierLabel.toUpperCase()}',
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                nextTierPts == null
                                    ? 'Kamu sudah ada di tier tertinggi.'
                                    : '${Formatters.commas(totalEarned)}/${Formatters.commas(nextTierPts)} total earned',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'AKUN',
                          style: AppTextStyles.label.copyWith(
                            fontSize: 11,
                            letterSpacing: 1.3,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _item(
                        icon: Icons.person_outline_rounded,
                        label: 'Informasi Pribadi',
                        sub: isLoggedIn
                            ? '${user.name} • ${user.phone}'
                            : 'Login dulu untuk mengakses',
                        onTap: () {
                          if (isLoggedIn) {
                            Get.toNamed(AppRoutes.editProfile);
                          } else {
                            _requireLogin();
                          }
                        },
                      ),
                      _item(
                        icon: Icons.receipt_long_outlined,
                        label: 'Riwayat Pesanan',
                        sub: 'Lihat semua pesanan',
                        onTap: () {
                          Get.find<MainController>().changeTab(3);
                        },
                      ),
                      _item(
                        icon: Icons.discount_outlined,
                        label: 'Voucher & Penawaran',
                        onTap: () => Get.toNamed(AppRoutes.voucher),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Get.defaultDialog(
                            title: 'Keluar?',
                            middleText: 'Kamu akan keluar dari akun ini.',
                            textConfirm: 'Keluar',
                            textCancel: 'Batal',
                            confirmTextColor: Colors.white,
                            buttonColor: AppColors.primary,
                            onConfirm: () {
                              Get.back();
                              appState.logout();
                              Get.offAllNamed(AppRoutes.login);
                            },
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 1.4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text(
                            'Keluar',
                            style: AppTextStyles.button.copyWith(
                              fontSize: 14,
                              color: AppColors.primary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'TEH TARIK NOMAD • BUILT FOR JOURNEY',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: AppColors.textHint,
                          letterSpacing: 0.4,
                        ),
                      ),
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

  Widget _item({
    required IconData icon,
    required String label,
    String? sub,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryDark.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (sub != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      sub,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
