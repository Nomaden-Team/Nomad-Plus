import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../../../controllers/cart/cart_controller.dart';
import '../../../controllers/home/home_controller.dart';
import '../../../controllers/home/main_controller.dart';
import '../../../controllers/menu/menu_controller.dart';
import '../../../controllers/menu/menu_detail_controller.dart';
import '../../../core/app_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/models/user_model.dart';
import '../menu/menu_detail_sheet.dart';

bool _isAllowedHomeCategory(String name) {
  final normalized = name.trim().toLowerCase();
  return normalized == 'drink' ||
      normalized == 'snack' ||
      normalized == 'food' ||
      normalized == 'dessert';
}

const List<_PromoSlideData> _dummyPromoSlides = [
  _PromoSlideData(
    title: 'Discount 30%',
    subtitle: 'Khusus minggu ini',
    imageUrl:
        'https://vpralnmqzcumeptstlyf.supabase.co/storage/v1/object/public/promo/promo.jpeg',
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<HomeController>();
    final appState = Get.find<AppStateController>();
    final cartCtrl = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (homeCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (homeCtrl.errorMessage.value.isNotEmpty &&
            homeCtrl.branches.isEmpty &&
            homeCtrl.featuredMenus.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 56,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    homeCtrl.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: homeCtrl.loadHomeData,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }
        final selectedBranch = homeCtrl.selectedBranch;

        final isLoggedIn = appState.isLoggedIn;
        final user = isLoggedIn ? appState.user : null;

        final userName = isLoggedIn ? (user?.name.trim() ?? 'Guest') : 'Guest';
        final firstName = userName.isEmpty
            ? 'Guest'
            : userName.split(' ').first;
        final points = isLoggedIn ? (user?.loyaltyPoints ?? 0) : 0;
        final totalEarned = isLoggedIn ? (user?.totalEarnedPoints ?? 0) : 0;
        final tier = isLoggedIn
            ? (user?.membershipTier.toLowerCase() ?? 'bronze')
            : 'bronze';
        final userId = isLoggedIn ? (user?.id ?? '') : '';

        final curatedSlides = _dummyPromoSlides;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _HomeHeroSection(
                firstName: firstName,
                branchName: selectedBranch?.name ?? 'Pilih Cabang',
                points: points,
                totalEarned: totalEarned,
                tier: tier,
                userId: userId,
                onBranchTap: () => _showBranchPicker(context, homeCtrl),
                onMembershipTap: () => Get.find<MainController>().changeTab(2),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (curatedSlides.isNotEmpty) ...[
                      const _SectionHeader(
                        eyebrow: 'WEEKLY PICKS',
                        title: 'Weekly Curations',
                      ),
                      const SizedBox(height: 14),
                      _WeeklyCurationsSlider(slides: curatedSlides),
                      const SizedBox(height: 28),
                    ],
                    const _SectionHeader(
                      eyebrow: 'EXPLORE',
                      title: 'Browse Categories',
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 104,
                      child: (() {
                        final filteredCategories = homeCtrl.categories
                            .where((c) => _isAllowedHomeCategory(c.name))
                            .toList();

                        if (filteredCategories.isEmpty) {
                          return const Center(
                            child: Text(
                              'Kategori belum tersedia',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          );
                        }

                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: filteredCategories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final category = filteredCategories[index];
                            return _CategoryButton(
                              label: category.name,
                              icon: homeCtrl.iconForCategory(category.name),
                              onTap: () async {
                                await homeCtrl.selectCategory(category.id);

                                final mainCtrl = Get.find<MainController>();
                                final menuCtrl = Get.find<MenuController>();

                                menuCtrl.selectedType.value = category.id;
                                mainCtrl.changeTab(1);
                              },
                            );
                          },
                        );
                      })(),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        const Expanded(
                          child: _SectionHeader(
                            eyebrow: 'FEATURED MENU',
                            title: 'Popular Nomads',
                          ),
                        ),
                        if (homeCtrl.isRefreshingMenus.value)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSoft,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: const Text(
                              'FILTER',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (selectedBranch == null)
                      const _InfoCard(message: 'Belum ada cabang yang dipilih.')
                    else if (homeCtrl.featuredMenus.isEmpty)
                      _InfoCard(
                        message: homeCtrl.errorMessage.value.isNotEmpty
                            ? homeCtrl.errorMessage.value
                            : 'Menu unggulan belum tersedia.',
                      )
                    else
                      GridView.builder(
                        itemCount: homeCtrl.featuredMenus.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 254,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                            ),
                        itemBuilder: (context, index) {
                          final item = homeCtrl.featuredMenus[index];
                          return _MenuCard(
                            item: item,
                            qty: homeCtrl.qtyForMenu(item.id),
                            cartCtrl: cartCtrl,
                          );
                        },
                      ),
                    const SizedBox(height: 22),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showBranchPicker(BuildContext context, HomeController homeCtrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Pilih Lokasi Cabang',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...homeCtrl.branches.map((branch) {
              final isSelected = homeCtrl.selectedBranch?.id == branch.id;
              return InkWell(
                onTap: branch.isOpen
                    ? () async {
                        await homeCtrl.selectBranch(branch);
                        Navigator.pop(sheetContext);
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  color: isSelected
                      ? AppColors.secondaryLight.withValues(alpha: 0.08)
                      : Colors.transparent,
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secondaryLight.withValues(alpha: 0.18)
                              : AppColors.surfaceGrey,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              branch.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppColors.secondary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              branch.address,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: branch.isOpen
                              ? AppColors.tealLight
                              : AppColors.surfaceGrey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          branch.isOpen ? 'Buka' : 'Tutup',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: branch.isOpen
                                ? AppColors.teal
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _HomeHeroSection extends StatelessWidget {
  final String firstName;
  final String branchName;
  final int points;
  final int totalEarned;
  final String tier;
  final String userId;
  final VoidCallback onBranchTap;
  final VoidCallback onMembershipTap;

  const _HomeHeroSection({
    required this.firstName,
    required this.branchName,
    required this.points,
    required this.totalEarned,
    required this.tier,
    required this.userId,
    required this.onBranchTap,
    required this.onMembershipTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientQueue),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
          child: Column(
            children: [
              _TopHeaderCard(
                branchName: branchName,
                onBranchTap: onBranchTap,
                firstName: firstName,
              ),
              const SizedBox(height: 16),
              _MembershipCard(
                points: points,
                totalEarned: totalEarned,
                tier: tier,
                userId: userId,
                onTap: onMembershipTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;

  const _SectionHeader({required this.eyebrow, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.9,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            height: 1.05,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _TopHeaderCard extends StatelessWidget {
  final String branchName;
  final VoidCallback onBranchTap;
  final String firstName;

  const _TopHeaderCard({
    required this.branchName,
    required this.onBranchTap,
    required this.firstName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBranchTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: onBranchTap,
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT BRANCH',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.9,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    branchName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 21,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            child: ClipOval(
              child: Image.asset(
                'assets/menu_images/logo_nomad.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return Text(
                    firstName.isNotEmpty ? firstName[0].toUpperCase() : 'G',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  final int points;
  final int totalEarned;
  final String tier;
  final String userId;
  final VoidCallback onTap;

  const _MembershipCard({
    required this.points,
    required this.totalEarned,
    required this.tier,
    required this.userId,
    required this.onTap,
  });

  int? _nextTierTarget(String currentTier) {
    switch (currentTier) {
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

  String _nextTierLabel(String currentTier) {
    switch (currentTier) {
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

  Color _tierColor(String currentTier) {
    switch (currentTier) {
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

  String _memberId() {
    final safeId = userId.trim();
    if (safeId.isEmpty) return 'GUEST';
    final compact = safeId.replaceAll('-', '').toUpperCase();
    if (compact.length <= 8) return compact;
    return '${compact.substring(0, 4)}-${compact.substring(compact.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final nextTarget = _nextTierTarget(tier);
    final tierLabel = UserModel.getTierLabel(tier);
    final nextTierLabel = _nextTierLabel(tier);
    final tierColor = _tierColor(tier);

    final progress = nextTarget == null
        ? 1.0
        : (totalEarned / nextTarget).clamp(0.0, 1.0);

    final progressText = nextTarget == null
        ? 'Tier tertinggi sudah tercapai.'
        : totalEarned >= nextTarget
        ? 'Kamu sudah siap naik tier.'
        : 'Earn ${Formatters.commas(nextTarget - totalEarned)} more points to unlock more benefits.';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryDark.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MEMBERSHIP TIER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$tierLabel Nomad',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: tierColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: tierColor.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Text(
                    'ID: ${_memberId()}',
                    style: TextStyle(
                      color: tierColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    nextTarget == null
                        ? 'Membership Tertinggi'
                        : 'Progress to $nextTierLabel',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  nextTarget == null
                      ? '${Formatters.commas(totalEarned)} pts'
                      : '${Formatters.commas(totalEarned)}/${Formatters.commas(nextTarget)} pts',
                  style: TextStyle(
                    color: tierColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.surfaceGrey,
                color: tierColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              progressText,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Poin aktif: ${Formatters.commas(points)} pts',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoSlideData {
  final String title;
  final String subtitle;
  final String imageUrl;

  const _PromoSlideData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });
}

class _WeeklyCurationsSlider extends StatefulWidget {
  final List<_PromoSlideData> slides;

  const _WeeklyCurationsSlider({required this.slides});

  @override
  State<_WeeklyCurationsSlider> createState() => _WeeklyCurationsSliderState();
}

class _WeeklyCurationsSliderState extends State<_WeeklyCurationsSlider> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.90);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 188,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.slides.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final slide = widget.slides[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == widget.slides.length - 1 ? 0 : 12,
                ),
                child: _PromoImageCard(slide: slide),
              );
            },
          ),
        ),
        if (widget.slides.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.slides.length, (index) {
              final isActive = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.secondary
                      : AppColors.secondary.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _PromoImageCard extends StatelessWidget {
  final _PromoSlideData slide;

  const _PromoImageCard({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: _MenuImage(imageUrl: slide.imageUrl)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0.64),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PROMO MINGGU INI',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  slide.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    height: 1.1,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  slide.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
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

class _InfoCard extends StatelessWidget {
  final String message;

  const _InfoCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final MenuItem item;
  final int qty;
  final CartController cartCtrl;

  const _MenuCard({
    required this.item,
    required this.qty,
    required this.cartCtrl,
  });

  void _openDetail(BuildContext context) {
    if (!item.isAvailable) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MenuDetailSheet(
        controller: MenuDetailController(item: item, initialQty: 1),
      ),
    );
  }

  void _quickAdd() {
    if (!item.isAvailable) return;
    cartCtrl.addSimple(item);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.isAvailable ? () => _openDetail(context) : null,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryDark.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: AppColors.surfaceGrey,
                        child: _MenuImage(imageUrl: item.imageUrl),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.favorite_border_rounded,
                          size: 18,
                          color: item.isAvailable
                              ? AppColors.primary
                              : AppColors.textHint,
                        ),
                      ),
                    ),
                    if (!item.isAvailable)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.38),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Tidak Tersedia',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.2,
                        color: item.isAvailable
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Formatters.currency(item.price),
                      style: TextStyle(
                        fontSize: 13,
                        color: item.isAvailable
                            ? AppColors.primary
                            : AppColors.textHint,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: qty > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.tealLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$qty di cart',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.teal,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _quickAdd,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: item.isAvailable
                                  ? AppColors.secondary
                                  : AppColors.surfaceGrey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuImage extends StatelessWidget {
  final String imageUrl;

  const _MenuImage({required this.imageUrl});

  String _normalizeAssetPath(String raw) {
    final path = raw.trim();

    if (path.isEmpty) return '';

    if (path.startsWith('http')) return path;

    if (path.startsWith('assets/')) {
      return path;
    }

    if (path.startsWith('menu_images/')) {
      return 'assets/$path';
    }

    if (path.startsWith('promo/')) {
      return 'assets/$path';
    }

    return 'assets/menu_images/$path';
  }

  @override
  Widget build(BuildContext context) {
    final normalizedPath = _normalizeAssetPath(imageUrl);

    if (normalizedPath.isEmpty) {
      return const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 36,
          color: AppColors.textHint,
        ),
      );
    }

    if (normalizedPath.startsWith('http')) {
      return Image.network(
        normalizedPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.textHint,
          ),
        ),
      );
    }

    return Image.asset(
      normalizedPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 84,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 26, color: AppColors.secondary),
            ),
            const SizedBox(height: 10),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
