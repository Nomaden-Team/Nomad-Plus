class AdminBranchModel {
  final String id;
  final String name;
  final String address;
  final String location;
  final String openTime;
  final String closeTime;
  final bool isOpen;

  const AdminBranchModel({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.openTime,
    required this.closeTime,
    required this.isOpen,
  });

  factory AdminBranchModel.fromMap(Map<String, dynamic> map) {
    return AdminBranchModel(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
      location: (map['location'] ?? '').toString(),
      openTime: (map['open_time'] ?? '').toString(),
      closeTime: (map['close_time'] ?? '').toString(),
      isOpen: map['is_open'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'location': location,
      'open_time': openTime,
      'close_time': closeTime,
      'is_open': isOpen,
    };
  }
}
