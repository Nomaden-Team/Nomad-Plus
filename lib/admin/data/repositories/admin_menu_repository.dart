import 'dart:typed_data';
import '../datasources/admin_menu_remote.dart';
import '../models/admin_menu_model.dart';

class AdminMenuRepository {
  final AdminMenuRemote remote;

  AdminMenuRepository(this.remote);

  Future<List<Map<String, dynamic>>> fetchCategories() =>
      remote.fetchCategories();
  Future<List<Map<String, dynamic>>> fetchBranches() => remote.fetchBranches();
  Future<List<AdminMenuModel>> fetchMenus() => remote.fetchMenus();

  Future<void> updateAvailability({
    required String menuId,
    required bool isAvailable,
  }) => remote.updateAvailability(menuId: menuId, isAvailable: isAvailable);

  Future<void> deleteMenu(String menuId) => remote.deleteMenu(menuId);

  Future<void> saveMenu({
    String? menuId,
    required Map<String, dynamic> payload,
  }) => remote.saveMenu(menuId: menuId, payload: payload);

  Future<String> uploadMenuImage({
    required Uint8List bytes,
    required String filePath,
    required String contentType,
  }) => remote.uploadMenuImage(
    bytes: bytes,
    filePath: filePath,
    contentType: contentType,
  );
}
