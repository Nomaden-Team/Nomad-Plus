class Category {
  final String id;
  final String name;
  final String icon;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      icon: (map['icon'] ?? '').toString(),
    );
  }
}

class MenuItem {
  final String id;
  final String branchId;
  final String categoryId;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final bool isAvailable;
  final int orderCount;
  final String categoryName;

  const MenuItem({
    required this.id,
    required this.branchId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
    required this.orderCount,
    this.categoryName = '',
  });

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: (map['id'] ?? '').toString(),
      branchId: (map['branch_id'] ?? '').toString(),
      categoryId: (map['category_id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      price: _toInt(map['price']),
      imageUrl: (map['image_url'] ?? '').toString(),
      isAvailable: map['is_available'] ?? true,
      orderCount: _toInt(map['order_count']),
      categoryName: (map['category_name'] ?? '').toString(),
    );
  }

  MenuItem copyWith({
    String? id,
    String? branchId,
    String? categoryId,
    String? name,
    String? description,
    int? price,
    String? imageUrl,
    bool? isAvailable,
    int? orderCount,
    String? categoryName,
  }) {
    return MenuItem(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      orderCount: orderCount ?? this.orderCount,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  bool get isDrink => categoryName.trim().toLowerCase() == 'drink';
  bool get isFood => categoryName.trim().toLowerCase() == 'food';
  bool get isSnack => categoryName.trim().toLowerCase() == 'snack';
  bool get isDessert => categoryName.trim().toLowerCase() == 'dessert';

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }
}

class DrinkCustomization {
  final String temperature; // ice | hot
  final String? iceLevel; // less | normal | more
  final String sugarLevel; // less | normal | more

  const DrinkCustomization({
    required this.temperature,
    required this.iceLevel,
    required this.sugarLevel,
  });

  factory DrinkCustomization.defaults() {
    return const DrinkCustomization(
      temperature: 'ice',
      iceLevel: 'normal',
      sugarLevel: 'normal',
    );
  }

  DrinkCustomization copyWith({
    String? temperature,
    String? iceLevel,
    String? sugarLevel,
  }) {
    return DrinkCustomization(
      temperature: temperature ?? this.temperature,
      iceLevel: iceLevel,
      sugarLevel: sugarLevel ?? this.sugarLevel,
    );
  }
}

class FoodCustomization {
  final bool isSpicy;
  final bool addEgg;

  const FoodCustomization({
    required this.isSpicy,
    required this.addEgg,
  });

  factory FoodCustomization.defaults() {
    return const FoodCustomization(
      isSpicy: false,
      addEgg: false,
    );
  }

  FoodCustomization copyWith({
    bool? isSpicy,
    bool? addEgg,
  }) {
    return FoodCustomization(
      isSpicy: isSpicy ?? this.isSpicy,
      addEgg: addEgg ?? this.addEgg,
    );
  }
}

class CartItem {
  final String entryId;
  final MenuItem menuItem;
  final int qty;
  final String notes;
  final int unitPrice;
  final String customizationKey;

  const CartItem({
    required this.entryId,
    required this.menuItem,
    required this.qty,
    required this.notes,
    required this.unitPrice,
    required this.customizationKey,
  });

  int get subtotal => unitPrice * qty;

  CartItem copyWith({
    String? entryId,
    MenuItem? menuItem,
    int? qty,
    String? notes,
    int? unitPrice,
    String? customizationKey,
  }) {
    return CartItem(
      entryId: entryId ?? this.entryId,
      menuItem: menuItem ?? this.menuItem,
      qty: qty ?? this.qty,
      notes: notes ?? this.notes,
      unitPrice: unitPrice ?? this.unitPrice,
      customizationKey: customizationKey ?? this.customizationKey,
    );
  }

  static String entryKey(
    String menuId,
    String customizationKey, {
    String notes = '',
  }) {
    return '$menuId|$customizationKey|${notes.trim().toLowerCase()}';
  }
}