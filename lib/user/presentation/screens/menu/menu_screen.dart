import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../../../controllers/menu/menu_controller.dart';
import '../../../controllers/cart/cart_controller.dart';
import '../../../controllers/menu/menu_detail_controller.dart';
import '../../../core/app_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/menu_item_model.dart';
import '../menu/menu_detail_sheet.dart';

bool _isAllowedMenuCategory(String name) {
  final normalized = name.trim().toLowerCase();
  return normalized == 'drink' ||
      normalized == 'snack' ||
      normalized == 'food' ||
      normalized == 'dessert';
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MenuController>();
    final appState = Get.find<AppStateController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Obx(
            () => _Header(
              controller: controller,
              currentBranchName:
                  appState.selectedBranch?.name ?? 'Belum pilih cabang',
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _CategorySidebar(controller: controller),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.secondary,
                        ),
                      );
                    }

                    if (controller.errorMessage.value.isNotEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Text(
                              controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    if (appState.selectedBranch == null) {
                      return const _EmptyBranchState();
                    }

                    if (controller.menus.isEmpty) {
                      return const _EmptyMenuState();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 12, 16, 22),
                      itemCount: controller.menus.length,
                      itemBuilder: (_, i) {
                        final item = controller.menus[i];

                        return GetBuilder<CartController>(
                          builder: (cartLogic) {
                            final qty = cartLogic.qtyForMenu(item.id);
                            return _MenuItemCard(
                              item: item,
                              qty: qty,
                              cart: cartLogic,
                            );
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final MenuController controller;
  final String currentBranchName;

  const _Header({required this.controller, required this.currentBranchName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientQueue),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.location_on_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CURRENT BRANCH',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: Colors.white.withValues(alpha: 0.72),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  currentBranchName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                "NOMAD MENU",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Cari minuman dan makanan favoritmu dengan cepat.",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                child: TextField(
                  onChanged: (v) => controller.searchQuery.value = v,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: "Search beverages or snacks...",
                    hintStyle: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.70),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.darkCard.withValues(alpha: 0.72),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySidebar extends StatelessWidget {
  final MenuController controller;
  const _CategorySidebar({required this.controller});

  IconData _getIconData(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'local_cafe':
        return Icons.local_cafe_rounded;
      case 'emoji_food_beverage':
        return Icons.emoji_food_beverage_rounded;
      case 'fastfood':
        return Icons.fastfood_rounded;
      case 'dinner_dining':
        return Icons.dinner_dining_rounded;
      case 'local_drink':
        return Icons.local_drink_rounded;
      case 'menu_book':
        return Icons.grid_view_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: Obx(() {
        final filteredCategories = controller.categories
            .where((c) => _isAllowedMenuCategory(c.name))
            .toList();

        final allCategory = Category(id: 'all', name: 'ALL', icon: 'menu_book');

        final displayCategories = <Category>[
          allCategory,
          ...filteredCategories,
        ];

        if (displayCategories.isEmpty) {
          return const SizedBox.shrink();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(8, 14, 4, 14),
          itemCount: displayCategories.length,
          itemBuilder: (_, i) {
            final category = displayCategories[i];
            final categoryId = category.id.toString();

            return Obx(() {
              final isSelected = controller.selectedType.value == categoryId;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    controller.selectedType.value = categoryId;
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeInOut,
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secondaryLight.withValues(alpha: 0.22)
                              : AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secondary.withValues(alpha: 0.16)
                                : AppColors.cardBorder,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          _getIconData(category.icon),
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.textHint,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          category.name.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          },
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
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryDark.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.store_mall_directory_outlined,
                  size: 34,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Pilih cabang terlebih dulu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Menu akan muncul setelah kamu memilih cabang aktif. Buka halaman Home lalu pilih branch yang tersedia.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMenuState extends StatelessWidget {
  const _EmptyMenuState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 34,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Menu tidak ditemukan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih cabang terlebih dulu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final int qty;
  final CartController cart;

  const _MenuItemCard({
    required this.item,
    required this.qty,
    required this.cart,
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

  void _quickAdd(BuildContext context) {
    if (!item.isAvailable) return;
    cart.addSimple(item);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 340;
        final double imageWidth = isCompact ? 82 : 96;
        final double imageHeight = isCompact ? 92 : 104;
        final double rightActionSpace = isCompact ? 40 : 52;

        return InkWell(
          onTap: item.isAvailable ? () => _openDetail(context) : null,
          borderRadius: BorderRadius.circular(26),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryDark.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: rightActionSpace),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          width: imageWidth,
                          height: imageHeight,
                          color: AppColors.surfaceGrey,
                          child: _MenuImage(imageUrl: item.imageUrl),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: imageHeight),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.heading3.copyWith(
                                  fontSize: isCompact ? 14 : 16,
                                  height: 1.15,
                                  color: item.isAvailable
                                      ? AppColors.textPrimary
                                      : AppColors.textHint,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                                maxLines: isCompact ? 2 : 3,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: isCompact ? 10.5 : 11,
                                  height: 1.35,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                Formatters.currency(item.price),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.price.copyWith(
                                  color: item.isAvailable
                                      ? AppColors.primary
                                      : AppColors.textHint,
                                  fontSize: isCompact ? 14 : 15,
                                ),
                              ),
                              if (qty > 0) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.tealLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$qty di cart',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.teal,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: GestureDetector(
                    onTap: item.isAvailable ? () => _quickAdd(context) : null,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: item.isAvailable
                            ? const LinearGradient(
                                colors: [
                                  AppColors.secondaryDark,
                                  AppColors.secondary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: item.isAvailable ? null : AppColors.surfaceGrey,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: item.isAvailable
                            ? Colors.white
                            : AppColors.textHint,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                if (!item.isAvailable)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Sold Out",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
      return Container(
        color: AppColors.surfaceGrey,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.textHint,
        ),
      );
    }

    if (normalizedPath.startsWith('http')) {
      return Image.network(
        normalizedPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.surfaceGrey,
          child: const Icon(
            Icons.broken_image_outlined,
            color: AppColors.textHint,
          ),
        ),
      );
    }

    return Image.asset(
      normalizedPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppColors.surfaceGrey,
        child: const Icon(
          Icons.broken_image_outlined,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}
