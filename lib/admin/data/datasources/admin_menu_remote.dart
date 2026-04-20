import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/admin_branch_scope.dart';
import '../models/admin_menu_model.dart';

class AdminMenuRemote {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await _supabase.from('categories').select().order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchBranches() async {
    final branchId = await AdminBranchScope.requireBranchId();
    final response = await _supabase
        .from('branches')
        .select()
        .eq('id', branchId)
        .order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<AdminMenuModel>> fetchMenus() async {
    final branchId = await AdminBranchScope.requireBranchId();
    final response = await _supabase
        .from('menu_items')
        .select('''
          id,
          name,
          price,
          image_url,
          is_available,
          category_id,
          branch_id,
          categories(name),
          branches(name)
        ''')
        .eq('branch_id', branchId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response)
        .map(AdminMenuModel.fromMap)
        .toList();
  }

  Future<void> updateAvailability({
    required String menuId,
    required bool isAvailable,
  }) async {
    final branchId = await AdminBranchScope.requireBranchId();
    await _supabase
        .from('menu_items')
        .update({
          'is_available': isAvailable,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', menuId)
        .eq('branch_id', branchId);
  }

  Future<void> deleteMenu(String menuId) async {
    final branchId = await AdminBranchScope.requireBranchId();
    await _supabase
        .from('menu_items')
        .delete()
        .eq('id', menuId)
        .eq('branch_id', branchId);
  }

  Future<void> saveMenu({
    String? menuId,
    required Map<String, dynamic> payload,
  }) async {
    final branchId = await AdminBranchScope.requireBranchId();
    final scopedPayload = Map<String, dynamic>.from(payload)
      ..['branch_id'] = branchId;

    if (menuId == null || menuId.isEmpty) {
      await _supabase.from('menu_items').insert(scopedPayload);
      return;
    }

    await _supabase
        .from('menu_items')
        .update(scopedPayload)
        .eq('id', menuId)
        .eq('branch_id', branchId);
  }

  Future<String> uploadMenuImage({
    required Uint8List bytes,
    required String filePath,
    required String contentType,
  }) async {
    await _supabase.storage.from('menu-images').uploadBinary(
      filePath,
      bytes,
      fileOptions: FileOptions(
        upsert: true,
        contentType: contentType,
      ),
    );

    return _supabase.storage.from('menu-images').getPublicUrl(filePath);
  }
}
