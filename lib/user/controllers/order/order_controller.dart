import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../data/datasources/order_remote.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/order_repository.dart';
import '../cart/cart_controller.dart';
import '../home/main_controller.dart';
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
  RealtimeChannel? _ordersRealtimeChannel;
  bool _lastLoginState = false;

  final Set<String> _shownLoyaltyRewardOrderIds = <String>{};
  final Set<String> _syncedAcceptedPaymentOrderIds = <String>{};
  final Set<String> _appliedAcceptedPaymentOrderIds = <String>{};

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

  String? get appliedVoucherCode {
    return voucherController.appliedVoucher.value?.code;
  }

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
        listenUserOrdersRealtime();
      });
    }
  }

  void _handleAppStateChanged() {
    final isLoggedIn = appState.isLoggedIn;

    if (isLoggedIn && !_lastLoginState) {
      _lastLoginState = true;
      fetchOrders();
      listenUserOrdersRealtime();
      return;
    }

    if (!isLoggedIn && _lastLoginState) {
      _lastLoginState = false;

      orders = [];
      currentOrder = null;
      isCheckoutMode = false;

      _channel?.unsubscribe();
      _ordersRealtimeChannel?.unsubscribe();

      _shownLoyaltyRewardOrderIds.clear();
      _syncedAcceptedPaymentOrderIds.clear();
      _appliedAcceptedPaymentOrderIds.clear();

      update();
    }
  }

  Future<void> fetchOrders() async {
    try {
      if (!appState.isLoggedIn) {
        print('=== fetchOrders: user belum login');
        return;
      }

      final userId = appState.user.id;
      print('=== fetchOrders userId: $userId');
      if (userId.trim().isEmpty) {
        print('=== fetchOrders: userId kosong');
        return;
      }

      isLoading = true;
      update();

      final result = await orderRepo.getOrders(userId);
      print('=== fetchOrders result: ${result.length} orders');
      orders = result;
    } catch (e) {
      print('=== fetchOrders ERROR: $e');
      Get.log('fetchOrders error: $e');
    } finally {
      isLoading = false;
      update();
    }
  }
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

  void applyMaxPoints() {
    applyPoints(maxPointsUsable);
  }

  void clearPoints() {
    appState.clearCheckoutPoints();
    update();
  }

  void listenOrder(String orderId) {
    if (orderId.trim().isEmpty) return;

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
            unawaited(_handleOrderRealtimePayload(payload.newRecord));
          },
        )
        .subscribe();
  }

  void listenUserOrdersRealtime() {
    if (!appState.isLoggedIn) return;

    final userId = appState.user.id;
    if (userId.trim().isEmpty) return;

    _ordersRealtimeChannel?.unsubscribe();
    _ordersRealtimeChannel = client.channel('user-orders-$userId');

    _ordersRealtimeChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            unawaited(_handleOrderRealtimePayload(payload.newRecord));
          },
        )
        .subscribe();
  }

  Future<void> _handleOrderRealtimePayload(Map<String, dynamic> data) async {
    final orderId = (data['id'] ?? '').toString();
    if (orderId.trim().isEmpty) return;

    final payloadUserId = (data['user_id'] ?? '').toString();
    if (payloadUserId.isNotEmpty && payloadUserId != appState.user.id) {
      return;
    }

    final updatedStatus = _parseStatus(data['status']?.toString());

    _updateLocalOrderStatus(orderId: orderId, status: updatedStatus);

    update();

    final isPaymentAccepted = updatedStatus == OrderStatus.confirmed;
    final isOrderDone = updatedStatus == OrderStatus.done;

    if ((isPaymentAccepted || isOrderDone) &&
        !_syncedAcceptedPaymentOrderIds.contains(orderId)) {
      _syncedAcceptedPaymentOrderIds.add(orderId);

      final pointsEarned = _toInt(data['points_earned']);
      final pointsUsed = _toInt(data['points_used']);

      final applied = await _applyAcceptedOrderLoyaltyOnUserSide(
        orderId: orderId,
        pointsEarned: pointsEarned,
        pointsUsed: pointsUsed,
      );

      await _syncUserPointsFromRemote();

      if (applied && pointsEarned > 0 && pointsUsed <= 0) {
        _showLoyaltyRewardDialogIfNeeded(
          orderId: orderId,
          pointsEarned: pointsEarned,
        );
      }
    }


    await fetchOrders();
  }

  Future<bool> _applyAcceptedOrderLoyaltyOnUserSide({
    required String orderId,
    required int pointsEarned,
    required int pointsUsed,
  }) async {
    try {
      if (!appState.isLoggedIn) return false;
      if (_appliedAcceptedPaymentOrderIds.contains(orderId)) return false;

      if (pointsEarned <= 0 && pointsUsed <= 0) return false;

      _appliedAcceptedPaymentOrderIds.add(orderId);

      final response = await client
          .from('users')
          .select('loyalty_points, total_earned_points')
          .eq('id', appState.user.id)
          .single();

      final currentPoints = _toInt(response['loyalty_points']);
      final currentTotalEarned = _toInt(response['total_earned_points']);

      final usedToApply = pointsUsed > 0 ? pointsUsed : 0;

      // Jika user memakai poin, reward tidak diberikan.
      final earnedToApply = pointsUsed <= 0 && pointsEarned > 0
          ? pointsEarned
          : 0;

      final newPoints = (currentPoints - usedToApply + earnedToApply)
          .clamp(0, 1 << 31)
          .toInt();

      final newTotalEarned = currentTotalEarned + earnedToApply;
      final newTier = UserModel.getTier(newTotalEarned);

      final updatedUser = await client
          .from('users')
          .update({
            'loyalty_points': newPoints,
            'total_earned_points': newTotalEarned,
            'membership_tier': newTier,
          })
          .eq('id', appState.user.id)
          .select('loyalty_points, total_earned_points, membership_tier')
          .single();

      final savedPoints = _toInt(updatedUser['loyalty_points']);
      final savedTotalEarned = _toInt(updatedUser['total_earned_points']);
      final savedTier = (updatedUser['membership_tier'] ?? newTier).toString();

      appState.setAuthenticatedUser(
        appState.user.copyWith(
          loyaltyPoints: savedPoints,
          totalEarnedPoints: savedTotalEarned,
          membershipTier: savedTier,
        ),
      );

      update();
      return true;
    } catch (e) {
      _appliedAcceptedPaymentOrderIds.remove(orderId);
      _syncedAcceptedPaymentOrderIds.remove(orderId);
      Get.log('applyAcceptedOrderLoyaltyOnUserSide error: $e');
      return false;
    }
  }

  void _updateLocalOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) {
    if (currentOrder?.id == orderId) {
      currentOrder = currentOrder!.copyWith(status: status);
    }

    final index = orders.indexWhere((order) => order.id == orderId);
    if (index >= 0) {
      orders[index] = orders[index].copyWith(status: status);
    }
  }

  Future<void> _syncUserPointsFromRemote() async {
    try {
      if (!appState.isLoggedIn) return;

      final response = await client
          .from('users')
          .select('loyalty_points, total_earned_points, membership_tier')
          .eq('id', appState.user.id)
          .single();

      final loyaltyPoints = _toInt(response['loyalty_points']);
      final totalEarnedPoints = _toInt(response['total_earned_points']);
      final membershipTier = (response['membership_tier'] ?? '').toString();

      appState.setAuthenticatedUser(
        appState.user.copyWith(
          loyaltyPoints: loyaltyPoints,
          totalEarnedPoints: totalEarnedPoints,
          membershipTier: membershipTier,
        ),
      );

      update();
    } catch (e) {
      Get.log('syncUserPointsFromRemote error: $e');
    }
  }

  void _showLoyaltyRewardDialogIfNeeded({
    required String orderId,
    required int pointsEarned,
  }) {
    if (pointsEarned <= 0) return;
    if (_shownLoyaltyRewardOrderIds.contains(orderId)) return;

    if (Get.isDialogOpen == true) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!isClosed) {
          _showLoyaltyRewardDialogIfNeeded(
            orderId: orderId,
            pointsEarned: pointsEarned,
          );
        }
      });
      return;
    }

    _shownLoyaltyRewardOrderIds.add(orderId);

    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryDark.withValues(alpha: 0.06),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientQueue,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28),
                            ),
                          ),
                          child: const Icon(
                            Icons.workspace_premium_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Poin Loyalty Didapat',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.heading2.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pembayaran sudah diterima kasir',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Reward',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '+$pointsEarned poin',
                                style: AppTextStyles.heading2.copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.stars_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'POINT REWARD',
                                    style: AppTextStyles.label.copyWith(
                                      fontSize: 10,
                                      letterSpacing: 0.9,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '+$pointsEarned poin',
                                    style: AppTextStyles.heading3.copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Poin loyalty kamu sudah diperbarui dan bisa digunakan untuk transaksi berikutnya.',
                                    style: AppTextStyles.bodySecondary.copyWith(
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Poin ini sudah masuk ke akunmu dan bisa digunakan untuk transaksi berikutnya.',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: Get.back,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            'Oke',
                            style: AppTextStyles.button.copyWith(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        if (qNum > maxQueue) {
          maxQueue = qNum;
        }
      }

      return (maxQueue + 1).toString().padLeft(3, '0');
    } catch (_) {
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

      final isUsingVoucher =
          appliedVoucherCode != null && appliedVoucherCode!.trim().isNotEmpty;

      if (isUsingVoucher) {
        final voucherValidationMessage = await voucherController
            .validateAppliedVoucherForCheckout();

        if (voucherValidationMessage != null) {
          return voucherValidationMessage;
        }
      }

      final branch = appState.selectedBranch!;
      final queue = await _generateSimpleQueue(branch.id);

      final subtotal = subtotalPreview;
      final discount = voucherDiscountPreview;
      final grandTotal = grandTotalPreview;

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

      if (isUsingVoucher) {
        final usageSaved = await voucherController.finalizeVoucherUsage(
          saved.id,
        );

        if (!usageSaved) {
          Get.log(
            'Voucher usage belum berhasil disimpan untuk order ${saved.id}',
          );
        }
      }

      currentOrder = saved;

      await fetchOrders();
      listenOrder(saved.id);
      listenUserOrdersRealtime();

      update();

      return saved;
    } on PostgrestException catch (e) {
      return _mapCheckoutDbError(e);
    } catch (e) {
      Get.log('confirmOrder error: $e');
      return 'Checkout gagal. Coba lagi.';
    } finally {
      isLoading = false;
      update();
    }
  }

  void finishCheckoutAndOpenOrder(OrderModel order) {
    currentOrder = order;
    isCheckoutMode = false;

    cart.clearCart();
    voucherController.clearAppliedVoucher();
    appState.clearCheckoutPoints();

    listenOrder(order.id);
    listenUserOrdersRealtime();

    update();
  }

  void finishCheckoutAndGoHome() {
    cart.clearCart();
    voucherController.clearAppliedVoucher();
    appState.clearCheckoutPoints();

    goHome();
  }

  void handleOrderStatusBack(OrderModel order) {
    if (order.status == OrderStatus.pending) {
      Get.back();
      return;
    }

    goHome();
  }

  String _mapCheckoutDbError(PostgrestException e) {
    if (e.code == '42501') return 'Akses database ditolak.';
    return 'Gagal menyimpan order ke database.';
  }

  void goHome() {
    _channel?.unsubscribe();

    isCheckoutMode = false;
    currentOrder = null;

    voucherController.clearAppliedVoucher();
    appState.clearCheckoutPoints();

    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().changeTab(0);
    }

    update();

    Get.offAllNamed(AppRoutes.home);
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  @override
  void onClose() {
    appState.removeListener(_handleAppStateChanged);
    _channel?.unsubscribe();
    _ordersRealtimeChannel?.unsubscribe();
    super.onClose();
  }

  Future<void> refreshOrdersAndCurrentOrder() async {
    final activeOrderId = currentOrder?.id;

    await fetchOrders();

    if (activeOrderId != null && activeOrderId.trim().isNotEmpty) {
      final index = orders.indexWhere((order) => order.id == activeOrderId);

      if (index >= 0) {
        currentOrder = orders[index];

        if (currentOrder!.status.isActive) {
          listenOrder(currentOrder!.id);
        }
      }
    }

    update();
  }

  Future<void> refreshCurrentUserData() async {
    await _syncUserPointsFromRemote();
  }
}
