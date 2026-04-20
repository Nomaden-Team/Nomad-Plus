import 'package:get/get.dart';

import '../../data/models/menu_item_model.dart';

class CartController extends GetxController {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  List<CartItem> get cartItems => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get totalQty {
    int total = 0;
    for (final item in _items) {
      total += item.qty;
    }
    return total;
  }

  int get subtotal {
    int total = 0;
    for (final item in _items) {
      total += item.subtotal;
    }
    return total;
  }

  void addSimple(MenuItem menuItem) {
    addItem(
      menuItem,
      1,
      _defaultNotes(menuItem),
      unitPrice: _defaultUnitPrice(menuItem),
      customizationKey: _defaultCustomizationKey(menuItem),
    );
  }

  void addItem(
    MenuItem menuItem,
    int qty,
    String notes, {
    int? unitPrice,
    String customizationKey = 'default',
  }) {
    if (qty <= 0) return;

    final finalUnitPrice = unitPrice ?? menuItem.price;
    final entryId = CartItem.entryKey(
      menuItem.id,
      customizationKey,
      notes: notes,
    );

    final index = _items.indexWhere((item) => item.entryId == entryId);

    if (index >= 0) {
      final current = _items[index];
      _items[index] = current.copyWith(qty: current.qty + qty);
    } else {
      _items.add(
        CartItem(
          entryId: entryId,
          menuItem: menuItem,
          qty: qty,
          notes: notes,
          unitPrice: finalUnitPrice,
          customizationKey: customizationKey,
        ),
      );
    }

    update();
  }

  void updateQty(String entryId, int newQty) {
    final index = _items.indexWhere((item) => item.entryId == entryId);
    if (index < 0) return;

    if (newQty <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(qty: newQty);
    }

    update();
  }

  void decreaseQty(String entryId) {
    final index = _items.indexWhere((item) => item.entryId == entryId);
    if (index < 0) return;

    if (_items[index].qty > 1) {
      _items[index] = _items[index].copyWith(qty: _items[index].qty - 1);
      update();
    }
  }

  void removeItem(String entryId) {
    _items.removeWhere((item) => item.entryId == entryId);
    update();
  }

  int qtyForMenu(String menuId) {
    int total = 0;
    for (final item in _items) {
      if (item.menuItem.id == menuId) {
        total += item.qty;
      }
    }
    return total;
  }

  void clearCart() {
    _items.clear();
    update();
  }

  void clearCartSilently() {
    _items.clear();
  }

  String _defaultCustomizationKey(MenuItem menuItem) {
    if (menuItem.isDrink) {
      return 'temp=ice|ice=normal|sugar=normal';
    }

    if (menuItem.isFood) {
      return 'spicy=no|egg=no';
    }

    return 'default';
  }

  String _defaultNotes(MenuItem menuItem) {
    if (menuItem.isDrink) {
      return 'Temperature: Ice | Ice: Normal | Sugar: Normal';
    }

    if (menuItem.isFood) {
      return 'Spicy: Tidak | Egg: Tidak';
    }

    return '';
  }

  int _defaultUnitPrice(MenuItem menuItem) {
    return menuItem.price;
  }
}
