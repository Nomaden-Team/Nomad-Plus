import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controllers/admin_home_controller.dart';
import '../../../controllers/admin_voucher_controller.dart';
import '../../../core/routes/admin_routes.dart';
import '../../../../user/core/constants/app_colors.dart';
import '../../../../user/core/constants/app_text_styles.dart';

class AdminVoucherFormScreen extends StatefulWidget {
  const AdminVoucherFormScreen({super.key});

  @override
  State<AdminVoucherFormScreen> createState() => _AdminVoucherFormScreenState();
}

class _AdminVoucherFormScreenState extends State<AdminVoucherFormScreen> {
  final AdminVoucherController voucherController =
      Get.find<AdminVoucherController>();

  final formKey = GlobalKey<FormState>();

  late final TextEditingController codeCtrl;
  late final TextEditingController nameCtrl;
  late final TextEditingController discountValueCtrl;
  late final TextEditingController maxDiscountCtrl;
  late final TextEditingController minTransactionCtrl;
  late final TextEditingController usageLimitCtrl;
  late final TextEditingController usagePerUserCtrl;
  late final TextEditingController startDateCtrl;
  late final TextEditingController expiryDateCtrl;

  final RxString discountType = 'fixed'.obs; // fixed | percent
  final RxBool isActive = true.obs;

  final List<String> discountTypes = const ['fixed', 'percent'];

  String voucherId = '';
  bool get isEdit => voucherId.isNotEmpty;

  @override
  void initState() {
    super.initState();

    codeCtrl = TextEditingController();
    nameCtrl = TextEditingController();
    discountValueCtrl = TextEditingController();
    maxDiscountCtrl = TextEditingController();
    minTransactionCtrl = TextEditingController();
    usageLimitCtrl = TextEditingController();
    usagePerUserCtrl = TextEditingController();
    startDateCtrl = TextEditingController();
    expiryDateCtrl = TextEditingController();

    final args = Get.arguments as Map<String, dynamic>?;
    final voucher = args?['voucher'] as Map<String, dynamic>?;

    voucherId = (args?['id'] ?? voucher?['id'] ?? '').toString();
    if (voucher != null) {
      _fillForm(voucher);
    } else {
      _setDefaultForm();
    }
  }

  @override
  void dispose() {
    codeCtrl.dispose();
    nameCtrl.dispose();
    discountValueCtrl.dispose();
    maxDiscountCtrl.dispose();
    minTransactionCtrl.dispose();
    usageLimitCtrl.dispose();
    usagePerUserCtrl.dispose();
    startDateCtrl.dispose();
    expiryDateCtrl.dispose();
    super.dispose();
  }

