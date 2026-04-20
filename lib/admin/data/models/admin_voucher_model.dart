class AdminVoucherModel {
  final String id;
  final String code;
  final String name;
  final String type; // fixed | percentage
  final int discountValue;
  final int? maxDiscount;
  final int minOrderValue;
  final int? usageLimit;
  final int? usagePerUser;
  final int usedCount;
  final String startDate;
  final String expiryDate;
  final bool isActive;
  final String branchId;

  const AdminVoucherModel({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.discountValue,
    this.maxDiscount,
    required this.minOrderValue,
    this.usageLimit,
    this.usagePerUser,
    required this.usedCount,
    required this.startDate,
    required this.expiryDate,
    required this.isActive,
    required this.branchId,
  });

  factory AdminVoucherModel.fromMap(Map<String, dynamic> map) {
    return AdminVoucherModel(
      id: (map['id'] ?? '').toString(),
      code: (map['code'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      type: _normalizeDbType(map['type']),
      discountValue: _toInt(map['discount_value']),
      maxDiscount: _toNullableInt(map['max_discount']),
      minOrderValue: _toInt(map['min_order_value']),
      usageLimit: _toNullableInt(map['usage_limit']),
      usagePerUser: _toNullableInt(map['usage_per_user']),
      usedCount: _toInt(map['used_count']),
      startDate: _dateOnly(map['start_date']),
      expiryDate: _dateOnly(map['expiry_date']),
      isActive: map['is_active'] == true,
      branchId: (map['branch_id'] ?? '').toString(),
    );
  }

  String get uiType => type == 'percentage' ? 'percent' : 'fixed';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'type': type,
      'discount_value': discountValue,
      'max_discount': maxDiscount,
      'min_order_value': minOrderValue,
      'usage_limit': usageLimit,
      'usage_per_user': usagePerUser,
      'used_count': usedCount,
      'start_date': startDate,
      'expiry_date': expiryDate,
      'is_active': isActive,
      'branch_id': branchId,
    };
  }

  static String _normalizeDbType(dynamic value) {
    final raw = (value ?? '').toString().trim().toLowerCase();
    if (raw == 'percent' || raw == 'percentage') return 'percentage';
    return 'fixed';
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value.toString().trim();
    if (text.isEmpty) return 0;

    return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value.toString().trim();
    if (text.isEmpty) return null;

    return int.tryParse(text) ?? double.tryParse(text)?.toInt();
  }

  static String _dateOnly(dynamic value) {
    final raw = (value ?? '').toString().trim();
    if (raw.isEmpty) return '';
    if (raw.contains('T')) return raw.split('T').first;
    if (raw.contains(' ')) return raw.split(' ').first;
    return raw;
  }
}