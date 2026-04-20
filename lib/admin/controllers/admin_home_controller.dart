import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/routes/admin_routes.dart';
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

  final adminMenus = const <AdminMenuItem>[
    AdminMenuItem(
      title: 'Orders',
      subtitle: 'Kelola pesanan masuk',
      route: AdminRoutes.orders,
    ),
    AdminMenuItem(
      title: 'Menus',
      subtitle: 'Kelola menu & availability',
      route: AdminRoutes.menus,
    ),
    AdminMenuItem(
      title: 'Branches',
      subtitle: 'Kelola cabang & jam operasional',
      route: AdminRoutes.branches,
    ),
    AdminMenuItem(
      title: 'Vouchers',
      subtitle: 'Kelola voucher & promo',
      route: AdminRoutes.vouchers,
    ),
  ];

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

  String formatRupiah(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }

    return 'Rp${buffer.toString().split('').reversed.join()}';
  }
}

class AdminMenuItem {
  final String title;
  final String subtitle;
  final String route;

  const AdminMenuItem({
    required this.title,
    required this.subtitle,
    required this.route,
  });
}
