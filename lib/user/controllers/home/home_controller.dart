import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../../controllers/menu/menu_controller.dart';
import '../../core/app_state.dart';
import '../../data/datasources/branch_remote.dart';
import '../../data/datasources/menu_remote.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/repositories/branch_repository.dart';
import '../../data/repositories/menu_repository.dart';

class HomeController extends GetxController {
  final BranchRepository branchRepository;
  final MenuRepository menuRepository;

  HomeController({
    BranchRepository? branchRepository,
    MenuRepository? menuRepository,
  }) : branchRepository = branchRepository ?? BranchRepository(BranchRemote()),
       menuRepository = menuRepository ?? MenuRepository(MenuRemote());

  final AppStateController appState = Get.find<AppStateController>();

  final RxBool isLoading = true.obs;
  final RxBool isRefreshingMenus = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<Branch> branches = <Branch>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxList<MenuItem> featuredMenus = <MenuItem>[].obs;

  final RxString selectedCategoryId = 'all'.obs;

  Branch? get selectedBranch => appState.selectedBranch;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final fetchedBranches = await branchRepository.getBranches();
      final fetchedCategories = await menuRepository.getCategories();

      branches.assignAll(fetchedBranches);
      categories.assignAll(fetchedCategories);

      _setInitialBranch();
      await loadFeaturedMenus();
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      featuredMenus.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void _setInitialBranch() {
    if (branches.isEmpty) return;

    final savedBranchId = appState.selectedBranch?.id;

    if (savedBranchId != null && savedBranchId.isNotEmpty) {
      final savedBranch = branches.firstWhereOrNull(
        (branch) => branch.id == savedBranchId,
      );

      if (savedBranch != null) {
        appState.setBranch(savedBranch);
        return;
      }
    }

    final defaultBranch = _resolveDefaultBranch(branches) ?? branches.first;
    appState.setBranch(defaultBranch);
  }

  Branch? _resolveDefaultBranch(List<Branch> allBranches) {
    return allBranches.firstWhereOrNull((branch) {
      final name = branch.name.toLowerCase();
      final address = branch.address.toLowerCase();

      return name.contains('biola') ||
          address.contains('jl. biola') ||
          address.contains('prevab');
    });
  }

  Future<void> loadFeaturedMenus() async {
    final branch = appState.selectedBranch;
    if (branch == null) {
      featuredMenus.clear();
      return;
    }

    try {
      isRefreshingMenus.value = true;
      errorMessage.value = '';

      final menus = await menuRepository.getFeaturedMenus(
        branchId: branch.id,
        categoryId: selectedCategoryId.value,
        limit: 4,
      );

      featuredMenus.assignAll(menus);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      featuredMenus.clear();
    } finally {
      isRefreshingMenus.value = false;
    }
  }

  Future<void> selectBranch(Branch branch) async {
    if (!branch.isOpen) return;
    if (appState.selectedBranch?.id == branch.id) return;

    appState.setBranch(branch);

    if (Get.isRegistered<MenuController>()) {
      await Get.find<MenuController>().reloadForBranchChange();
    }

    await loadFeaturedMenus();
  }

  Future<void> selectCategory(String categoryId) async {
    selectedCategoryId.value = categoryId;
    await loadFeaturedMenus();
  }

  int qtyForMenu(String menuId) {
    int total = 0;

    for (final item in appState.cartItems) {
      if (item.menuItem.id == menuId) {
        total += item.qty;
      }
    }

    return total;
  }

  IconData iconForCategory(String categoryName) {
    final name = categoryName.trim().toLowerCase();

    if (name == 'drink' || name.contains('coffee') || name.contains('tea')) {
      return Icons.local_cafe_rounded;
    }
    if (name == 'food') {
      return Icons.fastfood_rounded;
    }
    if (name == 'snack') {
      return Icons.cookie_rounded;
    }
    if (name == 'dessert') {
      return Icons.cake_rounded;
    }

    return Icons.restaurant_menu_rounded;
  }
}
