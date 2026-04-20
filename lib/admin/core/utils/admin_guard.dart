import 'package:get/get.dart';

import '../../../user/core/app_state.dart';

class AdminGuard {
  static bool isAdmin() {
    if (!Get.isRegistered<AppStateController>()) return false;

    final appState = Get.find<AppStateController>();

    if (!appState.isLoggedIn) return false;

    return appState.user.role.toLowerCase() == 'admin';
  }
}