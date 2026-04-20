enum VoucherType { percent, fixed, freeItem, birthday }

class VoucherModel {
  final String id;
  final String code;
  final String name;
  final VoucherType type;
  final int discountValue;
  final int? maxDiscount;
  final int minOrderValue;
  final int? usageLimit;
  final int usedCount;
  final int usagePerUser;
  final DateTime startDate;
  final DateTime expiryDate;
  final bool isActive;

  const VoucherModel({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.discountValue,
    this.maxDiscount,
    this.minOrderValue = 0,
    this.usageLimit,
    this.usedCount = 0,
    this.usagePerUser = 1,
    required this.startDate,
    required this.expiryDate,
    this.isActive = true,
  });

  factory VoucherModel.fromMap(Map<String, dynamic> map) {
    return VoucherModel(
      id: (map['id'] ?? '').toString(),
      code: (map['code'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      type: _parseVoucherType(map['type']),
      discountValue: _toInt(map['discount_value']),
      maxDiscount: map['max_discount'] == null
          ? null
          : _toInt(map['max_discount']),
      minOrderValue: _toInt(map['min_order_value']),
      usageLimit: map['usage_limit'] == null
          ? null
          : _toInt(map['usage_limit']),
      usedCount: _toInt(map['used_count']),
      usagePerUser: _toInt(map['usage_per_user'] ?? 1),
      startDate: _parseDate(
        value: map['start_date'],
        fieldLabel: 'tanggal mulai voucher',
      ),
      expiryDate: _parseDate(
        value: map['expiry_date'],
        fieldLabel: 'tanggal berakhir voucher',
      ),
      isActive: map['is_active'] ?? true,
    );
  }

  static VoucherType _parseVoucherType(dynamic rawType) {
    final value = (rawType ?? '').toString().trim().toLowerCase();

    switch (value) {
      case 'percent':
      case 'percentage':
        return VoucherType.percent;
      case 'fixed':
        return VoucherType.fixed;
      case 'free_item':
      case 'freeitem':
        return VoucherType.freeItem;
      case 'birthday':
        return VoucherType.birthday;
      default:
        return VoucherType.fixed;
    }
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  static DateTime _parseDate({
    required dynamic value,
    required String fieldLabel,
  }) {
    if (value == null) {
      throw FormatException('$fieldLabel belum diisi');
    }

    final raw = value.toString().trim();
    if (raw.isEmpty || raw.toLowerCase() == 'null') {
      throw FormatException('$fieldLabel belum diisi');
    }

    try {
      return DateTime.parse(raw);
    } catch (_) {
      throw FormatException('$fieldLabel tidak valid');
    }
  }

  int calculateDiscount(int subtotal) {
    if (!isValid) return 0;
    if (subtotal < minOrderValue) return 0;

    switch (type) {
      case VoucherType.percent:
        final rawDiscount = ((subtotal * discountValue) / 100).floor();
        if (maxDiscount != null) {
          return rawDiscount.clamp(0, maxDiscount!);
        }
        return rawDiscount;

      case VoucherType.fixed:
      case VoucherType.birthday:
        return discountValue.clamp(0, subtotal);

      case VoucherType.freeItem:
        return 0;
    }
  }

  bool get isValid {
    final now = DateTime.now();

    if (!isActive) return false;
    if (now.isBefore(startDate)) return false;
    if (now.isAfter(expiryDate)) return false;
    if (usageLimit != null && usedCount >= usageLimit!) return false;

    return true;
  }

  String? validate(int subtotal, int userUsageCount) {
    final now = DateTime.now();

    if (!isActive) return 'Voucher ini sedang tidak tersedia';
    if (now.isBefore(startDate)) return 'Voucher ini belum bisa digunakan';
    if (now.isAfter(expiryDate)) return 'Masa berlaku voucher ini sudah berakhir';
    if (usageLimit != null && usedCount >= usageLimit!) {
      return 'Voucher ini sudah habis';
    }
    if (userUsageCount >= usagePerUser) {
      return 'Voucher ini sudah pernah kamu gunakan';
    }
    if (subtotal < minOrderValue) {
      return 'Minimum belanja belum memenuhi syarat voucher';
    }

    return null;
  }

  String get typeLabel {
    switch (type) {
      case VoucherType.percent:
        return 'Diskon $discountValue%';
      case VoucherType.fixed:
        return 'Potongan ${_currency(discountValue)}';
      case VoucherType.freeItem:
        return 'Gratis item';
      case VoucherType.birthday:
        return 'Promo ulang tahun';
    }
  }

  static String _currency(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final pos = s.length - i;
      buffer.write(s[i]);
      if (pos > 1 && pos % 3 == 1) buffer.write('.');
    }
    return 'Rp $buffer';
  }
}