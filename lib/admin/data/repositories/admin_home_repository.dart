import '../datasources/admin_home_remote.dart';
import '../models/admin_dashboard_model.dart';

class AdminHomeRepository {
  final AdminHomeRemote remote;

  AdminHomeRepository(this.remote);

  Future<AdminDashboardModel> getDashboardSummary() {
    return remote.getDashboardSummary();
  }
}