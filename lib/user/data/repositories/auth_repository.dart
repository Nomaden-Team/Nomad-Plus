import '../datasources/auth_remote.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthRemote remote;

  AuthRepository(this.remote);

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) {
    return remote.register(
      email: email,
      password: password,
      name: name,
      phone: phone,
    );
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) {
    return remote.login(email: email, password: password);
  }

  Future<UserModel?> getLoggedInUser() {
    return remote.getLoggedInUser();
  }

  Future<void> logout() {
    return remote.logout();
  }
}
