class UserModel {
  final String id;
  final String authId;
  final String name;
  final String email;
  final String phone;
  final int loyaltyPoints;
  final int totalEarnedPoints;
  final String membershipTier;
  final String role;

  const UserModel({
    required this.id,
    required this.authId,
    required this.name,
    required this.email,
    required this.phone,
    required this.loyaltyPoints,
    required this.totalEarnedPoints,
    required this.membershipTier,
    required this.role,
  });

  UserModel copyWith({
    String? id,
    String? authId,
    String? name,
    String? email,
    String? phone,
    int? loyaltyPoints,
    int? totalEarnedPoints,
    String? membershipTier,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      totalEarnedPoints: totalEarnedPoints ?? this.totalEarnedPoints,
      membershipTier: membershipTier ?? this.membershipTier,
      role: role ?? this.role,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final totalEarnedPoints = _toInt(
      map['total_earned_points'] ??
          map['totalEarnedPoints'] ??
          map['total_points'] ??
          0,
    );

    final loyaltyPoints = _toInt(
      map['loyalty_points'] ?? map['loyaltyPoints'] ?? 0,
    );

    final rawTier = (map['membership_tier'] ?? map['membershipTier'])
        ?.toString()
        .trim()
        .toLowerCase();

    final rawRole = (map['role'] ?? 'user').toString().trim().toLowerCase();

    return UserModel(
      id: (map['id'] ?? '').toString(),
      authId: (map['auth_id'] ?? map['authId'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      loyaltyPoints: loyaltyPoints,
      totalEarnedPoints: totalEarnedPoints,
      membershipTier: _normalizeTier(
        rawTier,
        fallbackTotalEarned: totalEarnedPoints,
      ),
      role: rawRole.isEmpty ? 'user' : rawRole,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'auth_id': authId,
      'name': name,
      'email': email,
      'phone': phone,
      'loyalty_points': loyaltyPoints,
      'total_earned_points': totalEarnedPoints,
      'membership_tier': membershipTier,
      'role': role,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  static String _normalizeTier(
    String? tier, {
    required int fallbackTotalEarned,
  }) {
    switch (tier) {
      case 'bronze':
      case 'silver':
      case 'gold':
      case 'platinum':
        return tier!;
      default:
        return getTier(fallbackTotalEarned);
    }
  }

  static String getTier(int totalEarned) {
    if (totalEarned >= 800) return 'platinum';
    if (totalEarned >= 300) return 'gold';
    if (totalEarned >= 100) return 'silver';
    return 'bronze';
  }

  static String getTierLabel(String tier) {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return 'Platinum';
      case 'gold':
        return 'Gold';
      case 'silver':
        return 'Silver';
      default:
        return 'Bronze';
    }
  }

  static String getTierIcon(String tier) {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return '💎';
      case 'gold':
        return '🥇';
      case 'silver':
        return '🥈';
      default:
        return '🥉';
    }
  }
}
