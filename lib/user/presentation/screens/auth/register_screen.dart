import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../controllers/auth/register_controller.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegisterController>();
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            height: screenH * 0.34,
            decoration: const BoxDecoration(
              gradient: AppColors.gradientLoyalty,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () => Get.back(),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Create\nYour Account',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.02,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Gabung dengan Nomad Coffee dan mulai kumpulkan reward di setiap perjalanan rasa.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(22, 24, 22, 26),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel('FULL NAME'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: controller.nameCtrl,
                                validator: Validators.name,
                                textCapitalization: TextCapitalization.words,
                                decoration: _inputDecoration(
                                  hint: 'Alex Ferguson',
                                  icon: Icons.person_outline_rounded,
                                ),
                              ),
                              const SizedBox(height: 18),

                              _sectionLabel('EMAIL ADDRESS'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: controller.emailCtrl,
                                validator: Validators.email,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _inputDecoration(
                                  hint: 'hello@example.com',
                                  icon: Icons.alternate_email_rounded,
                                ),
                              ),
                              const SizedBox(height: 18),

                              _sectionLabel('PHONE NUMBER'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: controller.phoneCtrl,
                                validator: Validators.phone,
                                keyboardType: TextInputType.phone,
                                decoration: _inputDecoration(
                                  hint: '0812 3456 7890',
                                  icon: Icons.phone_outlined,
                                ),
                              ),
                              const SizedBox(height: 18),

                              _sectionLabel('PASSWORD'),
                              const SizedBox(height: 8),
                              Obx(
                                () => TextFormField(
                                  controller: controller.passCtrl,
                                  validator: Validators.password,
                                  obscureText: controller.obscure.value,
                                  decoration:
                                      _inputDecoration(
                                        hint: '••••••••',
                                        icon: Icons.lock_outline_rounded,
                                      ).copyWith(
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            controller.obscure.value
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            color: AppColors.textHint,
                                            size: 20,
                                          ),
                                          onPressed: controller.toggleObscure,
                                        ),
                                      ),
                                ),
                              ),
                              const SizedBox(height: 22),

                              Obx(
                                () => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSoft,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.cardBorder,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: Checkbox(
                                          value: controller.agreed.value,
                                          onChanged: controller.toggleAgreed,
                                          activeColor: AppColors.primary,
                                          side: const BorderSide(
                                            color: AppColors.textHint,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                              height: 1.55,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Saya setuju dengan ',
                                              ),
                                              TextSpan(
                                                text: 'Syarat Layanan',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              TextSpan(text: ' dan '),
                                              TextSpan(
                                                text: 'Kebijakan Privasi',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              Obx(
                                () => SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: controller.loading.value
                                          ? null
                                          : AppColors.gradientPrimarySoft,
                                      color: controller.loading.value
                                          ? AppColors.textHint
                                          : null,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(
                                            0.22,
                                          ),
                                          blurRadius: 14,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: controller.loading.value
                                          ? null
                                          : controller.register,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ),
                                      child: controller.loading.value
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.2,
                                              ),
                                            )
                                          : const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'CREATE ACCOUNT',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.white,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Icon(
                                                  Icons.arrow_forward_rounded,
                                                  size: 18,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 22),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Sudah punya akun? ',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Get.back(),
                                    child: const Text(
                                      'Masuk',
                                      style: TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),

                Obx(() {
                  if (!controller.loading.value) {
                    return const SizedBox.shrink();
                  }
                  return Positioned.fill(
                    child: Container(color: Colors.black.withOpacity(0.18)),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
        letterSpacing: 0.9,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: AppColors.textHint),
      filled: true,
      fillColor: AppColors.surfaceGrey,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.error, width: 1.2),
      ),
    );
  }
}
