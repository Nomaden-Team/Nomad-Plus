import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_state.dart';
import '../../data/datasources/voucher_remote.dart';
import '../../data/models/voucher_model.dart';
import '../../data/repositories/voucher_repository.dart';
import '../cart/cart_controller.dart';

class VoucherController extends GetxController {
  final AppStateController _appState = Get.find<AppStateController>();
  final CartController _cart = Get.find<CartController>();

  final VoucherRepository _repository = VoucherRepository(VoucherRemote());

  final vouchers = <VoucherModel>[].obs;
  final isLoading = false.obs;

  final appliedVoucher = Rxn<VoucherModel>();
  final discountAmount = 0.obs;

  final infoMessage = ''.obs;
  final emptyMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadVouchers();
  }

  Future<void> loadVouchers() async {
    try {
      isLoading.value = true;
      infoMessage.value = '';
      emptyMessage.value = '';

      final rawList = await _repository.fetchAllVouchers();
      vouchers.assignAll(rawList);

      if (rawList.isEmpty) {
        emptyMessage.value = 'Saat ini belum ada voucher yang siap digunakan.';
      }
    } catch (_) {
      vouchers.clear();
      infoMessage.value =
          'Daftar voucher belum bisa ditampilkan sekarang. Coba buka lagi beberapa saat.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> applyVoucher(String code) async {
    final normalized = code.trim().toUpperCase();

    if (normalized.isEmpty) {
      return 'Masukkan kode voucher terlebih dahulu';
    }

    if (_appState.checkoutPointsToUse > 0) {
      return 'Poin sedang digunakan. Matikan dulu poin untuk memakai voucher';
    }

    if (_cart.subtotal <= 0) {
      return 'Tambahkan pesanan terlebih dahulu sebelum memakai voucher';
    }

    try {
      final data = await _repository.validateVoucher(normalized);

      if (data == null) {
        return 'Kode voucher tidak ditemukan';
      }

      final voucher = VoucherModel.fromMap(data);

      final validationMessage = voucher.validate(
        _cart.subtotal,
        _appState.getUserVoucherUsageCount(voucher.code),
      );

      if (validationMessage != null) {
        return validationMessage;
      }

      final discount = voucher.calculateDiscount(_cart.subtotal);

      if (discount <= 0 && voucher.type != VoucherType.freeItem) {
        return 'Voucher ini belum bisa dipakai untuk pesananmu';
      }

      appliedVoucher.value = voucher;
      discountAmount.value = discount;

      return null;
    } on PostgrestException catch (e) {
      return _mapVoucherDbMessage(e);
    } on FormatException catch (e) {
      return e.message;
    } catch (_) {
      return 'Voucher belum bisa diproses sekarang. Coba lagi sebentar lagi';
    }
  }

  void clearAppliedVoucher() {
    appliedVoucher.value = null;
    discountAmount.value = 0;
  }

  List<VoucherModel> get activeVouchers =>
      vouchers.where((v) => v.isValid).toList();

  List<VoucherModel> get expiredVouchers =>
      vouchers.where((v) => !v.isValid).toList();

  bool isUsedByCurrentUser(VoucherModel voucher) {
    return _appState.getUserVoucherUsageCount(voucher.code) >=
        voucher.usagePerUser;
  }

  String _mapVoucherDbMessage(PostgrestException e) {
    if (e.code == '42703') {
      return 'Pengaturan voucher belum lengkap, jadi belum bisa dipakai';
    }

    if (e.code == '42501') {
      return 'Akses voucher sedang dibatasi. Coba lagi beberapa saat';
    }

    return 'Voucher belum bisa diproses sekarang. Coba lagi beberapa saat';
  }
}
