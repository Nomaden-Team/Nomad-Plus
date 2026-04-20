import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../admin/core/routes/admin_routes.dart';
import '../../core/app_state.dart';
import '../../core/routes/app_routes.dart';
import '../../data/datasources/auth_remote.dart';
import '../../data/repositories/auth_repository.dart';

class SplashController extends GetxController {
  final AuthRepository _authRepository = AuthRepository(AuthRemote());
  final AppStateController _appState = Get.find<AppStateController>();

  @override
  void onReady() {
    super.onReady();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await Future.delayed(const Duration(milliseconds: 2600));

      if (isClosed) return;

      final session = Supabase.instance.client.auth.currentSession;

      if (session != null && session.user != null) {
        final user = await _authRepository.getLoggedInUser();

        if (user != null) {
          _appState.setAuthenticatedUser(user);

          if ((user.role).toLowerCase() == 'admin') {
            Get.offAllNamed(AdminRoutes.home);
          } else {
            Get.offAllNamed(AppRoutes.home);
          }
          return;
        }
      }

      Get.offAllNamed(AppRoutes.login);
    } catch (_) {
      if (!isClosed) {
        Get.offAllNamed(AppRoutes.login);
      }
    }
  }
}