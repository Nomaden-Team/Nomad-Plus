class Branch {
  final String id;
  final String name;
  final String address;
  final String phone;
  final bool isOpen;
  final String openTime;
  final String closeTime;
  final String imageUrl;

  const Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
    required this.imageUrl,
  });

  factory Branch.fromMap(Map<String, dynamic> map) {
    return Branch(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      address: (map['location'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      isOpen: map['is_open'] == null ? true : map['is_open'] as bool,
      openTime: (map['open_time'] ?? '').toString(),
      closeTime: (map['close_time'] ?? '').toString(),
      imageUrl: (map['image_url'] ?? '').toString(),
    );
  }
}