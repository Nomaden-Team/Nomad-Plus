  import 'menu_item_model.dart';

  enum OrderStatus { pending, confirmed, ready, done, cancelled }

  extension OrderStatusX on OrderStatus {
    bool get isActive {
      return this == OrderStatus.pending ||
          this == OrderStatus.confirmed ||
          this == OrderStatus.ready;
    }
  }

  class OrderModel {
    final String id;
    final String userId;
    final String queueNumber;
    final String branchId;
    final String branchName;
    final List<CartItem> items;
    final String paymentMethod;
    final OrderStatus status;
    final DateTime createdAt;
    final int subtotal;
    final int discountAmount;
    final int serviceFee;
    final int grandTotal;
    final int pointsEarned;
    final int pointsUsed;
    final String? voucherCode;
    final String orderType;
    final String? notes;

    const OrderModel({
      required this.id,
      required this.userId,
      required this.queueNumber,
      required this.branchId,
      required this.branchName,
      required this.items,
      required this.paymentMethod,
      this.status = OrderStatus.pending,
      required this.createdAt,
      required this.subtotal,
      this.discountAmount = 0,
      required this.serviceFee,
      required this.grandTotal,
      required this.pointsEarned,
      this.pointsUsed = 0,
      this.voucherCode,
      this.orderType = 'dine_in',
      this.notes,
    });

    OrderModel copyWith({
      String? id,
      OrderStatus? status,
    }) {
      return OrderModel(
        id: id ?? this.id,
        userId: userId,
        queueNumber: queueNumber,
        branchId: branchId,
        branchName: branchName,
        items: items,
        paymentMethod: paymentMethod,
        status: status ?? this.status,
        createdAt: createdAt,
        subtotal: subtotal,
        discountAmount: discountAmount,
        serviceFee: serviceFee,
        grandTotal: grandTotal,
        pointsEarned: pointsEarned,
        pointsUsed: pointsUsed,
        voucherCode: voucherCode,
        orderType: orderType,
        notes: notes,
      );
    }
  }