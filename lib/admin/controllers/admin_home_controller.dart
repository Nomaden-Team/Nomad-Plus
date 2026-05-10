import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/admin_dashboard_model.dart';
import '../data/repositories/admin_home_repository.dart';

class AdminHomeController extends GetxController {
  final AdminHomeRepository repository;

  AdminHomeController(this.repository);

  final SupabaseClient _supabase = Supabase.instance.client;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxInt pendingOrders = 0.obs;
  final RxInt processingOrders = 0.obs;
  final RxInt readyOrders = 0.obs;
  final RxInt doneOrdersToday = 0.obs;
  final RxInt totalMenusAvailable = 0.obs;
  final RxInt activeVouchers = 0.obs;
  final RxInt todayRevenue = 0.obs;
  final RxString branchName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await Future.wait([loadDashboard(), loadAdminProfile()]);
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final AdminDashboardModel data = await repository.getDashboardSummary();

      pendingOrders.value = data.pendingOrders;
      processingOrders.value = data.processingOrders;
      readyOrders.value = data.readyOrders;
      doneOrdersToday.value = data.doneOrdersToday;
      totalMenusAvailable.value = data.totalMenusAvailable;
      activeVouchers.value = data.activeVouchers;
      todayRevenue.value = data.todayRevenue;
    } catch (e) {
      errorMessage.value = 'Dashboard belum bisa dimuat. Coba refresh lagi.';
      Get.log('AdminHomeController.loadDashboard error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAdminProfile() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        branchName.value = '';
        return;
      }

      final data = await _supabase
          .from('users')
          .select('branch_id, branches(name)')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (data == null) {
        branchName.value = '';
        return;
      }

      final branchData = data['branches'];

      if (branchData is Map<String, dynamic>) {
        branchName.value = (branchData['name'] ?? '').toString();
      } else {
        branchName.value = '';
      }
    } catch (e) {
      branchName.value = '';
      Get.log('AdminHomeController.loadAdminProfile error: $e');
    }
  }

  void openMenu(String route) {
    Get.toNamed(route);
  }
}
