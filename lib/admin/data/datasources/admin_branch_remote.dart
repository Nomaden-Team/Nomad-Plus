import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/admin_branch_scope.dart';
import '../models/admin_branch_model.dart';

class AdminBranchRemote {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<AdminBranchModel>> fetchBranches() async {
    final branchId = await AdminBranchScope.requireBranchId();
    final response = await _supabase
        .from('branches')
        .select()
        .eq('id', branchId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response)
        .map(AdminBranchModel.fromMap)
        .toList();
  }

  Future<void> updateBranchOpenStatus({
    required String branchId,
    required bool isOpen,
  }) async {
    final adminBranchId = await AdminBranchScope.requireBranchId();
    await _supabase
        .from('branches')
        .update({'is_open': isOpen})
        .eq('id', branchId)
        .eq('id', adminBranchId);
  }

  Future<void> saveBranch({
    String? branchId,
    required Map<String, dynamic> payload,
  }) async {
    final adminBranchId = await AdminBranchScope.requireBranchId();
    final targetBranchId = (branchId == null || branchId.isEmpty)
        ? adminBranchId
        : branchId;

    await _supabase
        .from('branches')
        .update(payload)
        .eq('id', targetBranchId)
        .eq('id', adminBranchId);
  }

  Future<void> deleteBranch(String branchId) async {
    final adminBranchId = await AdminBranchScope.requireBranchId();
    await _supabase
        .from('branches')
        .delete()
        .eq('id', branchId)
        .eq('id', adminBranchId);
  }
}
