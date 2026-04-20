import 'package:supabase_flutter/supabase_flutter.dart';

class AdminBranchScope {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<String> requireBranchId() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) {
      throw Exception('Admin belum login.');
    }

    final response = await _supabase
        .from('users')
        .select('role, branch_id')
        .eq('auth_id', authUser.id)
        .maybeSingle();

    if (response == null) {
      throw Exception('Profil admin tidak ditemukan.');
    }

    final role = (response['role'] ?? '').toString().trim().toLowerCase();
    if (role != 'admin') {
      throw Exception('Akun ini bukan admin cabang.');
    }

    final branchId = (response['branch_id'] ?? '').toString().trim();
    if (branchId.isEmpty) {
      throw Exception('Admin belum terhubung ke cabang.');
    }

    return branchId;
  }
}
