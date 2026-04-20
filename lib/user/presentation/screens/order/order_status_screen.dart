import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../controllers/cart/cart_controller.dart';
import '../../../controllers/order/order_controller.dart';
import '../../../controllers/voucher/voucher_controller.dart';
import '../../../core/app_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/models/order_model.dart';

class OrderStatusScreen extends StatefulWidget {
  const OrderStatusScreen({super.key});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  static const _steps = [
    (OrderStatus.pending, Icons.hourglass_bottom_rounded, 'MENUNGGU'),
    (OrderStatus.confirmed, Icons.restaurant_rounded, 'DIPROSES'),
    (OrderStatus.done, Icons.celebration_rounded, 'SELESAI'),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<OrderController>();
      final args = Get.arguments;

      if (args is OrderModel) {
        controller.openExistingOrder(args);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController(), permanent: true);

    final VoucherController voucherController =
        Get.isRegistered<VoucherController>()
        ? Get.find<VoucherController>()
        : Get.put(VoucherController());

    final cart = Get.find<CartController>();
    final appState = Get.find<AppStateController>();

    return GetBuilder<OrderController>(
      init: controller,
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: controller.isCheckoutMode
                ? _CheckoutMode(
                    controller: controller,
                    voucherController: voucherController,
                    cart: cart,
                    branchName:
                        appState.selectedBranch?.name ?? 'Cabang belum dipilih',
                    branchAddress: appState.selectedBranch?.address ?? '-',
                  )
                : controller.currentOrder == null
                ? const _EmptyOrderState()
                : _StatusMode(
                    order: controller.currentOrder!,
                    steps: _steps,
                    onBackHome: controller.goHome,
                  ),
          ),
        );
      },
    );
  }
}

class _CheckoutMode extends StatelessWidget {
  final OrderController controller;
  final VoucherController voucherController;
  final CartController cart;
  final String branchName;
  final String branchAddress;

  const _CheckoutMode({
    required this.controller,
    required this.voucherController,
    required this.cart,
    required this.branchName,
    required this.branchAddress,
  });

