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
  final userUsageByVoucherId = <String, int>{}.obs;

  final isLoading = false.obs;

  final appliedVoucher = Rxn<VoucherModel>();
  final discountAmount = 0.obs;

  final infoMessage = ''.obs;
  final emptyMessage = ''.obs;

  bool _lastLoginState = false;
  String? _lastBranchId;

  @override
  void onInit() {
    super.onInit();

    _lastLoginState = _appState.isLoggedIn;
    _lastBranchId = _appState.selectedBranchId;

    _appState.addListener(_handleAppStateChanged);

    loadVouchers();
  }

  void _handleAppStateChanged() {
    final isLoggedIn = _appState.isLoggedIn;
    final currentBranchId = _appState.selectedBranchId;

    if (!isLoggedIn && _lastLoginState) {
      _lastLoginState = false;
      _lastBranchId = null;

      vouchers.clear();
      userUsageByVoucherId.clear();
      clearAppliedVoucher();

      return;
    }

    if (isLoggedIn && !_lastLoginState) {
      _lastLoginState = true;
      _lastBranchId = currentBranchId;

      loadVouchers();
      return;
    }

    if (isLoggedIn && currentBranchId != _lastBranchId) {
      _lastBranchId = currentBranchId;

      clearAppliedVoucher();
      loadVouchers();
    }
  }

  Future<void> loadVouchers() async {
    try {
      isLoading.value = true;
      infoMessage.value = '';
      emptyMessage.value = '';

      if (!_appState.isLoggedIn) {
        vouchers.clear();
        userUsageByVoucherId.clear();
        emptyMessage.value = 'Login diperlukan untuk melihat voucher.';
        return;
      }

      final branchId = _appState.selectedBranchId?.trim() ?? '';

      if (branchId.isEmpty) {
        vouchers.clear();
        emptyMessage.value = 'Pilih cabang terlebih dahulu untuk melihat voucher.';
        return;
      }

      await refreshUserVoucherUsages();

      final list = await _repository.fetchAllVouchers(branchId: branchId);
      vouchers.assignAll(list);

      if (list.isEmpty) {
        emptyMessage.value = 'Saat ini belum ada voucher untuk cabang ini.';
      }
    } catch (e) {
      vouchers.clear();
      infoMessage.value =
          'Daftar voucher belum bisa ditampilkan sekarang. Coba buka lagi beberapa saat.';
      Get.log('loadVouchers error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshUserVoucherUsages() async {
    if (!_appState.isLoggedIn) {
      userUsageByVoucherId.clear();
      return;
    }

    try {
      final usageMap = await _repository.getUserUsageCountMapByVoucherId(
        _appState.user.id,
      );

      userUsageByVoucherId.assignAll(usageMap);
    } catch (e) {
      Get.log('refreshUserVoucherUsages error: $e');
    }
  }

  Future<void> incrementVoucherUsage(String code) async {
    try {
      final branchId = _appState.selectedBranchId?.trim() ?? '';

      if (branchId.isEmpty) {
        Get.log('Gagal update kuota voucher: cabang belum dipilih');
        return;
      }

      final voucherData = await _repository.validateVoucher(
        code,
        branchId: branchId,
      );

      if (voucherData == null) return;

      final voucherId = voucherData['id'].toString();

      await _repository.remote.incrementVoucherUsedCount(voucherId);
      await loadVouchers();
    } catch (e) {
      Get.log('Gagal update kuota voucher: $e');
    }
  }

  Future<String?> applyVoucher(String code) async {
    final normalized = code.trim().toUpperCase();

    if (normalized.isEmpty) {
      return 'Masukkan kode voucher terlebih dahulu';
    }

    if (!_appState.isLoggedIn) {
      return 'Kamu harus login dulu untuk memakai voucher';
    }

    final branchId = _appState.selectedBranchId?.trim() ?? '';

    if (branchId.isEmpty) {
      return 'Pilih cabang terlebih dahulu untuk memakai voucher';
    }

    if (_appState.checkoutPointsToUse > 0) {
      return 'Poin sedang digunakan. Matikan dulu poin untuk memakai voucher';
    }

    if (_cart.subtotal <= 0) {
      return 'Tambahkan pesanan terlebih dahulu sebelum memakai voucher';
    }

    try {
      final data = await _repository.validateVoucher(
        normalized,
        branchId: branchId,
      );

      if (data == null) {
        return 'Voucher tidak tersedia untuk cabang ini';
      }

      final voucher = VoucherModel.fromMap(data);

      final userUsageCount = await _repository.getUserUsageCount(
        voucherId: voucher.id,
        userId: _appState.user.id,
      );

      userUsageByVoucherId[voucher.id] = userUsageCount;

      final validationMessage = voucher.validate(
        _cart.subtotal,
        userUsageCount,
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
    } catch (e) {
      Get.log('applyVoucher error: $e');
      return 'Voucher belum bisa diproses sekarang. Coba lagi sebentar lagi';
    }
  }

  Future<String?> validateAppliedVoucherForCheckout() async {
    final voucher = appliedVoucher.value;

    if (voucher == null) return null;

    final message = await applyVoucher(voucher.code);

    if (message != null) {
      clearAppliedVoucher();
    }

    return message;
  }

  Future<bool> finalizeVoucherUsage(String orderId) async {
    final voucher = appliedVoucher.value;

    if (voucher == null) return true;

    try {
      await _repository.markVoucherAsUsed(
        voucherId: voucher.id,
        userId: _appState.user.id,
        orderId: orderId,
      );

      await loadVouchers();

      return true;
    } catch (e) {
      Get.log('Error finalizeVoucherUsage: $e');
      return false;
    }
  }

  void clearAppliedVoucher() {
    appliedVoucher.value = null;
    discountAmount.value = 0;
  }

  int getUserUsageCount(VoucherModel voucher) {
    return userUsageByVoucherId[voucher.id] ?? 0;
  }

  List<VoucherModel> get activeVouchers {
    return vouchers.where((v) => v.isValid).toList();
  }

  List<VoucherModel> get expiredVouchers {
    return vouchers.where((v) => !v.isValid).toList();
  }

  bool isUsedByCurrentUser(VoucherModel voucher) {
    return getUserUsageCount(voucher) >= voucher.usagePerUser;
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

  @override
  void onClose() {
    _appState.removeListener(_handleAppStateChanged);
    super.onClose();
  }
}