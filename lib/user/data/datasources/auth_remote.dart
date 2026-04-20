import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/supabase_service.dart';
import '../models/user_model.dart';

class AuthRemote {
  final SupabaseClient client;

  AuthRemote({SupabaseClient? client})
    : client = client ?? SupabaseService.client;

  Session? get currentSession => client.auth.currentSession;

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phone, 'role': 'customer'},
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Register gagal. User tidak ditemukan.');
      }
    } on AuthException catch (error) {
      throw Exception(error.message);
    } catch (e) {
      throw Exception("Unknown Error: $e");
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Login gagal.');
      }

      final existing = await client
          .from('users')
          .select()
          .eq('auth_id', user.id)
          .maybeSingle();

      if (existing == null) {
        await client.from('users').insert({
          'auth_id': user.id,
          'email': email,
          'name': user.userMetadata?['name'] ?? '',
          'phone': user.userMetadata?['phone'] ?? '',
          'loyalty_points': 0,
          'total_earned_points': 0,
          'membership_tier': 'silver',
        });
      }

      return await fetchProfile(user.id);
    } on AuthException catch (error) {
      throw Exception(error.message);
    } on PostgrestException catch (error) {
      throw Exception(error.message);
    }
  }

  Future<UserModel?> getLoggedInUser() async {
    final session = client.auth.currentSession;

    if (session?.user == null) return null;

    try {
      return await fetchProfile(session!.user.id);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> fetchProfile(String authId) async {
    final data = await client
        .from('users')
        .select()
        .eq('auth_id', authId)
        .maybeSingle();

    if (data == null) {
      throw Exception('Profil user tidak ditemukan.');
    }

    return UserModel.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> logout() async {
    await client.auth.signOut();
  }
}
