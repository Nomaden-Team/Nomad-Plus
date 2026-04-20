import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admin_voucher_model.dart';

class AdminVoucherRemote {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> _getAdminProfile() async {
    final currentUser = _supabase.auth.currentUser;

    if (currentUser == null) {
      throw Exception('User belum login.');
    }

    final response = await _supabase
        .from('users')
        .select('id, auth_id, branch_id, role')
        .eq('auth_id', currentUser.id)
        .maybeSingle();

    if (response == null) {
      throw Exception('Data user admin tidak ditemukan di tabel users.');
    }

    final userId = (response['id'] ?? '').toString();
    final branchId = (response['branch_id'] ?? '').toString();
    final role = (response['role'] ?? '').toString().toLowerCase();

    if (userId.isEmpty) {
      throw Exception('ID user admin tidak ditemukan.');
    }

    if (branchId.isEmpty) {
      throw Exception('Admin belum terhubung ke branch_id.');
    }

    final isAdminLike =
        role == 'admin' ||
        role == 'super_admin' ||
        role == 'branch_admin' ||
        role.contains('admin');

    if (!isAdminLike) {
      throw Exception('Role user ini bukan admin. Role saat ini: $role');
    }

    return {'user_id': userId, 'branch_id': branchId, 'role': role};
  }

  Future<List<AdminVoucherModel>> fetchVouchers() async {
    final profile = await _getAdminProfile();
    final branchId = profile['branch_id'] as String;

    final response = await _supabase
        .from('vouchers')
        .select()
        .eq('branch_id', branchId);

    final rows = List<Map<String, dynamic>>.from(response);
    return rows.map((row) => AdminVoucherModel.fromMap(row)).toList();
  }

  Future<void> updateVoucherStatus({
    required String voucherId,
    required bool isActive,
  }) async {
    final profile = await _getAdminProfile();
    final branchId = profile['branch_id'] as String;

    await _supabase
        .from('vouchers')
        .update({'is_active': isActive})
        .eq('id', voucherId)
        .eq('branch_id', branchId);
  }

  Future<void> saveVoucher({
    String? voucherId,
    required Map<String, dynamic> payload,
  }) async {
    final profile = await _getAdminProfile();
    final branchId = profile['branch_id'] as String;
    final userId = profile['user_id'] as String;

    final safePayload = <String, dynamic>{
      'name': (payload['name'] ?? '').toString().trim(),
      'code': (payload['code'] ?? '').toString().trim().toUpperCase(),
      'type': _normalizeDbType(payload['type']),
      'discount_value': _toInt(payload['discount_value']),
      'max_discount': _toNullableInt(payload['max_discount']),
      'min_order_value': _toInt(payload['min_order_value']),
      'usage_limit': _toNullableInt(payload['usage_limit']),
      'usage_per_user': _toNullableInt(payload['usage_per_user']),
      'start_date': _normalizeDate(payload['start_date']),
      'expiry_date': _normalizeDate(payload['expiry_date']),
      'is_active': payload['is_active'] == true,
      'branch_id': branchId,
    };

    if (voucherId == null || voucherId.isEmpty) {
      await _supabase.from('vouchers').insert({
        ...safePayload,
        'created_by': userId,
        'used_count': _toInt(payload['used_count']),
      });
      return;
    }

    await _supabase
        .from('vouchers')
        .update(safePayload)
        .eq('id', voucherId)
        .eq('branch_id', branchId);
  }

  Future<void> deleteVoucher(String voucherId) async {
    final profile = await _getAdminProfile();
    final branchId = profile['branch_id'] as String;

    await _supabase
        .from('vouchers')
        .delete()
        .eq('id', voucherId)
        .eq('branch_id', branchId);
  }

  String _normalizeDbType(dynamic value) {
    final raw = (value ?? '').toString().trim().toLowerCase();
    if (raw == 'percent' || raw == 'percentage') return 'percentage';
    return 'fixed';
  }

  String _normalizeDate(dynamic value) {
    final raw = (value ?? '').toString().trim();
    if (raw.isEmpty) return '';
    if (raw.contains('T')) return raw.split('T').first;
    if (raw.contains(' ')) return raw.split(' ').first;
    return raw;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value.toString().trim();
    if (text.isEmpty) return 0;

    return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? 0;
  }

  int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value.toString().trim();
    if (text.isEmpty) return null;

    return int.tryParse(text) ?? double.tryParse(text)?.toInt();
  }
}
