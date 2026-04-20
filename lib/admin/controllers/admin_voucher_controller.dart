import 'package:get/get.dart';

import '../data/repositories/admin_voucher_repository.dart';

class AdminVoucherController extends GetxController {
  final AdminVoucherRepository repository;

  AdminVoucherController(this.repository);

  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxList<Map<String, dynamic>> vouchers = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchVouchers();
  }

  Future<void> fetchVouchers() async {
    try {
      isLoading.value = true;
      final response = await repository.fetchVouchers();
      vouchers.assignAll(response.map((e) => e.toMap()).toList());
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar(
        'Tidak bisa memuat data',
        message.isEmpty ? 'Daftar voucher belum berhasil dibuka.' : message,
      );
      Get.log('AdminVoucherController.fetchVouchers error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleVoucher({
    required String voucherId,
    required bool currentValue,
  }) async {
    try {
      await repository.updateVoucherStatus(
        voucherId: voucherId,
        isActive: !currentValue,
      );

      final index = vouchers.indexWhere((e) => e['id'].toString() == voucherId);
      if (index != -1) {
        final updated = Map<String, dynamic>.from(vouchers[index]);
        updated['is_active'] = !currentValue;
        vouchers[index] = updated;
      }

      Get.snackbar(
        'Berhasil',
        !currentValue ? 'Voucher diaktifkan.' : 'Voucher dinonaktifkan.',
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar(
        'Belum berhasil',
        message.isEmpty ? 'Status voucher belum bisa diperbarui.' : message,
      );
      Get.log('AdminVoucherController.toggleVoucher error: $e');
    }
  }

  Future<bool> saveVoucher({
    String? voucherId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      isSubmitting.value = true;

      await repository.saveVoucher(voucherId: voucherId, payload: payload);

      await fetchVouchers();

      // PERBAIKAN: Delay snackbar agar tidak "dimakan" oleh Get.back() dari UI
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          'Berhasil',
          voucherId == null || voucherId.isEmpty
              ? 'Voucher berhasil ditambahkan.'
              : 'Voucher berhasil diperbarui.',
        );
      });

      return true;
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      
      // Delay juga untuk error agar form bisa ditutup (jika UI menutup form saat error)
      // atau biarkan jika UI tidak melakukan Get.back() saat error
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          'Belum berhasil',
          message.isEmpty ? 'Voucher belum bisa disimpan.' : message,
        );
      });
      
      Get.log('AdminVoucherController.saveVoucher error: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> deleteVoucher(String voucherId) async {
    try {
      await repository.deleteVoucher(voucherId);
      vouchers.removeWhere((e) => e['id'].toString() == voucherId);
      Get.snackbar('Berhasil', 'Voucher berhasil dihapus.');
      return true;
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar(
        'Belum berhasil',
        message.isEmpty ? 'Voucher belum bisa dihapus.' : message,
      );
      Get.log('AdminVoucherController.deleteVoucher error: $e');
      return false;
    }
  }

  String formatDiscount(Map<String, dynamic> voucher) {
    final type = _normalizeUiType(voucher['type']);
    final value = _toInt(voucher['discount_value']);

    if (type == 'percent') {
      final maxDiscount = _toNullableInt(voucher['max_discount']);
      if (maxDiscount != null && maxDiscount > 0) {
        return '$value% maks Rp${_formatNumber(maxDiscount)}';
      }
      return '$value%';
    }

    return 'Rp${_formatNumber(value)}';
  }

  String _normalizeUiType(dynamic value) {
    final raw = (value ?? '').toString().trim().toLowerCase();
    if (raw == 'percent' || raw == 'percentage') return 'percent';
    return 'fixed';
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value.toString().trim();
    if (text.isEmpty) return 0;

    return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? 0;
  }

  int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value.toString().trim();
    if (text.isEmpty) return null;

    return int.tryParse(text) ?? double.tryParse(text)?.toInt();
  }

  String _formatNumber(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final positionFromEnd = text.length - i;
      buffer.write(text[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }
}