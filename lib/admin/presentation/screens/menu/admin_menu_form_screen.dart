import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../user/core/constants/app_colors.dart';
import '../../../../user/core/constants/app_text_styles.dart';
import '../../../controllers/admin_menu_controller.dart';

class AdminMenuFormScreen extends GetView<AdminMenuController> {
  const AdminMenuFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final menuId = (args?['id'] ?? '').toString();
    final isEdit = menuId.isNotEmpty;

    return Scaffold(
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
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'Edit Menu' : 'Tambah Menu',
                          style: AppTextStyles.heading3.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEdit
                              ? 'Perbarui detail menu dengan rapi'
                              : 'Isi detail menu baru untuk ditampilkan',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.84),
                          ),
                        ),
                      ],
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
                      Icons.restaurant_menu_rounded,
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
      body: Obx(
        () => Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: controller.isUploadingImage.value
                    ? null
                    : controller.pickAndUploadImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _UploadBanner(
                      imageUrl: controller.imageUrlCtrl.text.trim(),
                    ),
                    if (controller.isUploadingImage.value)
                      Container(
                        height: 210,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.24),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Ketuk area di atas untuk mengunggah foto menu',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INFORMASI MENU',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 11,
                        letterSpacing: 1,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const _FieldLabel('Nama Menu'),
                    const SizedBox(height: 8),
                    _PrimaryTextField(
                      controller: controller.nameCtrl,
                      hintText: 'Contoh: Es Kopi Nomad',
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Nama menu wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    const _FieldLabel('Harga'),
                    const SizedBox(height: 8),
                    _PrimaryTextField(
                      controller: controller.priceCtrl,
                      hintText: 'Contoh: 18000',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      prefixText: 'Rp ',
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Harga wajib diisi';
                        }
                        if (int.tryParse(value!.trim()) == null) {
                          return 'Harga harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    const _FieldLabel('Deskripsi'),
                    const SizedBox(height: 8),
                    _PrimaryTextField(
                      controller: controller.descriptionCtrl,
                      hintText:
                          'Contoh: Minuman kopi susu creamy dengan rasa caramel',
                      maxLines: 4,
                      maxLength: 200,
                    ),
                    const SizedBox(height: 18),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel('Kategori'),
                              const SizedBox(height: 8),
                              _PrimaryDropdown<String>(
                                value:
                                    controller.selectedCategoryId.value.isEmpty
                                    ? null
                                    : controller.selectedCategoryId.value,
                                hintText: 'Pilih kategori',
                                items: controller.categoriesData
                                    .map(
                                      (category) => DropdownMenuItem<String>(
                                        value: (category['id'] ?? '')
                                            .toString(),
                                        child: Text(
                                          (category['name'] ?? '-').toString(),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    controller.selectedCategoryId.value = value;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel('Cabang'),
                              const SizedBox(height: 8),
                              _PrimaryDropdown<String>(
                                value: controller.selectedBranchId.value.isEmpty
                                    ? null
                                    : controller.selectedBranchId.value,
                                hintText: 'Pilih cabang',
                                items: controller.branchesData
                                    .map(
                                      (branch) => DropdownMenuItem<String>(
                                        value: (branch['id'] ?? '').toString(),
                                        child: Text(
                                          (branch['name'] ?? '-').toString(),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    controller.selectedBranchId.value = value;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MEDIA & STATUS',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 11,
                        letterSpacing: 1,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const _FieldLabel('URL Gambar'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controller.imageUrlCtrl,
                      readOnly: true,
                      maxLines: 2,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'URL gambar akan terisi otomatis setelah upload',
                        hintStyle: AppTextStyles.bodySecondary.copyWith(
                          fontSize: 14,
                          color: AppColors.textHint,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceSoft,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: AppColors.cardBorder,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: SwitchListTile(
                        value: controller.isAvailable.value,
                        onChanged: (value) =>
                            controller.isAvailable.value = value,
                        contentPadding: EdgeInsets.zero,
                        activeColor: Colors.white,
                        activeTrackColor: AppColors.secondary,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: const Color(0xFFE0DAD5),
                        title: Text(
                          'Menu tersedia',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          controller.isAvailable.value
                              ? 'Menu dapat ditampilkan ke pengguna'
                              : 'Menu disembunyikan sementara',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () => controller.saveMenu(menuId: menuId),
                  child: Text(
                    controller.isSubmitting.value
                        ? 'Menyimpan...'
                        : (isEdit ? 'Simpan Perubahan' : 'Tambah Menu'),
                    style: AppTextStyles.button.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
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

class _UploadBanner extends StatelessWidget {
  final String imageUrl;

  const _UploadBanner({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.isNotEmpty;

    return Container(
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryDark,
            AppColors.secondary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: hasImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _UploadBannerInner(),
                    )
                  : Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _UploadBannerInner(),
                    ),
            )
          : const _UploadBannerInner(),
    );
  }
}

class _UploadBannerInner extends StatelessWidget {
  const _UploadBannerInner();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Upload Foto Menu',
              style: AppTextStyles.heading3.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Gunakan foto yang jelas, menarik, dan sesuai produk',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.84),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryDark.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.label.copyWith(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      ),
    );
  }
}

class _PrimaryTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? maxLength;
  final String? prefixText;

  const _PrimaryTextField({
    required this.controller,
    required this.hintText,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      maxLength: maxLength,
      style: AppTextStyles.bodyMedium.copyWith(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        counterText: '',
        prefixText: prefixText,
        prefixStyle: AppTextStyles.bodyMedium.copyWith(
          fontSize: 14,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: AppTextStyles.bodySecondary.copyWith(
          color: AppColors.textHint,
          fontSize: 14,
        ),
        filled: true,
        fillColor: AppColors.surfaceSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}

class _PrimaryDropdown<T> extends StatelessWidget {
  final T? value;
  final String hintText;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _PrimaryDropdown({
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      items: items,
      onChanged: onChanged,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textSecondary,
      ),
      style: AppTextStyles.bodyMedium.copyWith(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodySecondary.copyWith(
          color: AppColors.textHint,
          fontSize: 14,
        ),
        filled: true,
        fillColor: AppColors.surfaceSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      dropdownColor: AppColors.surface,
      menuMaxHeight: 320,
    );
  }
}
