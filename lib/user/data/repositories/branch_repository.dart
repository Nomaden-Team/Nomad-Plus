import '../datasources/branch_remote.dart';
import '../models/branch_model.dart';

class BranchRepository {
  final BranchRemote remote;

  BranchRepository(this.remote);

  Future<List<Branch>> getBranches() {
    return remote.getBranches();
  }
}