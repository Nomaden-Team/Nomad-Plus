import 'package:get/get.dart';

import '../controllers/cart/cart_controller.dart';
import '../data/models/branch_model.dart';
import '../data/models/menu_item_model.dart';
import '../data/models/order_model.dart';
import '../data/models/user_model.dart';

class AppStateController extends GetxController {
  DateTime? lastRedeemDate;

  UserModel? _user;
  UserModel get user => _user!;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  // BRANCH REACTIVE
  final Rxn<Branch> selectedBranchRx = Rxn<Branch>();
  Branch? get selectedBranch => selectedBranchRx.value;
  String? get selectedBranchId => selectedBranchRx.value?.id;

  int _checkoutPointsToUse = 0;
  int get checkoutPointsToUse => _checkoutPointsToUse;

  CartController get _cartController => Get.find<CartController>();

  List<CartItem> get cartItems => _cartController.items;
  int get cartTotalItems => _cartController.totalQty;
  int get cartTotalPrice => _cartController.subtotal;

  final List<OrderModel> _orders = <OrderModel>[];
  List<OrderModel> get orders => List.unmodifiable(_orders);

  final Map<String, int> _voucherUsageByCode = <String, int>{};

  void setAuthenticatedUser(UserModel user) {
    _user = user;
    _isLoggedIn = true;
    update();
  }

  void logout() {
    _isLoggedIn = false;
    _user = null;
    selectedBranchRx.value = null;
    _checkoutPointsToUse = 0;
    _orders.clear();
    _voucherUsageByCode.clear();

    if (Get.isRegistered<CartController>()) {
      _cartController.clearCart();
    }

    update();
  }

  void setBranch(Branch branch) {
    if (selectedBranchRx.value?.id == branch.id) return;
    selectedBranchRx.value = branch;
    update();
  }

  void setDefaultBranchIfNeeded(List<Branch> branches) {
    if (selectedBranchRx.value != null) return;
    if (branches.isEmpty) return;

    selectedBranchRx.value = branches.first;
    update();
  }

  void updateProfileLocal({required String name, required String phone}) {
    if (_user == null) return;

    _user = _user!.copyWith(name: name, phone: phone);
    update();
  }

  void updateProfile({required String name, required String phone}) {
    updateProfileLocal(name: name, phone: phone);
  }

  void addCartItem(MenuItem item, int qty, String notes) {
    _cartController.addItem(item, qty, notes);
    update();
  }

  void updateCartItemQty(String entryId, int delta) {
    final current = _cartController.items.firstWhereOrNull(
      (e) => e.entryId == entryId,
    );

    if (current == null) return;

    _cartController.updateQty(entryId, current.qty + delta);
    update();
  }

  void restoreCartItem(CartItem item) {
    _cartController.addItem(item.menuItem, item.qty, item.notes);
    update();
  }

  void clearCart() {
    _cartController.clearCart();
    update();
  }

  void addOrder(OrderModel order) {
    _orders.insert(0, order);

    if (order.voucherCode != null && order.voucherCode!.trim().isNotEmpty) {
      markVoucherUsed(order.voucherCode!);
    }

    _cartController.clearCart();
    _checkoutPointsToUse = 0;
    update();
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;

    _orders[index] = _orders[index].copyWith(status: newStatus);
    update();
  }

  OrderModel? findOrder(String id) {
    return _orders.where((order) => order.id == id).firstOrNull;
  }

  int getUserVoucherUsageCount(String code) {
    return _voucherUsageByCode[code.trim().toUpperCase()] ?? 0;
  }

  void markVoucherUsed(String code) {
    final key = code.trim().toUpperCase();
    _voucherUsageByCode[key] = (_voucherUsageByCode[key] ?? 0) + 1;
    update();
  }

  void setCheckoutPointsToUse(int points) {
    if (_user == null) {
      _checkoutPointsToUse = 0;
      update();
      return;
    }

    final maxByBalance = _user!.loyaltyPoints;
    final maxByBusinessRule = cartTotalPrice ~/ 10000;
    final maxAllowed = maxByBalance < maxByBusinessRule
        ? maxByBalance
        : maxByBusinessRule;

    _checkoutPointsToUse = points.clamp(0, maxAllowed);
    update();
  }

  void clearCheckoutPoints() {
    _checkoutPointsToUse = 0;
    update();
  }

  bool canRedeemToday() {
    if (lastRedeemDate == null) return true;

    final now = DateTime.now();

    return !(lastRedeemDate!.year == now.year &&
        lastRedeemDate!.month == now.month &&
        lastRedeemDate!.day == now.day);
  }

  void markRedeemToday() {
    lastRedeemDate = DateTime.now();
  }

  void _earnPoints(int points) {
    if (_user == null || points <= 0) return;

    final newTotalEarned = _user!.totalEarnedPoints + points;
    final newBalance = _user!.loyaltyPoints + points;

    _user = _user!.copyWith(
      loyaltyPoints: newBalance,
      totalEarnedPoints: newTotalEarned,
      membershipTier: UserModel.getTier(newTotalEarned),
    );
  }

  void _deductPoints(int points) {
    if (_user == null || points <= 0) return;

    final updatedBalance = (_user!.loyaltyPoints - points).clamp(0, 1 << 31);
    _user = _user!.copyWith(loyaltyPoints: updatedBalance);
  }

  bool redeemPoints(int points) {
    if (_user == null) return false;
    if (_user!.loyaltyPoints < points) return false;

    _deductPoints(points);
    update();
    return true;
  }

  double get pointMultiplier {
    if (_user == null) return 1.0;

    switch (_user!.membershipTier) {
      case 'platinum':
        return 3.0;
      case 'gold':
        return 2.0;
      case 'silver':
        return 1.0;
      default:
        return 1.0;
    }
  }

  int calculateEarnedPoints(int subtotal) {
    if (subtotal <= 0) return 0;
    return ((subtotal / 5000) * pointMultiplier).floor();
  }

  
}

