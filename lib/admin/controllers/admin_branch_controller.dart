import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/repositories/admin_branch_repository.dart';

class AdminBranchController extends GetxController {
  final AdminBranchRepository repository;

  AdminBranchController(this.repository);

  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxList<Map<String, dynamic>> branches = <Map<String, dynamic>>[].obs;

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final openTimeCtrl = TextEditingController();
  final closeTimeCtrl = TextEditingController();

  final RxBool isOpen = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBranches();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    addressCtrl.dispose();
    openTimeCtrl.dispose();
    closeTimeCtrl.dispose();
    super.onClose();
  }

  Future<void> fetchBranches() async {
    try {
      isLoading.value = true;
      final response = await repository.fetchBranches();
      branches.assignAll(response.map((e) => e.toMap()).toList());
    } catch (e) {
      Get.snackbar(
        'Tidak bisa memuat data',
        'Daftar cabang belum berhasil dibuka.',
      );
      Get.log('AdminBranchController.fetchBranches error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleBranch({
    required String branchId,
    required bool currentValue,
  }) async {
    try {
      await repository.updateBranchOpenStatus(
        branchId: branchId,
        isOpen: !currentValue,
      );
      await fetchBranches();

      Get.snackbar(
        'Berhasil',
        !currentValue ? 'Cabang dibuka.' : 'Cabang ditutup.',
      );
    } catch (e) {
      Get.snackbar('Belum berhasil', 'Status cabang belum bisa diperbarui.');
      Get.log('AdminBranchController.toggleBranch error: $e');
    }
  }

  void fillForm(Map<String, dynamic>? branch) {
    if (branch == null) {
      clearForm();
      return;
    }

    nameCtrl.text = (branch['name'] ?? '').toString();
    addressCtrl.text = (branch['address'] ?? branch['location'] ?? '')
        .toString();
    openTimeCtrl.text = (branch['open_time'] ?? '').toString();
    closeTimeCtrl.text = (branch['close_time'] ?? '').toString();
    isOpen.value = branch['is_open'] == true;
  }

  void clearForm() {
    nameCtrl.clear();
    addressCtrl.clear();
    openTimeCtrl.clear();
    closeTimeCtrl.clear();
    isOpen.value = true;
  }

  Future<void> saveBranch({String? branchId}) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    try {
      isSubmitting.value = true;

      final payload = {
        'name': nameCtrl.text.trim(),
        'address': addressCtrl.text.trim(),
        'location': addressCtrl.text.trim(),
        'open_time': openTimeCtrl.text.trim(),
        'close_time': closeTimeCtrl.text.trim(),
        'is_open': isOpen.value,
      };

      await repository.saveBranch(branchId: branchId, payload: payload);
      await fetchBranches();
      Get.back();

      Get.snackbar(
        'Berhasil',
        branchId == null || branchId.isEmpty
            ? 'Cabang berhasil ditambahkan.'
            : 'Cabang berhasil diperbarui.',
      );
    } catch (e) {
      Get.snackbar('Belum berhasil', 'Cabang belum bisa disimpan.');
      Get.log('AdminBranchController.saveBranch error: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> deleteBranch(String branchId) async {
    try {
      await repository.deleteBranch(branchId);
      await fetchBranches();
      Get.snackbar('Berhasil', 'Cabang berhasil dihapus.');
      return true;
    } catch (e) {
      Get.snackbar('Belum berhasil', 'Cabang belum bisa dihapus.');
      Get.log('AdminBranchController.deleteBranch error: $e');
      return false;
    }
  }
}
