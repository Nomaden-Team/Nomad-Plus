import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../controllers/auth/login_controller.dart';
import '../../../core/routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          final isCompact = h < 760;

          final topAreaHeight = isCompact ? h * 0.27 : h * 0.32;
          final logoSize = isCompact ? 70.0 : 82.0;
          final titleSize = isCompact ? 20.0 : 24.0;
          final horizontalPadding = isCompact ? 22.0 : 26.0;
          final topRadius = isCompact ? 28.0 : 34.0;

          return Stack(
            children: [
              // Background utama: tetap pakai brand merah-hijau, tapi dibuat lebih cold
              Container(
                decoration: const BoxDecoration(
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
              ),

              // Gambar background bagian atas
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: topAreaHeight + 40,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/menu_images/kopi_bg.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: AppColors.gradientLoyalty,
                          ),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.secondaryDark.withOpacity(0.30),
                            AppColors.secondary.withOpacity(0.52),
                            AppColors.primaryDark.withOpacity(0.78),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                            },
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: topAreaHeight - 30,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: logoSize,
                            height: logoSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.08),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.20),
                                width: 1.1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondaryDark.withOpacity(
                                    0.22,
                                  ),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/menu_images/logo_nomad.png',
                                  width: logoSize * 0.48,
                                  height: logoSize * 0.48,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) {
                                    return const Icon(
                                      Icons.coffee_rounded,
                                      size: 34,
                                      color: Colors.white,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isCompact ? 10 : 14),
                          Text(
                            'NOMAD COFFEE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleSize,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Every Sip is a Journey',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.88),
                              fontSize: isCompact ? 12 : 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(topRadius),
                            topRight: Radius.circular(topRadius),
                          ),
                        ),
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            isCompact ? 20 : 28,
                            horizontalPadding,
                            isCompact ? 16 : 22,
                          ),
                          child: Form(
                            key: controller.formKey,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight:
                                    constraints.maxHeight - topAreaHeight - 50,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome Back',
                                    style: TextStyle(
                                      fontSize: isCompact ? 24 : 28,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.4,
                                      height: 1.05,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Masuk untuk melanjutkan pesanan dan nikmati pengalaman Nomad yang lebih personal.',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: isCompact ? 13 : 14,
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: isCompact ? 18 : 24),

                                  _sectionLabel('EMAIL'),
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
                                  SizedBox(height: isCompact ? 14 : 16),

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
                                                    ? Icons
                                                          .visibility_off_rounded
                                                    : Icons.visibility_rounded,
                                                size: 20,
                                                color: AppColors.textHint,
                                              ),
                                              onPressed:
                                                  controller.toggleObscure,
                                            ),
                                          ),
                                    ),
                                  ),

                                  SizedBox(height: isCompact ? 20 : 26),

                                  Obx(
                                    () => SizedBox(
                                      width: double.infinity,
                                      height: 54,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: controller.loading.value
                                              ? null
                                              : AppColors.gradientQueue,
                                          color: controller.loading.value
                                              ? AppColors.textHint
                                              : null,
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.secondary
                                                  .withOpacity(0.18),
                                              blurRadius: 14,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: controller.loading.value
                                              ? null
                                              : controller.login,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                          ),
                                          child: controller.loading.value
                                              ? const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2.2,
                                                      ),
                                                )
                                              : const Text(
                                                  'MASUK',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: isCompact ? 14 : 16),

                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 13,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceSoft,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.cardBorder,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.coffee_rounded,
                                          size: 18,
                                          color: AppColors.secondary,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Masuk untuk akses riwayat order, loyalty point, dan voucher personal.',
                                            style: TextStyle(
                                              fontSize: isCompact ? 11.5 : 12,
                                              height: 1.4,
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: isCompact ? 14 : 16),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Belum punya akun? ',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () =>
                                            Get.toNamed(AppRoutes.register),
                                        child: const Text(
                                          'Daftar sekarang',
                                          style: TextStyle(
                                            color: AppColors.secondary,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: isCompact ? 4 : 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: 0.8,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.textHint,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, size: 20, color: AppColors.textHint),
      filled: true,
      fillColor: AppColors.surfaceGrey,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
        borderSide: const BorderSide(color: AppColors.secondary, width: 1.25),
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
