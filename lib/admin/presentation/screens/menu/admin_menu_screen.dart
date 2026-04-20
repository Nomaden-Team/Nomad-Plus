import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../user/core/constants/app_colors.dart';
import '../../../../user/core/constants/app_text_styles.dart';
import '../../../controllers/admin_menu_controller.dart';
import '../../../core/routes/admin_routes.dart';
import '../../widgets/admin_drawer.dart';

class AdminMenuScreen extends GetView<AdminMenuController> {
  const AdminMenuScreen({super.key});

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
                      'Kelola Menu',
                      style: AppTextStyles.heading3.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 2,
        onPressed: () {
          controller.clearForm();
          Get.toNamed(AdminRoutes.menuForm);
        },
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: Column(
        children: [
          const SizedBox(height: 14),
          Obx(() {
            final categories = controller.categories;
            final selectedCategory = controller.selectedCategory.value;

            return SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;

                  return ChoiceChip(
                    label: Text(
                      category.toUpperCase(),
                      style: AppTextStyles.captionBold.copyWith(
                        fontSize: 11,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.cardBorder,
                      ),
                    ),
                    onSelected: (_) => controller.changeCategory(category),
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() {
              final isLoading = controller.isLoading.value;
              final menus = controller.menus;

              if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                );
              }

              if (menus.isEmpty) {
                return _EmptyMenuState(
                  onAddTap: () {
                    controller.clearForm();
                    Get.toNamed(AdminRoutes.menuForm);
                  },
                  onImportTap: () {
                    Get.snackbar(
                      'Belum tersedia',
                      'Fitur impor CSV belum bisa digunakan saat ini.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.white,
                      colorText: AppColors.textPrimary,
                      borderColor: AppColors.cardBorder,
                      borderWidth: 1,
                      margin: const EdgeInsets.all(12),
                    );
                  },
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: menus.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = menus[index];

                  final menuId = (item['id'] ?? '').toString();
                  final name = (item['name'] ?? '-').toString();
                  final price = item['price'] ?? 0;
                  final imageUrl = (item['image_url'] ?? '').toString();
                  final isAvailable = item['is_available'] == true;

                  final categoryData =
                      item['categories'] as Map<String, dynamic>?;
                  final categoryName = (categoryData?['name'] ?? '-')
                      .toString();

                  final branchData = item['branches'] as Map<String, dynamic>?;
                  final branchName = (branchData?['name'] ?? '-').toString();

                  return Container(
                    padding: const EdgeInsets.all(14),
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MenuImage(imageUrl: imageUrl),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: AppTextStyles.heading3.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Kategori: $categoryName',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Cabang: $branchName',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Harga: Rp$price',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isAvailable
                                          ? const Color(0xFFE8F8F0)
                                          : AppColors.primarySoft,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      isAvailable
                                          ? 'TERSEDIA'
                                          : 'TIDAK TERSEDIA',
                                      style: AppTextStyles.captionBold.copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: isAvailable
                                            ? AppColors.success
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  _OutlineSmallButton(
                                    label: 'Edit',
                                    onTap: () {
                                      controller.fillForm(item);
                                      Get.toNamed(
                                        AdminRoutes.menuForm,
                                        arguments: {'id': menuId},
                                      );
                                    },
                                  ),
                                  _OutlineSmallButton(
                                    label: 'Hapus',
                                    onTap: () {
                                      Get.defaultDialog(
                                        title: 'Hapus Menu?',
                                        middleText:
                                            'Menu ini akan dihapus permanen.',
                                        textConfirm: 'Hapus',
                                        textCancel: 'Batal',
                                        confirmTextColor: Colors.white,
                                        buttonColor: AppColors.primary,
                                        onConfirm: () async {
                                          final ok = await controller
                                              .deleteMenu(menuId);
                                          if (ok) {
                                            Get.back(closeOverlays: true);
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Switch(
                          value: isAvailable,
                          onChanged: (_) {
                            controller.toggleAvailability(
                              menuId: menuId,
                              currentValue: isAvailable,
                            );
                          },
                          activeColor: Colors.white,
                          activeTrackColor: AppColors.secondary,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: const Color(0xFFE0DAD5),
                        ),
                      ],
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
}

class _EmptyMenuState extends StatelessWidget {
  final VoidCallback onAddTap;
  final VoidCallback onImportTap;

  const _EmptyMenuState({required this.onAddTap, required this.onImportTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Icon(
                  Icons.restaurant_menu_rounded,
                  size: 40,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Belum ada menu',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tambahkan menu pertamamu atau impor data menu agar daftar produk mulai terisi.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary.copyWith(
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: onAddTap,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: Text(
                    'Tambah Menu Pertama',
                    style: AppTextStyles.button.copyWith(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: onImportTap,
                  icon: const Icon(Icons.file_upload_outlined),
                  label: Text(
                    'Impor CSV',
                    style: AppTextStyles.button.copyWith(fontSize: 14),
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

class _MenuImage extends StatelessWidget {
  final String imageUrl;

  const _MenuImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final rawValue = imageUrl.trim();

    if (rawValue.isEmpty) {
      return _fallback();
    }

    final isAsset = rawValue.startsWith('assets/');
    final isNetwork =
        rawValue.startsWith('http://') || rawValue.startsWith('https://');

    if (isAsset) {
      return Container(
        width: 78,
        height: 78,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surfaceSoft,
        ),
        child: Image.asset(
          rawValue,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _fallback(),
        ),
      );
    }

    if (isNetwork) {
      final safeUrl = Uri.encodeFull(rawValue);

      return Container(
        width: 78,
        height: 78,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surfaceSoft,
        ),
        child: Image.network(
          safeUrl,
          width: 78,
          height: 78,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) {
              return child;
            }
            return const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _fallback(),
        ),
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.image_outlined, color: AppColors.textHint),
    );
  }
}

class _OutlineSmallButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlineSmallButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(82, 36),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        side: const BorderSide(color: AppColors.cardBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        foregroundColor: AppColors.textPrimary,
        textStyle: AppTextStyles.captionBold.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: onTap,
      child: Text(label),
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
            active: true,
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
