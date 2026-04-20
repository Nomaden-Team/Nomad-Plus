import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/profile/profile_controller.dart';
import '../../../core/app_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;

  bool _changed = false;

  ProfileController get controller => Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>()
      : Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    final user = Get.find<AppStateController>().user;

    _nameCtrl = TextEditingController(text: user.name);
    _phoneCtrl = TextEditingController(text: user.phone);

    controller.clearMessages();

    _nameCtrl.addListener(_handleChange);
    _phoneCtrl.addListener(_handleChange);
  }

  void _handleChange() {
    final user = Get.find<AppStateController>().user;
    final hasChanged =
        _nameCtrl.text.trim() != user.name.trim() ||
        _phoneCtrl.text.trim() != user.phone.trim();

    if (_changed != hasChanged) {
      setState(() => _changed = hasChanged);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final success = await controller.updateProfile(
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
    );

    if (!mounted) return;

    if (!success) {
      Get.snackbar(
        'Gagal',
        controller.errorMessage.value.isNotEmpty
            ? controller.errorMessage.value
            : 'Profil gagal diperbarui',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: AppColors.textPrimary,
        borderColor: AppColors.cardBorder,
        borderWidth: 1,
        margin: const EdgeInsets.all(12),
        icon: const Icon(Icons.error_outline, color: AppColors.error),
      );
      return;
    }

    Get.snackbar(
      'Berhasil',
      controller.successMessage.value.isNotEmpty
          ? controller.successMessage.value
          : 'Profil berhasil diperbarui',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: AppColors.textPrimary,
      borderColor: AppColors.cardBorder,
      borderWidth: 1,
      margin: const EdgeInsets.all(12),
      icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
      duration: const Duration(seconds: 2),
    );

    setState(() => _changed = false);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AppStateController>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
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
                      'Edit Profil',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
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
                        child: Column(
                          children: [
                            Container(
                              width: 86,
                              height: 86,
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
                            const SizedBox(height: 14),
                            Text(
                              user.email,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.84),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Perbarui nama dan nomor HP agar akunmu tetap up to date.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 12,
                                height: 1.45,
                                color: Colors.white.withValues(alpha: 0.84),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'INFORMASI PRIBADI',
                              style: AppTextStyles.label.copyWith(
                                fontSize: 11,
                                letterSpacing: 1,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _buildField(
                              label: 'Nama Lengkap',
                              ctrl: _nameCtrl,
                              hint: 'Masukkan nama lengkap',
                              validator: Validators.name,
                              prefixIcon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              label: 'Nomor HP',
                              ctrl: _phoneCtrl,
                              hint: '08xxxxxxxxxx',
                              keyboard: TextInputType.phone,
                              validator: Validators.phone,
                              prefixIcon: Icons.phone_outlined,
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
                              'ALAMAT EMAIL',
                              style: AppTextStyles.label.copyWith(
                                fontSize: 11,
                                letterSpacing: 1,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSoft,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.lock_outline_rounded,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      user.email,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Email tidak dapat diubah.',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 12,
                                color: AppColors.textHint,
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
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              color: AppColors.background,
              child: Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (controller.isLoading.value || !_changed)
                        ? null
                        : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      disabledBackgroundColor: AppColors.primary.withValues(
                        alpha: 0.45,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Simpan Perubahan',
                            style: AppTextStyles.button.copyWith(fontSize: 16),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController ctrl,
    required String hint,
    IconData? prefixIcon,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.captionBold.copyWith(
            fontSize: 12,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboard,
          validator: validator,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 18, color: AppColors.textSecondary),
          ),
        ),
      ],
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
