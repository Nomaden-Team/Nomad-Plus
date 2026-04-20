import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/repositories/admin_order_repository.dart';

class AdminOrderController extends GetxController {
  final AdminOrderRepository repository;

  AdminOrderController(this.repository);

  final RxBool isLoading = true.obs;
  final RxBool isUpdatingStatus = false.obs;
  final RxString selectedStatus = 'menunggu'.obs;
  final RxString errorMessage = ''.obs;
  final RxString updatingOrderId = ''.obs;

  final RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;

  final List<String> statuses = const [
    'menunggu',
    'diproses',
    'selesai',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await repository.fetchOrdersByStatus(selectedStatus.value);
      orders.assignAll(response.map((e) => e.toMap()).toList());
    } catch (e) {
      orders.clear();
      errorMessage.value = 'Daftar pesanan belum bisa dimuat sekarang.';
      _showNotice(
        title: 'Pesanan belum tampil',
        message: 'Coba buka lagi beberapa saat.',
      );
      Get.log('AdminOrderController.fetchOrders error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeFilter(String status) async {
    if (selectedStatus.value == status) return;
    if (isLoading.value) return;

    selectedStatus.value = status;
    await fetchOrders();
  }

  bool canUpdateOrder(String orderId) {
    return !isUpdatingStatus.value || updatingOrderId.value == orderId;
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    if (isUpdatingStatus.value) return;
    if (orderId.trim().isEmpty) {
      _showNotice(
        title: 'Pesanan belum bisa diperbarui',
        message: 'ID pesanan tidak ditemukan.',
      );
      return;
    }

    final currentOrder = orders.firstWhereOrNull(
      (e) => (e['id'] ?? '').toString() == orderId,
    );

    final currentStatus = (currentOrder?['status'] ?? '').toString();

    if (currentStatus == newStatus) {
      _showNotice(
        title: 'Status sudah sesuai',
        message: 'Pesanan ini sudah berada di status ${formatStatusLabel(newStatus)}.',
      );
      return;
    }

    if (!_isStatusTransitionAllowed(
      currentStatus: currentStatus,
      newStatus: newStatus,
    )) {
      _showNotice(
        title: 'Perubahan belum bisa dilakukan',
        message: 'Status ${formatStatusLabel(currentStatus)} tidak bisa langsung diubah ke ${formatStatusLabel(newStatus)}.',
      );
      return;
    }

    try {
      isUpdatingStatus.value = true;
      updatingOrderId.value = orderId;

      await repository.updateOrderStatus(
        orderId: orderId,
        newStatus: newStatus,
      );

      await fetchOrders();

      _showSuccess(
        title: 'Status berhasil diperbarui',
        message: 'Pesanan sekarang masuk ke ${formatStatusLabel(newStatus)}.',
      );
    } catch (e) {
      _showNotice(
        title: 'Status belum berubah',
        message: 'Perubahan status belum bisa disimpan sekarang.',
      );
      Get.log('AdminOrderController.updateOrderStatus error: $e');
    } finally {
      isUpdatingStatus.value = false;
      updatingOrderId.value = '';
    }
  }

  bool _isStatusTransitionAllowed({
    required String currentStatus,
    required String newStatus,
  }) {
    switch (currentStatus) {
      case 'menunggu':
        return newStatus == 'diproses';
      case 'diproses':
        return newStatus == 'selesai';
      case 'selesai':
        return false;
      default:
        return false;
    }
  }

  String formatStatusLabel(String status) {
    switch (status) {
      case 'menunggu':
        return 'Menunggu';
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      default:
        return status;
    }
  }

  String formatPaymentLabel(String paymentMethod) {
    final value = paymentMethod.trim().toLowerCase();

    switch (value) {
      case 'cash':
        return 'Tunai';
      case 'qris':
        return 'QRIS';
      case 'transfer':
        return 'Transfer';
      case 'card':
        return 'Kartu';
      default:
        return paymentMethod.isEmpty ? '-' : paymentMethod.toUpperCase();
    }
  }

  void _showSuccess({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
      borderColor: const Color(0xFFEAE1DC),
      borderWidth: 1,
      margin: const EdgeInsets.all(12),
      icon: const Icon(
        Icons.check_circle_outline_rounded,
        color: Colors.green,
      ),
      duration: const Duration(seconds: 2),
    );
  }

  void _showNotice({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
      borderColor: const Color(0xFFEAE1DC),
      borderWidth: 1,
      margin: const EdgeInsets.all(12),
      icon: const Icon(
        Icons.info_outline_rounded,
        color: Colors.orange,
      ),
      duration: const Duration(seconds: 3),
    );
  }
}