  Future<void> _showVoucherDialog(BuildContext context) async {
    if (controller.pointsToUse > 0) {
      _showError('Poin dan voucher tidak bisa digunakan bersamaan');
      return;
    }

    final textController = TextEditingController(
      text: voucherController.appliedVoucher.value?.code ?? '',
    );

    await Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Pakai Voucher',
          style: AppTextStyles.heading3.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: TextField(
          controller: textController,
          textCapitalization: TextCapitalization.characters,
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Masukkan kode voucher',
            hintStyle: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
            isDense: true,
            filled: true,
            fillColor: AppColors.surfaceGrey,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.secondary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Batal',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final message = await voucherController.applyVoucher(
                textController.text,
              );

              controller.refreshCheckout();

              if (message != null) {
                _showError(message);
                return;
              }

              Get.back();
              _showSuccess('Voucher berhasil dipakai');
            },
            child: Text(
              'Pakai',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitCheckout() async {
    final result = await controller.confirmOrder();

    if (result is OrderModel) {
      await _showPaymentSuccessDialog(result);
      return;
    }

    if (result is String && result.isNotEmpty) {
      _showError(result);
    }
  }

  Future<void> _showPaymentSuccessDialog(OrderModel order) async {
    await Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: _PaymentSuccessDialog(
          order: order,
          onTrackOrder: Get.back,
          onBackHome: () {
            Get.back();
            controller.goHome();
          },
        ),
      ),
    );
  }

  void _togglePoints(bool value) {
    if (!value) {
      controller.clearPoints();
      return;
    }

    if (voucherController.appliedVoucher.value != null) {
      _showError('Hapus voucher dulu sebelum menggunakan poin');
      return;
    }

    if (controller.maxPointsUsable <= 0) {
      _showError('Poin belum tersedia atau subtotal belum memenuhi');
      return;
    }

    controller.applyMaxPoints();
  }

  static void _showError(String message) {
    Get.snackbar(
      'Belum bisa digunakan',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: AppColors.textPrimary,
      borderColor: AppColors.cardBorder,
      borderWidth: 1,
      margin: const EdgeInsets.all(12),
      icon: const Icon(Icons.info_outline_rounded, color: AppColors.warning),
      duration: const Duration(seconds: 3),
    );
  }

  static void _showSuccess(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: AppColors.textPrimary,
      borderColor: AppColors.cardBorder,
      borderWidth: 1,
      margin: const EdgeInsets.all(12),
      icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appliedVoucher = voucherController.appliedVoucher.value;
    final appState = Get.find<AppStateController>();
    final bool isPointsOn = controller.pointsToUse > 0;
    final int pointsDiscountRupiah = controller.pointsToUse * 1000;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Row(
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: Text(
                  'Checkout',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.tertiaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            children: [
              _BranchCard(branchName: branchName, branchAddress: branchAddress),
              const SizedBox(height: 14),
              _CompactOrderPreview(cart: cart),
              const SizedBox(height: 24),
              Text(
                'Privileges',
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _PrivilegeRow(
                      iconBg: AppColors.tertiaryLight,
                      iconColor: AppColors.secondary,
                      icon: Icons.confirmation_number_outlined,
                      title: 'Apply Voucher',
                      subtitle: appliedVoucher == null
                          ? 'Pilih voucher yang tersedia'
                          : appliedVoucher.code,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (appliedVoucher != null)
                            GestureDetector(
                              onTap: () {
                                voucherController.clearAppliedVoucher();
                                controller.refreshCheckout();
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                      onTap: () => _showVoucherDialog(context),
                    ),
                    const SizedBox(height: 14),
                    _PrivilegeToggleRow(
                      iconBg: const Color(0xFFDDF0F7),
                      iconColor: const Color(0xFF2B80B9),
                      icon: Icons.local_offer_outlined,
                      title: 'Gunakan Poin',
                      subtitle: appState.isLoggedIn
                          ? 'Poin tersedia: ${Formatters.commas(appState.user.loyaltyPoints)} poin'
                          : 'Login dulu untuk menggunakan poin',
                      value: isPointsOn,
                      onChanged: _togglePoints,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        isPointsOn
                            ? 'Menggunakan ${Formatters.commas(controller.pointsToUse)} poin senilai ${Formatters.currency(pointsDiscountRupiah)}. Maksimal penggunaan poin adalah 10% subtotal pesanan ini.'
                            : 'Maksimal poin yang dapat digunakan adalah 10% subtotal pesanan ini.',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SectionCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: AppTextStyles.heading3.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _summaryRow(
                      'Subtotal',
                      Formatters.currency(controller.subtotalPreview),
                    ),
                    const SizedBox(height: 10),
                    _summaryRow(
                      'Diskon Voucher',
                      controller.voucherDiscountPreview > 0
                          ? '- ${Formatters.currency(controller.voucherDiscountPreview)}'
                          : '- Rp 0',
                      valueColor: controller.voucherDiscountPreview > 0
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 10),
                    _summaryRow(
                      'Poin digunakan',
                      '- ${Formatters.currency(pointsDiscountRupiah)}',
                      valueColor: pointsDiscountRupiah > 0
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            'TOTAL AKHIR',
                            style: AppTextStyles.captionBold.copyWith(
                              fontSize: 12,
                              letterSpacing: 0.6,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          Formatters.currency(controller.grandTotalPreview),
                          style: AppTextStyles.priceLarge.copyWith(
                            fontSize: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            (controller.pointsToUse > 0 ||
                                    controller.voucherDiscountPreview > 0)
                                ? 'Transaksi ini tidak mendapatkan poin baru.'
                                : 'Estimasi poin didapat: ${Formatters.commas(Get.find<AppStateController>().calculateEarnedPoints(controller.subtotalPreview))}',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          'Inclusive of Tax',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          color: AppColors.background,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: controller.isLoading ? null : _submitCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text(
                controller.isLoading
                    ? 'Mengonfirmasi...'
                    : 'Konfirmasi & Pesan',
                style: AppTextStyles.button.copyWith(fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 14),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _BranchCard extends StatelessWidget {
  final String branchName;
  final String branchAddress;

  const _BranchCard({required this.branchName, required this.branchAddress});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.tertiaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: AppColors.secondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PICKUP STORE',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  branchName,
                  style: AppTextStyles.heading3.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  branchAddress,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactOrderPreview extends StatelessWidget {
  final CartController cart;

  const _CompactOrderPreview({required this.cart});

  @override
  Widget build(BuildContext context) {
    final CartItem? firstItem = cart.cartItems.isNotEmpty
        ? cart.cartItems.first
        : null;

    if (firstItem == null) {
      return const SizedBox.shrink();
    }

    final remainingCount = cart.cartItems.length - 1;
    final notes = firstItem.notes.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryDark.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CartStyleItemImage(imageUrl: firstItem.menuItem.imageUrl),
          const SizedBox(width: 14),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 88),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          firstItem.menuItem.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.heading3.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        Formatters.currency(firstItem.subtotal),
                        style: AppTextStyles.heading3.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notes.isNotEmpty
                        ? notes
                        : Formatters.currency(firstItem.menuItem.price),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySecondary.copyWith(
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Formatters.currency(firstItem.menuItem.price),
                          style: AppTextStyles.price.copyWith(fontSize: 16),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Text(
                          'Qty ${firstItem.qty}',
                          style: AppTextStyles.captionBold.copyWith(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (remainingCount > 0) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+$remainingCount item lainnya',
                        style: AppTextStyles.captionBold.copyWith(
                          fontSize: 11,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivilegeRow extends StatelessWidget {
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  const _PrivilegeRow({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _PrivilegeToggleRow extends StatelessWidget {
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrivilegeToggleRow({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: AppColors.secondary,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFE0DAD5),
        ),
      ],
    );
  }
}

class _CheckoutItemTile extends StatelessWidget {
  final CartItem item;

  const _CheckoutItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryDark.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CartStyleItemImage(imageUrl: item.menuItem.imageUrl),
          const SizedBox(width: 14),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 88),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.menuItem.name,
                          style: AppTextStyles.heading3.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        Formatters.currency(item.subtotal),
                        style: AppTextStyles.heading3.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.notes.trim().isNotEmpty
                        ? item.notes.trim()
                        : Formatters.currency(item.menuItem.price),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySecondary.copyWith(
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Formatters.currency(item.menuItem.price),
                          style: AppTextStyles.price.copyWith(fontSize: 16),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Text(
                          'Qty ${item.qty}',
                          style: AppTextStyles.captionBold.copyWith(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartStyleItemImage extends StatelessWidget {
  final String imageUrl;

  const _CartStyleItemImage({required this.imageUrl});

  String _normalizeAssetPath(String raw) {
    final path = raw.trim();

    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    if (path.startsWith('assets/')) return path;
    if (path.startsWith('menu_images/')) return 'assets/$path';
    if (path.startsWith('promo/')) return 'assets/$path';
    return 'assets/menu_images/$path';
  }

  @override
  Widget build(BuildContext context) {
    final normalizedPath = _normalizeAssetPath(imageUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 88,
        height: 88,
        child: normalizedPath.isEmpty
            ? Container(
                color: AppColors.surfaceGrey,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.textHint,
                ),
              )
            : normalizedPath.startsWith('http')
            ? Image.network(
                normalizedPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surfaceGrey,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textHint,
                  ),
                ),
              )
            : Image.asset(
                normalizedPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surfaceGrey,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textHint,
                  ),
                ),
              ),
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  final String imageUrl;

  const _ItemImage({required this.imageUrl});

  String _normalizeAssetPath(String raw) {
    final path = raw.trim();

    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    if (path.startsWith('assets/')) return path;
    if (path.startsWith('menu_images/')) return 'assets/$path';
    if (path.startsWith('promo/')) return 'assets/$path';
    return 'assets/menu_images/$path';
  }

  @override
  Widget build(BuildContext context) {
    final normalizedPath = _normalizeAssetPath(imageUrl);

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: normalizedPath.isEmpty
          ? const Icon(Icons.image_outlined, color: AppColors.textHint)
          : normalizedPath.startsWith('http')
          ? Image.network(
              normalizedPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_outlined, color: AppColors.textHint),
            )
          : Image.asset(
              normalizedPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_outlined, color: AppColors.textHint),
            ),
    );
  }
}

class _PaymentSuccessDialog extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTrackOrder;
  final VoidCallback onBackHome;

  const _PaymentSuccessDialog({
    required this.order,
    required this.onTrackOrder,
    required this.onBackHome,
  });

  @override
  Widget build(BuildContext context) {
    final earnedText = order.pointsEarned > 0
        ? '+${order.pointsEarned} poin berhasil didapat'
        : 'Transaksi ini tidak menghasilkan poin baru.';

    final rewardDescription = order.pointsEarned > 0
        ? 'Poin sudah otomatis masuk ke akunmu dan bisa dipakai di transaksi berikutnya.'
        : 'Karena transaksi ini memakai promo atau potongan, poin baru tidak ditambahkan.';

    final qrData = jsonEncode({
      'order_id': order.id,
      'queue': order.queueNumber,
      'branch': order.branchName,
      'total': order.grandTotal,
      'items': order.items
          .map((e) => {'name': e.menuItem.name, 'qty': e.qty})
          .toList(),
    });

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryDark.withValues(alpha: 0.06),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientQueue,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Pesanan Berhasil!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading2.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tunjukkan QR ini ke kasir',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySecondary.copyWith(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 160,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Antrian',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '#${order.queueNumber}',
                            style: AppTextStyles.heading2.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.workspace_premium_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'POINT REWARD',
                                style: AppTextStyles.label.copyWith(
                                  fontSize: 10,
                                  letterSpacing: 0.9,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                earnedText,
                                style: AppTextStyles.heading3.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                rewardDescription,
                                style: AppTextStyles.bodySecondary.copyWith(
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.receipt_long_rounded,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Scan QR di kasir, lalu pantau status pesananmu di sini.',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: onTrackOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        'Pantau Pesanan',
                        style: AppTextStyles.button.copyWith(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: onBackHome,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      textStyle: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Kembali ke Beranda'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusMode extends StatelessWidget {
  final OrderModel order;
  final List<(OrderStatus, IconData, String)> steps;
  final VoidCallback onBackHome;

  const _StatusMode({
    required this.order,
    required this.steps,
    required this.onBackHome,
  });

  @override
  Widget build(BuildContext context) {
    // Map 'ready' to 'confirmed' index since we only show 3 steps
    final statusForStepper = order.status == OrderStatus.ready
        ? OrderStatus.confirmed
        : order.status;
    final currentIndex = steps.indexWhere((e) => e.$1 == statusForStepper);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: Text(
                  'Order Status',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.gradientQueue,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text(
                'Queue Number',
                style: AppTextStyles.captionBold.copyWith(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                order.queueNumber,
                style: AppTextStyles.display.copyWith(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _statusLabel(order.status),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _buildStepper(order.status, steps, currentIndex),
        const SizedBox(height: 10),
        if (order.status == OrderStatus.pending ||
            order.status == OrderStatus.confirmed ||
            order.status == OrderStatus.ready) ...[
          _QrCard(order: order),
          const SizedBox(height: 10),
        ],
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            children: [
              _SectionCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: AppTextStyles.heading3.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...order.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CheckoutItemTile(item: item),
                      ),
                    ),
                    const Divider(color: AppColors.divider),
                    _priceRow('Subtotal', Formatters.currency(order.subtotal)),
                    if (order.discountAmount > 0) ...[
                      const SizedBox(height: 8),
                      _priceRow(
                        'Diskon',
                        '- ${Formatters.currency(order.discountAmount)}',
                        color: AppColors.success,
                      ),
                    ],
                    if (order.pointsUsed > 0) ...[
                      const SizedBox(height: 8),
                      _priceRow(
                        'Poin Digunakan',
                        '- ${Formatters.currency(order.pointsUsed * 1000)}',
                        color: AppColors.secondary,
                      ),
                    ],
                    if ((order.voucherCode ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _priceRow('Voucher', order.voucherCode!),
                    ],
                    const SizedBox(height: 8),
                    _priceRow(
                      'Total',
                      Formatters.currency(order.grandTotal),
                      bold: true,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    _infoRow('Pickup', order.branchName),
                    _infoRow('Payment', order.paymentMethod),
                    _infoRow(
                      'Order Type',
                      order.orderType == 'dine_in' ? 'Dine In' : 'Takeaway',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onBackHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                'Back to Home',
                style: AppTextStyles.button.copyWith(fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepper(
    OrderStatus status,
    List<(OrderStatus, IconData, String)> steps,
    int currentIndex,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isActive = index <= currentIndex;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.secondary
                              : AppColors.surfaceGrey,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          step.$2,
                          color: isActive ? Colors.white : AppColors.textHint,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step.$3,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.captionBold.copyWith(
                          fontSize: 10,
                          color: isActive
                              ? AppColors.secondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 24,
                    height: 2,
                    color: index < currentIndex
                        ? AppColors.secondary
                        : AppColors.divider,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  static String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Tunjukkan QR ke kasir';
      case OrderStatus.confirmed:
        return 'Pesanan sedang diproses';
      case OrderStatus.ready:
        return 'Pesanan siap diambil! 🎉';
      case OrderStatus.done:
        return 'Pesanan selesai';
      case OrderStatus.cancelled:
        return 'Pesanan dibatalkan';
    }
  }
}

class _QrCard extends StatelessWidget {
  final OrderModel order;

  const _QrCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final qrData = jsonEncode({
      'order_id': order.id,
      'queue': order.queueNumber,
      'branch': order.branchName,
      'total': order.grandTotal,
      'items': order.items
          .map((e) => {'name': e.menuItem.name, 'qty': e.qty})
          .toList(),
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryDark.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.qr_code_rounded,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QR Code Pesanan',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Tunjukkan ke kasir untuk diproses',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 180,
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrderState extends StatelessWidget {
  const _EmptyOrderState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 34,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Belum ada data pesanan',
                style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pesanan yang sudah dibuat akan tampil di sini.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary.copyWith(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryDark.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surfaceGrey,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

Widget _priceRow(
  String label,
  String value, {
  bool bold = false,
  Color? color,
}) {
  final textColor = color ?? AppColors.textPrimary;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: bold ? 15 : 13,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
          color: bold ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: bold ? 18 : 14,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          color: textColor,
        ),
      ),
    ],
  );
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}
