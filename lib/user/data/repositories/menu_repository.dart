import '../datasources/menu_remote.dart';
import '../models/menu_item_model.dart';

class MenuRepository {
  final MenuRemote remote;

  MenuRepository(this.remote);

  Future<List<MenuItem>> getMenus({
    required String branchId,
    String? categoryId,
  }) {
    return remote.getMenus(branchId: branchId, categoryId: categoryId);
  }

  Future<List<Category>> getCategories() {
    return remote.getCategories();
  }

  Future<List<MenuItem>> getFeaturedMenus({
    required String branchId,
    String? categoryId,
    int limit = 4,
  }) {
    return remote.getFeaturedMenus(
      branchId: branchId,
      categoryId: categoryId,
      limit: limit,
    );
  }
}
