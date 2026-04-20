import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_state.dart';
import '../../core/routes/app_routes.dart';
import '../../data/datasources/order_remote.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/order_repository.dart';
import '../cart/cart_controller.dart';
import '../voucher/voucher_controller.dart';

class OrderController extends GetxController {
  final cart = Get.find<CartController>();
  final appState = Get.find<AppStateController>();

  final orderRepo = OrderRepository(OrderRemote());
  final SupabaseClient client = Supabase.instance.client;

  bool isLoading = false;
  List<OrderModel> orders = [];
  OrderModel? currentOrder;

  bool isCheckoutMode = false;
  String orderType = 'takeaway';
  String paymentMethod = 'NomadPay';

  RealtimeChannel? _channel;
  bool _lastLoginState = false;

  VoucherController get voucherController {
    if (Get.isRegistered<VoucherController>()) {
      return Get.find<VoucherController>();
    }
    return Get.put(VoucherController());
  }

  int get subtotalPreview => cart.subtotal;

  int get voucherDiscountPreview {
    return voucherController.discountAmount.value.clamp(0, subtotalPreview);
  }

  int get pointsToUse => appState.checkoutPointsToUse;

  int get maxPointsUsable {
    if (!appState.isLoggedIn) return 0;
    final maxByBalance = appState.user.loyaltyPoints;
    final maxByBusinessRule = subtotalPreview ~/ 10000;
    return maxByBalance < maxByBusinessRule ? maxByBalance : maxByBusinessRule;
  }

  int get grandTotalPreview {
    final afterVoucher = (subtotalPreview - voucherDiscountPreview).clamp(
      0,
      1 << 31,
    );
    final afterPoints = (afterVoucher - pointsToUse * 1000).clamp(0, 1 << 31);
    return afterPoints;
  }

  String? get appliedVoucherCode =>
      voucherController.appliedVoucher.value?.code;

  @override
  void onInit() {
    super.onInit();
    _lastLoginState = appState.isLoggedIn;
    appState.addListener(_handleAppStateChanged);
  }

