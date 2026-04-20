import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../user/core/constants/app_colors.dart';
import '../../../../user/core/constants/app_text_styles.dart';
import '../../../controllers/admin_branch_controller.dart';
import '../../../controllers/admin_home_controller.dart';

class AdminBranchFormScreen extends GetView<AdminBranchController> {
  const AdminBranchFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final branchId = (args?['id'] ?? '').toString();
    final isEdit = branchId.isNotEmpty;

    final homeController = Get.isRegistered<AdminHomeController>()
        ? Get.find<AdminHomeController>()
        : null;

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
                      color: Colors.white,
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
                                'FORM CABANG',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isEdit ? 'Edit Cabang' : 'Tambah Cabang',
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
                                  branchName.isEmpty
                                      ? (isEdit
                                            ? 'Edit Cabang'
                                            : 'Tambah Cabang')
                                      : branchName,
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
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
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
                  _buildTextField(
                    label: 'Nama Cabang',
                    controller: controller.nameCtrl,
                    hint: 'Contoh: Nomad Banjarmasin',
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Nama cabang wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Alamat',
                    controller: controller.addressCtrl,
                    hint: 'Masukkan alamat lengkap cabang',
                    maxLines: 4,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Alamat wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTimeField(
                    context: context,
                    label: 'Jam Buka',
                    controller: controller.openTimeCtrl,
                    icon: Icons.access_time_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildTimeField(
                    context: context,
                    label: 'Jam Tutup',
                    controller: controller.closeTimeCtrl,
                    icon: Icons.nightlight_round,
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => _StatusCard(
                      value: controller.isOpen.value,
                      onChanged: (value) => controller.isOpen.value = value,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : () => controller.saveBranch(branchId: branchId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: controller.isSubmitting.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.4,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isEdit
                                        ? 'Simpan Perubahan'
                                        : 'Simpan Cabang',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 20,
                                  ),
                                ],
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.captionBold.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.surfaceSoft,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.captionBold.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          validator: (value) {
            if ((value ?? '').trim().isEmpty) {
              return '$label wajib diisi';
            }
            return null;
          },
          onTap: () async {
            final initial = _parseTime(controller.text) ?? TimeOfDay.now();
            final picked = await showTimePicker(
              context: context,
              initialTime: initial,
            );

            if (picked != null) {
              controller.text = _formatTime(picked);
            }
          },
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: '--:--',
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            suffixIcon: const Icon(
              Icons.access_time_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.surfaceSoft,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }

  TimeOfDay? _parseTime(String value) {
    if (value.trim().isEmpty) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _StatusCard extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _StatusCard({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final accent = value ? AppColors.success : AppColors.warning;

    return Container(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: accent,
        title: Text(
          value ? 'Cabang Sedang Buka' : 'Cabang Sedang Tutup',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          value
              ? 'Cabang terlihat aktif untuk operasional'
              : 'Cabang ditandai sedang tidak melayani',
          style: AppTextStyles.bodySecondary.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
    );
  }
}