  void _setDefaultForm() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 7));

    codeCtrl.clear();
    nameCtrl.clear();
    discountValueCtrl.clear();
    maxDiscountCtrl.clear();
    minTransactionCtrl.clear();
    usageLimitCtrl.clear();
    usagePerUserCtrl.clear();
    startDateCtrl.text = _dateOnly(start.toIso8601String());
    expiryDateCtrl.text = _dateOnly(end.toIso8601String());
    discountType.value = 'fixed';
    isActive.value = true;
  }

  void _fillForm(Map<String, dynamic> voucher) {
    codeCtrl.text = (voucher['code'] ?? '').toString();
    nameCtrl.text = (voucher['name'] ?? '').toString();
    discountValueCtrl.text = _toInt(voucher['discount_value']).toString();
    maxDiscountCtrl.text =
        _toNullableInt(voucher['max_discount'])?.toString() ?? '';
    minTransactionCtrl.text = _toInt(voucher['min_order_value']).toString();
    usageLimitCtrl.text =
        _toNullableInt(voucher['usage_limit'])?.toString() ?? '';
    usagePerUserCtrl.text =
        _toNullableInt(voucher['usage_per_user'])?.toString() ?? '';
    startDateCtrl.text = _dateOnly(voucher['start_date']);
    expiryDateCtrl.text = _dateOnly(voucher['expiry_date']);
    discountType.value = _normalizeUiType(voucher['type']);
    isActive.value = voucher['is_active'] == true;
  }

  Future<void> _submitForm() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!(formKey.currentState?.validate() ?? false)) {
      Get.snackbar(
        'Input belum valid',
        'Periksa kembali field yang masih error.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade50,
        colorText: Colors.orange.shade900,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final payload = <String, dynamic>{
      'name': nameCtrl.text.trim(),
      'code': codeCtrl.text.trim().toUpperCase(),
      'type': discountType.value == 'percent' ? 'percentage' : 'fixed',
      'discount_value': int.tryParse(discountValueCtrl.text.trim()) ?? 0,
      'max_discount': discountType.value == 'percent'
          ? (maxDiscountCtrl.text.trim().isEmpty
                ? null
                : int.tryParse(maxDiscountCtrl.text.trim()))
          : null,
      'min_order_value': int.tryParse(minTransactionCtrl.text.trim()) ?? 0,
      'usage_limit': usageLimitCtrl.text.trim().isEmpty
          ? null
          : int.tryParse(usageLimitCtrl.text.trim()),
      'usage_per_user': usagePerUserCtrl.text.trim().isEmpty
          ? null
          : int.tryParse(usagePerUserCtrl.text.trim()),
      'start_date': _dateOnly(startDateCtrl.text),
      'expiry_date': _dateOnly(expiryDateCtrl.text),
      'is_active': isActive.value,
      'used_count': isEdit ? null : 0,
    };
    final success = await voucherController.saveVoucher(
      voucherId: isEdit ? voucherId : null,
      payload: payload,
    );

    if (success) {
      Get.back();
      voucherController.fetchVouchers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.isRegistered<AdminHomeController>()
        ? Get.find<AdminHomeController>()
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(82),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondaryDark,
                AppColors.secondary,
                AppColors.primaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Get.offAllNamed(AdminRoutes.vouchers);
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: homeController == null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'FORM VOUCHER',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isEdit ? 'Edit Voucher' : 'Tambah Voucher',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.heading3.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Obx(() {
                            final branchName = homeController.branchName.value
                                .trim();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 14,
                                      color: Colors.white70,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'CABANG AKTIF',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  branchName.isEmpty
                                      ? (isEdit
                                            ? 'Edit Voucher'
                                            : 'Tambah Voucher')
                                      : branchName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.heading3.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            );
                          }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Informasi Utama'),
                const SizedBox(height: 12),
                _buildFormCard([
                  _buildTextField(
                    label: 'Deskripsi Voucher',
                    controller: nameCtrl,
                    hint: 'Contoh: Diskon Weekend 10% min. Rp50.000',
                    helper: 'Nama voucher wajib jelas.',
                    icon: Icons.description_outlined,
                    maxLength: 80,
                    validator: _validateVoucherName,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Kode Voucher',
                    controller: codeCtrl,
                    hint: 'Contoh: NOMADHEMAT',
                    helper:
                        'Hanya huruf, angka, strip, dan underscore. Tanpa spasi.',
                    icon: Icons.confirmation_number_outlined,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 20,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[A-Z0-9\-_a-z]'),
                      ),
                      UpperCaseTextFormatter(),
                    ],
                    validator: _validateVoucherCode,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(),
                ]),
                const SizedBox(height: 24),

                _buildSectionTitle('Detail Diskon'),
                const SizedBox(height: 12),
                _buildFormCard([
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => _buildTextField(
                            label: discountType.value == 'percent'
                                ? 'Diskon (%)'
                                : 'Diskon Nominal',
                            controller: discountValueCtrl,
                            hint: '0',
                            helper: discountType.value == 'percent'
                                ? 'Contoh 10 untuk diskon 10%.'
                                : 'Contoh 10000 untuk potongan Rp10.000.',
                            icon: discountType.value == 'percent'
                                ? Icons.percent_rounded
                                : Icons.payments_outlined,
                            keyboardType: TextInputType.number,
                            maxLength: 9,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) => _validateDiscountValue(
                              value,
                              discountType.value,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => _buildTextField(
                            label: 'Maks. Potongan',
                            controller: maxDiscountCtrl,
                            hint: discountType.value == 'percent'
                                ? 'Wajib diisi'
                                : 'Kosongkan',
                            helper: discountType.value == 'percent'
                                ? 'Wajib untuk voucher persen.'
                                : 'Tidak dipakai untuk voucher nominal.',
                            icon: Icons.price_change_outlined,
                            keyboardType: TextInputType.number,
                            maxLength: 9,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) =>
                                _validateMaxDiscount(value, discountType.value),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 24),

                _buildSectionTitle('Syarat Penggunaan'),
                const SizedBox(height: 12),
                _buildFormCard([
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Min. Transaksi',
                          controller: minTransactionCtrl,
                          hint: '0',
                          helper: 'Minimal belanja untuk pakai voucher.',
                          icon: Icons.shopping_bag_outlined,
                          keyboardType: TextInputType.number,
                          maxLength: 9,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: _validateMinTransaction,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'Kuota Voucher',
                          controller: usageLimitCtrl,
                          hint: 'Opsional',
                          helper: 'Kosongkan jika tidak dibatasi.',
                          icon: Icons.confirmation_number_outlined,
                          keyboardType: TextInputType.number,
                          maxLength: 9,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: _validateUsageLimit,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Kuota per User',
                    controller: usagePerUserCtrl,
                    hint: 'Opsional',
                    helper: 'Kosongkan jika tidak dibatasi per user.',
                    icon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validateUsagePerUser,
                  ),
                ]),
                const SizedBox(height: 24),

                _buildSectionTitle('Periode Voucher'),
                const SizedBox(height: 12),
                _buildFormCard([
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker(
                          context,
                          label: 'Tanggal Mulai',
                          controller: startDateCtrl,
                          validator: _validateStartDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDatePicker(
                          context,
                          label: 'Tanggal Kadaluarsa',
                          controller: expiryDateCtrl,
                          validator: (value) =>
                              _validateExpiryDate(value, startDateCtrl.text),
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 24),

                _buildSectionTitle('Pengaturan Status'),
                const SizedBox(height: 12),
                _buildStatusCard(),

                const SizedBox(height: 36),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateVoucherName(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Deskripsi voucher wajib diisi';
    if (text.length < 5) return 'Deskripsi voucher terlalu pendek';
    if (text.length > 80) return 'Deskripsi voucher maksimal 80 karakter';
    return null;
  }

  String? _validateVoucherCode(String? value) {
    final text = (value ?? '').trim().toUpperCase();
    if (text.isEmpty) return 'Kode voucher wajib diisi';
    if (text.contains(' ')) return 'Kode voucher tidak boleh mengandung spasi';
    if (text.length < 4) return 'Kode voucher minimal 4 karakter';
    if (text.length > 20) return 'Kode voucher maksimal 20 karakter';
    if (!RegExp(r'^[A-Z0-9\-_]+$').hasMatch(text)) {
      return 'Kode hanya boleh huruf, angka, strip, dan underscore';
    }
    return null;
  }

  String? _validateDiscountValue(String? value, String type) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Nilai diskon wajib diisi';

    final number = int.tryParse(text);
    if (number == null) return 'Nilai diskon harus berupa angka';
    if (number <= 0) return 'Nilai diskon harus lebih dari 0';

    if (type == 'percent') {
      if (number > 100) return 'Diskon persen maksimal 100';
    } else {
      if (number < 1000) return 'Diskon nominal minimal Rp1.000';
    }

    return null;
  }

  String? _validateMaxDiscount(String? value, String type) {
    final text = (value ?? '').trim();

    if (type == 'fixed') return null;
    if (text.isEmpty) return 'Maks. potongan wajib diisi untuk voucher persen';

    final number = int.tryParse(text);
    if (number == null) return 'Maks. potongan harus berupa angka';
    if (number < 1000) return 'Maks. potongan minimal Rp1.000';

    return null;
  }

  String? _validateMinTransaction(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Minimum transaksi wajib diisi';

    final number = int.tryParse(text);
    if (number == null) return 'Minimum transaksi harus berupa angka';
    if (number < 0) return 'Minimum transaksi tidak boleh minus';

    return null;
  }

  String? _validateUsageLimit(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;

    final number = int.tryParse(text);
    if (number == null) return 'Kuota voucher harus berupa angka';
    if (number <= 0) return 'Kuota voucher minimal 1';

    return null;
  }

  String? _validateUsagePerUser(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;

    final number = int.tryParse(text);
    if (number == null) return 'Kuota per user harus berupa angka';
    if (number <= 0) return 'Kuota per user minimal 1';

    return null;
  }

  String? _validateStartDate(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Tanggal mulai wajib diisi';
    if (DateTime.tryParse(text) == null)
      return 'Format tanggal mulai tidak valid';
    return null;
  }

  String? _validateExpiryDate(String? value, String startDate) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Tanggal kadaluarsa wajib diisi';

    final expiry = DateTime.tryParse(text);
    if (expiry == null) return 'Format tanggal tidak valid';

    final start = DateTime.tryParse(startDate);
    if (start == null) return 'Tanggal mulai belum valid';

    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedExpiry = DateTime(expiry.year, expiry.month, expiry.day);

    if (!normalizedExpiry.isAfter(normalizedStart)) {
      return 'Tanggal kadaluarsa harus setelah tanggal mulai';
    }

    return null;
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.heading3.copyWith(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    String? helper,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.captionBold.copyWith(fontSize: 13)),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(helper, style: AppTextStyles.caption.copyWith(fontSize: 12)),
        ],
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLength: maxLength,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: AppColors.surfaceSoft,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipe Diskon',
          style: AppTextStyles.captionBold.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          'Pilih apakah voucher berupa persen atau nominal rupiah.',
          style: AppTextStyles.caption.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 8),
        Obx(
          () => DropdownButtonFormField<String>(
            value: discountType.value,
            items: discountTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type == 'percent' ? 'PERCENT' : 'FIXED',
                  style: AppTextStyles.bodyMedium,
                ),
              );
            }).toList(),
            onChanged: (v) {
              if (v == null) return;
              discountType.value = v;
              if (v == 'fixed') {
                maxDiscountCtrl.clear();
              }
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.loyalty_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              filled: true,
              fillColor: AppColors.surfaceSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.captionBold.copyWith(fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          validator: validator,
          onTap: () async {
            final parsed = DateTime.tryParse(controller.text.trim());

            final safeFirstDate = DateTime(2020);
            final safeLastDate = DateTime(2035);

            DateTime initialDate;
            if (parsed != null) {
              initialDate = parsed;
            } else {
              final now = DateTime.now();
              initialDate = DateTime(now.year, now.month, now.day);
            }

            if (initialDate.isBefore(safeFirstDate)) {
              initialDate = safeFirstDate;
            }
            if (initialDate.isAfter(safeLastDate)) {
              initialDate = safeLastDate;
            }

            final picked = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: safeFirstDate,
              lastDate: safeLastDate,
            );

            if (picked != null) {
              controller.text = picked.toIso8601String().split('T').first;
            }
          },
          decoration: InputDecoration(
            hintText: 'Pilih tanggal',
            prefixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.surfaceSoft,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.tealLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Obx(
        () => SwitchListTile(
          value: isActive.value,
          onChanged: (v) => isActive.value = v,
          activeColor: AppColors.teal,
          title: Text(
            'Voucher Aktif',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.teal,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Text(
            isActive.value
                ? 'Voucher bisa langsung digunakan pelanggan.'
                : 'Voucher disimpan, tapi belum bisa digunakan.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: voucherController.isSubmitting.value ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: voucherController.isSubmitting.value
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.2,
                  ),
                )
              : Text(
                  isEdit ? 'SIMPAN PERUBAHAN' : 'BUAT VOUCHER',
                  style: AppTextStyles.button,
                ),
        ),
      ),
    );
  }

  String _normalizeUiType(dynamic value) {
    final raw = (value ?? '').toString().trim().toLowerCase();
    if (raw == 'percentage' || raw == 'percent') return 'percent';
    return 'fixed';
  }

  String _dateOnly(dynamic value) {
    final raw = (value ?? '').toString().trim();
    if (raw.isEmpty) return '';
    if (raw.contains('T')) return raw.split('T').first;
    if (raw.contains(' ')) return raw.split(' ').first;
    return raw;
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
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