  @override
  void onReady() {
    super.onReady();
    if (appState.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchOrders();
      });
    }
  }

  void _handleAppStateChanged() {
    final isLoggedIn = appState.isLoggedIn;
    if (isLoggedIn && !_lastLoginState) {
      _lastLoginState = true;
      fetchOrders();
    } else if (!isLoggedIn && _lastLoginState) {
      _lastLoginState = false;
      orders = [];
      currentOrder = null;
      isCheckoutMode = false;
      _channel?.unsubscribe();
      update();
    }
  }

  Future<void> fetchOrders() async {
    try {
      if (!appState.isLoggedIn) return;
      final userId = appState.user.id;
      if (userId.isEmpty) return;

      isLoading = true;
      update();

      final result = await orderRepo.getOrders(userId);
      orders = result;
    } catch (e) {
      Get.log('fetchOrders error: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  // --- REFRESH CHECKOUT (Penting untuk Status Order Screen) ---
  void refreshCheckout() {
    update();
  }

  void goToCheckout() {
    if (cart.isEmpty) {
      Get.snackbar('Keranjang kosong', 'Tambahkan menu terlebih dahulu.');
      return;
    }
    isCheckoutMode = true;
    currentOrder = null;
    orderType = 'takeaway';
    paymentMethod = 'NomadPay';
    voucherController.clearAppliedVoucher();
    appState.clearCheckoutPoints();
    update();
    Get.toNamed(AppRoutes.orderStatus);
  }

  void openExistingOrder(OrderModel order) {
    currentOrder = order;
    isCheckoutMode = false;
    update();
    if (order.status.isActive) {
      listenOrder(order.id);
    }
  }

  void setOrderType(String value) {
    orderType = value;
    update();
  }

  void setPaymentMethod(String value) {
    paymentMethod = value;
    update();
  }

  void applyPoints(int points) {
    if (!appState.isLoggedIn) {
      Get.snackbar('Login diperlukan', 'Kamu harus login dulu.');
      return;
    }
    if (voucherController.appliedVoucher.value != null) {
      Get.snackbar(
        'Tidak bisa dipakai',
        'Poin dan voucher tidak bisa digunakan bersamaan.',
      );
      return;
    }
    final validPoints = points.clamp(0, maxPointsUsable);
    appState.setCheckoutPointsToUse(validPoints);
    update();
  }

  void applyMaxPoints() => applyPoints(maxPointsUsable);

  void clearPoints() {
    appState.clearCheckoutPoints();
    update();
  }

  void listenOrder(String orderId) {
    _channel?.unsubscribe();
    _channel = client.channel('orders-$orderId');
    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: orderId,
          ),
          callback: (payload) {
            final data = payload.newRecord;
            final updatedStatus = _parseStatus(data['status']);
            if (currentOrder != null) {
              currentOrder = currentOrder!.copyWith(status: updatedStatus);
            }
            final index = orders.indexWhere((e) => e.id == orderId);
            if (index >= 0) {
              orders[index] = orders[index].copyWith(status: updatedStatus);
            }
            update();
          },
        )
        .subscribe();
  }

  OrderStatus _parseStatus(String? value) {
    switch (value) {
      case 'diproses':
        return OrderStatus.confirmed;
      case 'siap':
        return OrderStatus.ready;
      case 'selesai':
        return OrderStatus.done;
      case 'dibatalkan':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  // --- LOGIKA QUEUE (Lengkap seperti file awal) ---
  int _extractQueueNumber(dynamic rawQueue) {
    if (rawQueue == null) return 0;
    final queueString = rawQueue.toString().trim();
    if (queueString.isEmpty) return 0;

    if (queueString.contains('-')) {
      final parts = queueString.split('-');
      final numericPart = parts.isNotEmpty ? parts.last.trim() : '';
      return int.tryParse(numericPart) ?? 0;
    }
    return int.tryParse(queueString) ?? 0;
  }

  Future<String> _generateSimpleQueue(String branchId) async {
    try {
      final now = DateTime.now();
      final startToday = DateTime(
        now.year,
        now.month,
        now.day,
      ).toIso8601String();
      final startTomorrow = DateTime(
        now.year,
        now.month,
        now.day + 1,
      ).toIso8601String();

      final result = await client
          .from('orders')
          .select('queue_number')
          .eq('branch_id', branchId)
          .gte('created_at', startToday)
          .lt('created_at', startTomorrow)
          .order('created_at', ascending: false);

      final rows = (result as List?) ?? [];
      int maxQueue = 0;
      for (final row in rows) {
        final qNum = _extractQueueNumber(row['queue_number']);
        if (qNum > maxQueue) maxQueue = qNum;
      }
      return (maxQueue + 1).toString().padLeft(3, '0');
    } catch (e) {
      return '001';
    }
  }

  Future<dynamic> confirmOrder() async {
    if (isLoading) return 'Sedang memproses order...';
    if (cart.isEmpty) return 'Keranjang masih kosong.';
    if (!appState.isLoggedIn) return 'Kamu harus login dulu.';
    if (appState.selectedBranch == null) return 'Cabang belum dipilih.';

    try {
      isLoading = true;
      update();

      final branch = appState.selectedBranch!;
      final queue = await _generateSimpleQueue(branch.id);

      final subtotal = subtotalPreview;
      final discount = voucherDiscountPreview;
      final grandTotal = grandTotalPreview;

      final isUsingVoucher =
          appliedVoucherCode != null && appliedVoucherCode!.isNotEmpty;
      final isUsingPoints = pointsToUse > 0;

      final earnedPoints = (!isUsingVoucher && !isUsingPoints)
          ? appState.calculateEarnedPoints(subtotal)
          : 0;

      final order = OrderModel(
        id: '',
        userId: appState.user.id,
        queueNumber: queue,
        branchId: branch.id,
        branchName: branch.name,
        items: List<CartItem>.from(cart.cartItems),
        paymentMethod: paymentMethod,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        subtotal: subtotal,
        discountAmount: discount,
        serviceFee: 0,
        grandTotal: grandTotal,
        pointsEarned: earnedPoints,
        pointsUsed: pointsToUse,
        voucherCode: appliedVoucherCode,
        orderType: orderType,
        notes: null,
      );

      final saved = await orderRepo.createOrder(order);

      await _updateUserPoints(
        earned: order.pointsEarned,
        used: order.pointsUsed,
      );

      if (isUsingVoucher) {
        await voucherController.finalizeVoucherUsage(saved.id);
        appState.markVoucherUsed(appliedVoucherCode!);
      }

      currentOrder = saved;
      isCheckoutMode = false;
      cart.clearCart();
      voucherController.clearAppliedVoucher();
      appState.clearCheckoutPoints();

      await fetchOrders();
      listenOrder(saved.id);
      update();

      return saved;
    } on PostgrestException catch (e) {
      return _mapCheckoutDbError(e);
    } catch (e) {
      return 'Checkout gagal. Coba lagi.';
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> _updateUserPoints({
    required int earned,
    required int used,
  }) async {
    try {
      if (!appState.isLoggedIn) return;
      final userId = appState.user.id;

      final current = await client
          .from('users')
          .select('loyalty_points, total_earned_points')
          .eq('id', userId)
          .single();
      final currentPoints = (current['loyalty_points'] ?? 0) as int;
      final currentTotal = (current['total_earned_points'] ?? 0) as int;

      final newPoints = (currentPoints - used + earned).clamp(0, 1 << 31);
      final newTotal = currentTotal + earned;
      final newTier = UserModel.getTier(newTotal);

      await client
          .from('users')
          .update({
            'loyalty_points': newPoints,
            'total_earned_points': newTotal,
            'membership_tier': newTier,
          })
          .eq('id', userId);

      appState.setAuthenticatedUser(
        appState.user.copyWith(
          loyaltyPoints: newPoints,
          totalEarnedPoints: newTotal,
          membershipTier: newTier,
        ),
      );
    } catch (e) {
      Get.log('updateUserPoints error: $e');
    }
  }

  String _mapCheckoutDbError(PostgrestException e) {
    if (e.code == '42501') return 'Akses database ditolak.';
    return 'Gagal menyimpan order ke database.';
  }

  void goHome() {
    _channel?.unsubscribe();
    isCheckoutMode = false;
    voucherController.clearAppliedVoucher();
    appState.clearCheckoutPoints();
    update();
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void onClose() {
    appState.removeListener(_handleAppStateChanged);
    _channel?.unsubscribe();
    super.onClose();
  }
}
