import '../../core/services/supabase_service.dart';
import '../models/branch_model.dart';

class BranchRemote {
  Future<List<Branch>> getBranches() async {
    final response = await SupabaseService.client
        .from('branches')
        .select()
        .order('name');

    return (response as List)
        .map((item) => Branch.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }
}