import '../datasources/admin_branch_remote.dart';
import '../models/admin_branch_model.dart';

class AdminBranchRepository {
  final AdminBranchRemote remote;

  AdminBranchRepository(this.remote);

  Future<List<AdminBranchModel>> fetchBranches() => remote.fetchBranches();

  Future<void> updateBranchOpenStatus({
    required String branchId,
    required bool isOpen,
  }) => remote.updateBranchOpenStatus(branchId: branchId, isOpen: isOpen);

  Future<void> saveBranch({
    String? branchId,
    required Map<String, dynamic> payload,
  }) => remote.saveBranch(branchId: branchId, payload: payload);

  Future<void> deleteBranch(String branchId) => remote.deleteBranch(branchId);
}
