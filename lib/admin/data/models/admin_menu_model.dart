class AdminMenuModel {
  final String id;
  final String name;
  final int price;
  final String imageUrl;
  final bool isAvailable;
  final String categoryId;
  final String branchId;
  final String categoryName;
  final String branchName;

  const AdminMenuModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
    required this.categoryId,
    required this.branchId,
    required this.categoryName,
    required this.branchName,
  });

  factory AdminMenuModel.fromMap(Map<String, dynamic> map) {
    final categoryData = map['categories'] as Map<String, dynamic>?;
    final branchData = map['branches'] as Map<String, dynamic>?;

    return AdminMenuModel(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      price: (map['price'] as num?)?.toInt() ?? 0,
      imageUrl: (map['image_url'] ?? '').toString(),
      isAvailable: map['is_available'] == true,
      categoryId: (map['category_id'] ?? '').toString(),
      branchId: (map['branch_id'] ?? '').toString(),
      categoryName: (categoryData?['name'] ?? '').toString(),
      branchName: (branchData?['name'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'category_id': categoryId,
      'branch_id': branchId,
      'categories': {'name': categoryName},
      'branches': {'name': branchName},
    };
  }
}
