import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/admin_branch_scope.dart';
import '../models/admin_dashboard_model.dart';

class AdminHomeRemote {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AdminDashboardModel> getDashboardSummary() async {
    final branchId = await AdminBranchScope.requireBranchId();
    final now = DateTime.now();
    final startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    ).toIso8601String();

    final pendingFuture = _supabase
        .from('orders')
        .select('id')
        .eq('branch_id', branchId)
        .eq('status', 'menunggu');

    final processingFuture = _supabase
        .from('orders')
        .select('id')
        .eq('branch_id', branchId)
        .eq('status', 'diproses');

    final selesaiFuture = _supabase
        .from('orders')
        .select('id')
        .eq('branch_id', branchId)
        .eq('status', 'selesai');

    final selesaiTodayFuture = _supabase
        .from('orders')
        .select('id, grand_total')
        .eq('branch_id', branchId)
        .eq('status', 'selesai')
        .gte('created_at', startOfDay);

    final membersFuture = _supabase
        .from('users')
        .select('id')
        .neq('role', 'admin');

    final menusFuture = _supabase
        .from('menu_items')
        .select('id')
        .eq('branch_id', branchId)
        .eq('is_available', true);

    final vouchersFuture = _supabase
        .from('vouchers')
        .select('id')
        .eq('is_active', true);

    final results = await Future.wait([
      pendingFuture,
      processingFuture,
      selesaiFuture,
      selesaiTodayFuture,
      membersFuture,
      menusFuture,
      vouchersFuture,
    ]);

    final pendingData = List<Map<String, dynamic>>.from(results[0] as List);
    final processingData = List<Map<String, dynamic>>.from(results[1] as List);
    final selesaiData = List<Map<String, dynamic>>.from(results[2] as List);
    final selesaiTodayData = List<Map<String, dynamic>>.from(results[3] as List);
    final membersData = List<Map<String, dynamic>>.from(results[4] as List);
    final menusData = List<Map<String, dynamic>>.from(results[5] as List);
    final vouchersData = List<Map<String, dynamic>>.from(results[6] as List);

    int revenue = 0;
    for (final item in selesaiTodayData) {
      revenue += ((item['grand_total'] ?? 0) as num).toInt();
    }

    return AdminDashboardModel(
      pendingOrders: pendingData.length,
      processingOrders: processingData.length,
      readyOrders: selesaiData.length,
      doneOrdersToday: selesaiTodayData.length,
      totalMembers: membersData.length,
      totalMenusAvailable: menusData.length,
      activeVouchers: vouchersData.length,
      todayRevenue: revenue,
    );
  }
}
