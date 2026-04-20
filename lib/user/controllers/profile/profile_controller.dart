import 'package:get/get.dart';

import '../../core/app_state.dart';
import '../../data/datasources/profil_remote.dart';
import '../../data/repositories/profil_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repository = ProfileRepository(ProfileRemote());

  final AppStateController appState = Get.find<AppStateController>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
  }) async {
    try {
      isLoading.value = true;
      clearMessages();

      final user = appState.user;

      if (name.trim().isEmpty) {
        errorMessage.value = 'Nama tidak boleh kosong';
        return false;
      }

      if (phone.trim().isEmpty) {
        errorMessage.value = 'Nomor HP tidak boleh kosong';
        return false;
      }

      final updatedUser = await _repository.updateProfile(
        userId: user.id,
        name: name.trim(),
        phone: phone.trim(),
      );

      if (updatedUser == null) {
        errorMessage.value = 'Gagal memperbarui profil';
        return false;
      }

      appState.setAuthenticatedUser(updatedUser);
      successMessage.value = 'Profil berhasil diperbarui';
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
