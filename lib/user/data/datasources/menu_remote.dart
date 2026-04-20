import '../../core/services/supabase_service.dart';
import '../models/menu_item_model.dart';

class MenuRemote {
  Future<List<MenuItem>> getMenus({
    required String branchId,
    String? categoryId,
  }) async {
    dynamic query = SupabaseService.client
        .from('menu_items')
        .select('*, categories(name)')
        .eq('branch_id', branchId);

    // Filter by category jika diberikan, abaikan jika 'all'
    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
      query = query.eq('category_id', categoryId);
    }

    final response = await query.order('name');

    return (response as List)
        .map((e) => _menuFromResponse(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Category>> getCategories() async {
    final response = await SupabaseService.client
        .from('categories')
        .select()
        .order('name');

    // PERBAIKAN: Langsung kembalikan data murni dari database tanpa menyelipkan 'All'
    return (response as List)
        .map((item) => Category.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<MenuItem>> getFeaturedMenus({
    required String branchId,
    String? categoryId,
    int limit = 4,
  }) async {
    dynamic query = SupabaseService.client
        .from('menu_items')
        .select('*, categories(name)')
        .eq('branch_id', branchId)
        .eq('is_available', true);

    // Filter by category jika diberikan, abaikan jika 'all'
    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
      query = query.eq('category_id', categoryId);
    }

    final response = await query
        .order('order_count', ascending: false)
        .limit(limit);

    return (response as List)
        .map((e) => _menuFromResponse(Map<String, dynamic>.from(e)))
        .toList();
  }

  MenuItem _menuFromResponse(Map<String, dynamic> data) {
    final mapped = <String, dynamic>{...data};
    final category = data['categories'];

    if (category is Map<String, dynamic>) {
      mapped['category_name'] = category['name'];
    } else if (category is Map) {
      mapped['category_name'] = category['name'];
    }

    return MenuItem.fromMap(mapped);
  }
}