import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../data/repositories/admin_menu_repository.dart';

class AdminMenuController extends GetxController {
  final AdminMenuRepository repository;

  AdminMenuController(this.repository);

  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isUploadingImage = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isTogglingAvailability = false.obs;

  final RxString selectedCategory = 'all'.obs;

  final RxList<Map<String, dynamic>> menus = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> categoriesData =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> branchesData =
      <Map<String, dynamic>>[].obs;

  final List<String> categories = const [
    'all',
    'drink',
    'food',
    'snack',
    'dessert',
  ];

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final imageUrlCtrl = TextEditingController();

  final RxBool isAvailable = true.obs;
  final RxString selectedCategoryId = ''.obs;
  final RxString selectedBranchId = ''.obs;

  final ImagePicker _picker = ImagePicker();

  static final RegExp _menuNameRegex = RegExp(r'^[a-zA-Z0-9 ]+$');

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    descriptionCtrl.dispose();
    imageUrlCtrl.dispose();
    super.onClose();
  }

  Future<void> fetchInitialData() async {
    await Future.wait([fetchCategories(), fetchBranches(), fetchMenus()]);
  }

  Future<void> fetchCategories() async {
    try {
      final response = await repository.fetchCategories();
      categoriesData.assignAll(response);
    } catch (e) {
      _showNotice(
        title: 'Kategori belum tampil',
        message: 'Daftar kategori belum bisa dimuat sekarang.',
      );
      Get.log('AdminMenuController.fetchCategories error: $e');
    }
  }

  Future<void> fetchBranches() async {
    try {
      final response = await repository.fetchBranches();
      branchesData.assignAll(response);
    } catch (e) {
      _showNotice(
        title: 'Cabang belum tampil',
        message: 'Daftar cabang belum bisa dimuat sekarang.',
      );
      Get.log('AdminMenuController.fetchBranches error: $e');
    }
  }

  Future<void> fetchMenus() async {
    try {
      isLoading.value = true;
      final response = await repository.fetchMenus();
      final raw = response.map((e) => e.toMap()).toList();

      if (selectedCategory.value == 'all') {
        menus.assignAll(raw);
      } else {
        menus.assignAll(
          raw.where((item) {
            final categoryData = item['categories'] as Map<String, dynamic>?;
            final categoryName = (categoryData?['name'] ?? '')
                .toString()
                .toLowerCase();
            return categoryName == selectedCategory.value;
          }).toList(),
        );
      }
    } catch (e) {
      menus.clear();
      _showNotice(
        title: 'Menu belum tampil',
        message: 'Daftar menu belum bisa dimuat sekarang.',
      );
      Get.log('AdminMenuController.fetchMenus error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeCategory(String category) async {
    selectedCategory.value = category;
    await fetchMenus();
  }

  Future<void> toggleAvailability({
    required String menuId,
    required bool currentValue,
  }) async {
    if (isTogglingAvailability.value) return;

    try {
      isTogglingAvailability.value = true;

      await repository.updateAvailability(
        menuId: menuId,
        isAvailable: !currentValue,
      );

      await fetchMenus();

      _showSuccess(
        title: 'Status menu diperbarui',
        message: !currentValue
            ? 'Menu sekarang ditampilkan ke pengguna.'
            : 'Menu sekarang disembunyikan dari pengguna.',
      );
    } catch (e) {
      _showNotice(
        title: 'Status belum berubah',
        message: 'Ketersediaan menu belum bisa diperbarui.',
      );
      Get.log('AdminMenuController.toggleAvailability error: $e');
    } finally {
      isTogglingAvailability.value = false;
    }
  }

  Future<bool> deleteMenu(String menuId) async {
    if (isDeleting.value) return false;

    try {
      isDeleting.value = true;

      await repository.deleteMenu(menuId);
      await fetchMenus();

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      _showSuccess(
        title: 'Menu berhasil dihapus',
        message: 'Menu sudah dihapus dari daftar.',
      );
      return true;
    } catch (e) {
      _showNotice(
        title: 'Menu belum terhapus',
        message: 'Menu ini belum bisa dihapus sekarang.',
      );
      Get.log('AdminMenuController.deleteMenu error: $e');
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  void clearForm() {
    nameCtrl.clear();
    priceCtrl.clear();
    descriptionCtrl.clear();
    imageUrlCtrl.clear();
    isAvailable.value = true;
    selectedCategoryId.value = '';
    selectedBranchId.value = '';
  }

  void fillForm(Map<String, dynamic>? menu) {
    if (menu == null) {
      clearForm();
      return;
    }

    nameCtrl.text = (menu['name'] ?? '').toString();
    priceCtrl.text = (menu['price'] ?? 0).toString();
    descriptionCtrl.text = (menu['description'] ?? '').toString();
    imageUrlCtrl.text = (menu['image_url'] ?? '').toString();
    isAvailable.value = menu['is_available'] == true;
    selectedCategoryId.value = (menu['category_id'] ?? '').toString();
    selectedBranchId.value = (menu['branch_id'] ?? '').toString();
  }

  Future<void> pickAndUploadImage() async {
    if (isUploadingImage.value) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      isUploadingImage.value = true;

      final bytes = await pickedFile.readAsBytes();
      final parts = pickedFile.name.split('.');
      final ext = parts.isNotEmpty ? parts.last.toLowerCase() : 'jpg';

      final fileName =
          'menu_${DateTime.now().millisecondsSinceEpoch}.${ext.isEmpty ? 'jpg' : ext}';
      final filePath = 'menus/$fileName';

      final publicUrl = await repository.uploadMenuImage(
        bytes: bytes,
        filePath: filePath,
        contentType: _getContentType(ext),
      );

      imageUrlCtrl.text = publicUrl;
      imageUrlCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: imageUrlCtrl.text.length),
      );

      _showSuccess(
        title: 'Foto berhasil diunggah',
        message: 'Foto menu sudah tersimpan dan siap dipakai.',
      );
    } catch (e) {
      _showNotice(
        title: 'Foto belum terunggah',
        message: 'Coba pilih gambar lain atau ulangi beberapa saat lagi.',
      );
      Get.log('AdminMenuController.pickAndUploadImage error: $e');
    } finally {
      isUploadingImage.value = false;
    }
  }

  String _getContentType(String ext) {
    switch (ext.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  String? validateMenuName(String? value) {
    final text = (value ?? '').trim();

    if (text.isEmpty) {
      return 'Nama menu wajib diisi';
    }

    if (text.length < 3) {
      return 'Nama menu minimal 3 karakter';
    }

    if (text.length > 50) {
      return 'Nama menu maksimal 50 karakter';
    }

    if (!_menuNameRegex.hasMatch(text)) {
      return 'Nama menu hanya boleh huruf, angka, dan spasi';
    }

    return null;
  }

  String? validatePrice(String? value) {
    final text = (value ?? '').trim();

    if (text.isEmpty) {
      return 'Harga wajib diisi';
    }

    final price = int.tryParse(text);
    if (price == null) {
      return 'Harga harus berupa angka';
    }

    if (price < 1000) {
      return 'Harga minimal Rp1000';
    }

    if (price > 500000) {
      return 'Harga maksimal Rp500000';
    }

    return null;
  }

  String? validateDescription(String? value) {
    final text = (value ?? '').trim();

    if (text.length > 200) {
      return 'Deskripsi maksimal 200 karakter';
    }

    return null;
  }

  Future<void> saveMenu({String? menuId}) async {
    if (isSubmitting.value) return;

    FocusManager.instance.primaryFocus?.unfocus();

    if (!(formKey.currentState?.validate() ?? false)) {
      _showNotice(
        title: 'Data belum lengkap',
        message: 'Periksa lagi isian menu yang masih kosong atau belum sesuai.',
      );
      return;
    }

    if (selectedCategoryId.value.isEmpty) {
      _showNotice(
        title: 'Kategori belum dipilih',
        message: 'Pilih kategori menu terlebih dahulu.',
      );
      return;
    }

    if (selectedBranchId.value.isEmpty) {
      _showNotice(
        title: 'Cabang belum dipilih',
        message: 'Pilih cabang untuk menu ini terlebih dahulu.',
      );
      return;
    }

    if (imageUrlCtrl.text.trim().isEmpty) {
      _showNotice(
        title: 'Foto belum tersedia',
        message: 'Upload foto menu terlebih dahulu sebelum menyimpan.',
      );
      return;
    }

    final parsedPrice = int.tryParse(priceCtrl.text.trim());
    if (parsedPrice == null || parsedPrice <= 0) {
      _showNotice(
        title: 'Harga belum sesuai',
        message: 'Masukkan harga menu dengan angka yang valid.',
      );
      return;
    }

    try {
      isSubmitting.value = true;

      final payload = {
        'name': nameCtrl.text.trim(),
        'price': parsedPrice,
        'description': descriptionCtrl.text.trim().isEmpty
            ? null
            : descriptionCtrl.text.trim(),
        'image_url': imageUrlCtrl.text.trim(),
        'category_id': selectedCategoryId.value,
        'branch_id': selectedBranchId.value,
        'is_available': isAvailable.value,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await repository.saveMenu(menuId: menuId, payload: payload);
      await fetchMenus();
      Get.back();

      _showSuccess(
        title: menuId == null || menuId.isEmpty
            ? 'Menu berhasil ditambahkan'
            : 'Perubahan berhasil disimpan',
        message: menuId == null || menuId.isEmpty
            ? 'Menu baru sudah masuk ke daftar.'
            : 'Data menu sudah diperbarui.',
      );
    } catch (e) {
      _showNotice(
        title: 'Menu belum tersimpan',
        message: 'Perubahan belum bisa disimpan sekarang.',
      );
      Get.log('AdminMenuController.saveMenu error: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  void _showSuccess({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
      borderColor: const Color(0xFFEAE1DC),
      borderWidth: 1,
      margin: const EdgeInsets.all(12),
      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
      duration: const Duration(seconds: 2),
    );
  }

  void _showNotice({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
      borderColor: const Color(0xFFEAE1DC),
      borderWidth: 1,
      margin: const EdgeInsets.all(12),
      icon: const Icon(Icons.info_outline_rounded, color: Colors.orange),
      duration: const Duration(seconds: 3),
    );
  }
}
