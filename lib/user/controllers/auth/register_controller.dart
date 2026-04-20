import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../data/datasources/auth_remote.dart';
import '../../data/repositories/auth_repository.dart';

class RegisterController extends GetxController {
  final AuthRepository repo = AuthRepository(AuthRemote());

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final agreed = false.obs;
  final loading = false.obs;
  final obscure = true.obs;

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
    super.onClose();
  }

  void toggleObscure() {
    obscure.value = !obscure.value;
  }

  void toggleAgreed(bool? value) {
    agreed.value = value ?? false;
  }

  Future<void> register() async {
    if (loading.value) return;

    if (!(formKey.currentState?.validate() ?? false)) return;

    if (!agreed.value) {
      Get.snackbar(
        'Register gagal',
        'Setujui Terms terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      loading.value = true;

      await repo.register(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
      );

      Get.snackbar(
        'Berhasil',
        'Register berhasil. Silakan login.',
        snackPosition: SnackPosition.BOTTOM,
      );

      // 🔥 FIX: tunggu frame selesai render, bukan delay waktu
      await Future.microtask(() {});

      if (!Get.isRegistered<RegisterController>()) return;

      Get.offAllNamed(AppRoutes.login);
    } catch (error) {
      Get.snackbar(
        'Register gagal',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      loading.value = false;
    }
  }
}
