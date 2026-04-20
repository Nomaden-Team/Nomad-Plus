import '../../core/services/supabase_service.dart';
import '../models/user_model.dart';

class ProfileRemote {
  Future<UserModel?> updateProfile({
    required String userId,
    required String name,
    required String phone,
  }) async {
    final response = await SupabaseService.client
        .from('users')
        .update({
          'name': name,
          'phone': phone,
        })
        .eq('id', userId)
        .select()
        .maybeSingle();

    if (response == null) return null;

    return UserModel.fromMap(response);
  }
}