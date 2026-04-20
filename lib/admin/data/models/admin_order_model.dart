class AdminOrderModel {
  final String id;
  final String queueNumber;
  final String status;
  final int subtotal;
  final int discountAmount;
  final int serviceFee;
  final int grandTotal;
  final int pointsEarned;
  final int pointsUsed;
  final String voucherCode;
  final String orderType;
  final String notes;
  final String createdAt;
  final String updatedAt;
  final String userName;
  final String userEmail;
  final String branchName;
  final List<Map<String, dynamic>> orderItems;

  const AdminOrderModel({
    required this.id,
    required this.queueNumber,
    required this.status,
    required this.subtotal,
    required this.discountAmount,
    required this.serviceFee,
    required this.grandTotal,
    required this.pointsEarned,
    required this.pointsUsed,
    required this.voucherCode,
    required this.orderType,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.userName,
    required this.userEmail,
    required this.branchName,
    required this.orderItems,
  });

  factory AdminOrderModel.fromMap(Map<String, dynamic> map) {
    final userData = map['users'] as Map<String, dynamic>?;
    final branchData = map['branches'] as Map<String, dynamic>?;
    final itemsRaw = map['order_items'];

    return AdminOrderModel(
      id: (map['id'] ?? '').toString(),
      queueNumber: (map['queue_number'] ?? '').toString(),
      status: (map['status'] ?? '').toString(),
      subtotal: (map['subtotal'] as num?)?.toInt() ?? 0,
      discountAmount: (map['discount_amount'] as num?)?.toInt() ?? 0,
      serviceFee: (map['service_fee'] as num?)?.toInt() ?? 0,
      grandTotal: (map['grand_total'] as num?)?.toInt() ?? 0,
      pointsEarned: (map['points_earned'] as num?)?.toInt() ?? 0,
      pointsUsed: (map['points_used'] as num?)?.toInt() ?? 0,
      voucherCode: (map['voucher_code'] ?? '').toString(),
      orderType: (map['order_type'] ?? '').toString(),
      notes: (map['notes'] ?? '').toString(),
      createdAt: (map['created_at'] ?? '').toString(),
      updatedAt: (map['updated_at'] ?? '').toString(),
      userName: (userData?['name'] ?? '').toString(),
      userEmail: (userData?['email'] ?? '').toString(),
      branchName: (branchData?['name'] ?? '').toString(),
      orderItems: itemsRaw is List
          ? itemsRaw
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : const <Map<String, dynamic>>[],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'queue_number': queueNumber,
      'status': status,
      'subtotal': subtotal,
      'discount_amount': discountAmount,
      'service_fee': serviceFee,
      'grand_total': grandTotal,
      'points_earned': pointsEarned,
      'points_used': pointsUsed,
      'voucher_code': voucherCode,
      'order_type': orderType,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'users': {'name': userName, 'email': userEmail},
      'branches': {'name': branchName},
      'order_items': orderItems,
    };
  }
}
