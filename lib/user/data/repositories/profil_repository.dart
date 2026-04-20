import '../datasources/profil_remote.dart';
import '../models/user_model.dart';

class ProfileRepository {
  final ProfileRemote remote;

  ProfileRepository(this.remote);

  Future<UserModel?> updateProfile({
    required String userId,
    required String name,
    required String phone,
  }) {
    return remote.updateProfile(
      userId: userId,
      name: name,
      phone: phone,
    );
  }
}