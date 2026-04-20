import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../admin/core/routes/admin_routes.dart';
import '../../core/app_state.dart';
import '../../core/routes/app_routes.dart';
import '../../data/datasources/auth_remote.dart';
import '../../data/repositories/auth_repository.dart';

class LoginController extends GetxController {
  final AppStateController appState = Get.find<AppStateController>();
  final AuthRepository repo = AuthRepository(AuthRemote());

  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final obscure = true.obs;
  final loading = false.obs;

  @override
  void onClose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.onClose();
  }

  void toggleObscure() {
    obscure.value = !obscure.value;
  }

  Future<void> login() async {
    if (loading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    try {
      loading.value = true;

      final user = await repo.login(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      appState.setAuthenticatedUser(user);

      await Future.delayed(const Duration(milliseconds: 200));

      if (user.role.toLowerCase() == 'admin') {
        Get.offAllNamed(AdminRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (error) {
      Get.snackbar(
        'Login gagal',
        _readableError(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      loading.value = false;
    }
  }

  String _readableError(Object error) {
    final raw = error.toString().replaceFirst('Exception: ', '').trim();
    if (raw.isEmpty) {
      return 'Terjadi kesalahan saat login.';
    }
    return raw;
  }

  void loginSocial() {
    Get.snackbar(
      'Info',
      'Social login belum diimplementasikan',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
