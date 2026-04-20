import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/cart/cart_controller.dart';
import '../../../controllers/menu/menu_detail_controller.dart';
import '../../../controllers/order/order_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/formatters.dart';

double _rs(BuildContext context, double size) {
  final width = MediaQuery.of(context).size.width;
  final scale = (width / 390).clamp(0.86, 1.12);
  return size * scale;
}

class MenuDetailSheet extends StatelessWidget {
  final MenuDetailController controller;

  const MenuDetailSheet({super.key, required this.controller});

  Future<void> _handleRedeemFlow(BuildContext context) async {
    final confirmed = await Get.dialog<bool>(
      _RedeemConfirmDialog(controller: controller),
      barrierDismissible: true,
    );

    if (confirmed != true) return;

    final error = await controller.redeemWithPoints();
    if (error != null) {
      Get.snackbar('Gagal', error, snackPosition: SnackPosition.TOP);
      return;
    }

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    Get.back();

    await Get.dialog(
      _RedeemSuccessDialog(
        itemName: controller.item.name,
        pointsUsed: controller.totalRedeemPoints,
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return GetBuilder<MenuDetailController>(
      init: controller,
      global: false,
      builder: (controller) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: _rs(context, 10)),
                Container(
                  width: _rs(context, 56),
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                SizedBox(height: _rs(context, 14)),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      _rs(context, 14),
                      0,
                      _rs(context, 14),
                      _rs(context, 14),
                    ),
                    child: Column(
                      children: [
                        _HeroImageSection(
                          imageUrl: controller.item.imageUrl,
                          isRedeemMode: controller.isRedeemMode,
                        ),
                        SizedBox(height: _rs(context, 14)),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              _rs(context, 28),
                            ),
                            border: Border.all(color: AppColors.cardBorder),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondaryDark.withValues(
                                  alpha: 0.06,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  _rs(context, 18),
                                  _rs(context, 18),
                                  _rs(context, 18),
                                  _rs(context, 10),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            controller.isRedeemMode
                                                ? 'REWARD ITEM'
                                                : 'MENU DETAIL',
                                            style: AppTextStyles.label.copyWith(
                                              color: AppColors.textSecondary,
                                              letterSpacing: 0.9,
                                              fontSize: _rs(context, 11),
                                            ),
                                          ),
                                          SizedBox(height: _rs(context, 8)),
                                          Text(
                                            controller.item.name,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.heading1
                                                .copyWith(
                                                  fontSize: _rs(context, 28),
                                                  fontWeight: FontWeight.w900,
                                                  height: 1.05,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: _rs(context, 12)),
                                    Flexible(
                                      child: _PriceBadge(
                                        isRedeemMode: controller.isRedeemMode,
                                        label: controller.isRedeemMode
                                            ? '${Formatters.commas(controller.redeemUnitPoints)} poin'
                                            : Formatters.currency(
                                                controller.unitPrice,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  _rs(context, 18),
                                  0,
                                  _rs(context, 18),
                                  _rs(context, 18),
                                ),
                                child: Text(
                                  controller.item.description.trim().isNotEmpty
                                      ? controller.item.description.trim()
                                      : 'Expertly brewed dan dibuat fresh dengan rasa khas Nomad.',
                                  style: AppTextStyles.bodySecondary.copyWith(
                                    fontSize: _rs(context, 13),
                                    height: 1.6,
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: AppColors.cardBorder,
                              ),
                              if (controller.isRedeemMode) ...[
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    _rs(context, 18),
                                    _rs(context, 16),
                                    _rs(context, 18),
                                    _rs(context, 18),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(_rs(context, 14)),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.tertiaryLight,
                                          AppColors.surface,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        _rs(context, 18),
                                      ),
                                      border: Border.all(
                                        color: AppColors.cardBorder,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: _rs(context, 34),
                                          height: _rs(context, 34),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary,
                                            borderRadius: BorderRadius.circular(
                                              _rs(context, 12),
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.workspace_premium_rounded,
                                            color: Colors.white,
                                            size: _rs(context, 18),
                                          ),
                                        ),
                                        SizedBox(width: _rs(context, 12)),
                                        Expanded(
                                          child: Text(
                                            'Reward ini hanya berlaku untuk 1 item per penukaran. Setelah dikonfirmasi, item akan masuk ke keranjang dengan harga Rp0.',
                                            style: AppTextStyles.captionBold
                                                .copyWith(
                                                  fontSize: _rs(context, 12),
                                                  height: 1.5,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ] else ...[
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    _rs(context, 18),
                                    _rs(context, 16),
                                    _rs(context, 18),
                                    _rs(context, 18),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (controller.isDrink) ...[
                                        const _SectionHeader(
                                          title: 'TEMPERATURE',
                                        ),
                                        SizedBox(height: _rs(context, 10)),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _ChoiceCard(
                                                label: 'Ice',
                                                selected:
                                                    controller
                                                        .drinkCustomization
                                                        .temperature ==
                                                    'ice',
                                                onTap: () => controller
                                                    .setTemperature('ice'),
                                              ),
                                            ),
                                            SizedBox(width: _rs(context, 10)),
                                            Expanded(
                                              child: _ChoiceCard(
                                                label: 'Hot',
                                                selected:
                                                    controller
                                                        .drinkCustomization
                                                        .temperature ==
                                                    'hot',
                                                onTap: () => controller
                                                    .setTemperature('hot'),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: _rs(context, 18)),
                                        if (controller
                                                .drinkCustomization
                                                .temperature ==
                                            'ice') ...[
                                          const _SectionHeader(
                                            title: 'ICE LEVEL',
                                          ),
                                          SizedBox(height: _rs(context, 10)),
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: _ChoiceCard(
                                                      label: 'Less Ice',
                                                      selected:
                                                          controller
                                                              .drinkCustomization
                                                              .iceLevel ==
                                                          'less',
                                                      onTap: () => controller
                                                          .setIceLevel('less'),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: _rs(context, 10),
                                                  ),
                                                  Expanded(
                                                    child: _ChoiceCard(
                                                      label: 'Normal Ice',
                                                      selected:
                                                          controller
                                                              .drinkCustomization
                                                              .iceLevel ==
                                                          'normal',
                                                      onTap: () => controller
                                                          .setIceLevel(
                                                            'normal',
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: _rs(context, 10),
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: _ChoiceCard(
                                                      label: 'More Ice',
                                                      selected:
                                                          controller
                                                              .drinkCustomization
                                                              .iceLevel ==
                                                          'more',
                                                      onTap: () => controller
                                                          .setIceLevel('more'),
                                                    ),
                                                  ),
                                                  const Expanded(
                                                    child: SizedBox(),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: _rs(context, 18)),
                                        ],
                                        const _SectionHeader(
                                          title: 'SUGAR LEVEL',
                                        ),
                                        SizedBox(height: _rs(context, 10)),
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _ChoiceCard(
                                                    label: 'Normal Sugar',
                                                    selected:
                                                        controller
                                                            .drinkCustomization
                                                            .sugarLevel ==
                                                        'normal',
                                                    onTap: () => controller
                                                        .setSugarLevel(
                                                          'normal',
                                                        ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: _rs(context, 10),
                                                ),
                                                Expanded(
                                                  child: _ChoiceCard(
                                                    label: 'Less Sugar',
                                                    selected:
                                                        controller
                                                            .drinkCustomization
                                                            .sugarLevel ==
                                                        'less',
                                                    onTap: () => controller
                                                        .setSugarLevel('less'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: _rs(context, 10)),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _ChoiceCard(
                                                    label: 'More Sugar',
                                                    selected:
                                                        controller
                                                            .drinkCustomization
                                                            .sugarLevel ==
                                                        'more',
                                                    onTap: () => controller
                                                        .setSugarLevel('more'),
                                                  ),
                                                ),
                                                const Expanded(
                                                  child: SizedBox(),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: _rs(context, 18)),
                                      ],
                                      if (controller.isFoodCustomizable) ...[
                                        const _SectionHeader(
                                          title: 'LEVEL PEDAS',
                                        ),
                                        SizedBox(height: _rs(context, 10)),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _ChoiceCard(
                                                label: 'Tidak Pedas',
                                                selected: !controller
                                                    .foodCustomization
                                                    .isSpicy,
                                                onTap: () =>
                                                    controller.setSpicy(false),
                                              ),
                                            ),
                                            SizedBox(width: _rs(context, 10)),
                                            Expanded(
                                              child: _ChoiceCard(
                                                label: 'Pedas',
                                                selected: controller
                                                    .foodCustomization
                                                    .isSpicy,
                                                onTap: () =>
                                                    controller.setSpicy(true),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: _rs(context, 18)),
                                        const _SectionHeader(title: 'ADD-ON'),
                                        SizedBox(height: _rs(context, 10)),
                                        _AddOnCard(
                                          label: 'Tambah Egg',
                                          priceLabel:
                                              '+ ${Formatters.currency(5000)}',
                                          selected: controller
                                              .foodCustomization
                                              .addEgg,
                                          onTap: () => controller.setAddEgg(
                                            !controller
                                                .foodCustomization
                                                .addEgg,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: AppColors.background,
                  padding: EdgeInsets.fromLTRB(
                    _rs(context, 14),
                    _rs(context, 10),
                    _rs(context, 14),
                    bottomPadding > 0
                        ? bottomPadding + _rs(context, 8)
                        : _rs(context, 16),
                  ),
                  child: controller.isRedeemMode
                      ? SizedBox(
                          width: double.infinity,
                          height: _rs(context, 56),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: AppColors.gradientLuxury,
                              borderRadius: BorderRadius.circular(
                                _rs(context, 18),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.18,
                                  ),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () => _handleRedeemFlow(context),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    _rs(context, 18),
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: _rs(context, 14),
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'TUKARKAN • ${Formatters.commas(controller.totalRedeemPoints)} poin',
                                  style: AppTextStyles.button.copyWith(
                                    fontSize: _rs(context, 15),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            Flexible(
                              flex: 0,
                              child: _QtyStepper(
                                qty: controller.qty,
                                onDecrease: controller.decrement,
                                onIncrease: controller.increment,
                              ),
                            ),
                            SizedBox(width: _rs(context, 12)),
                            Expanded(
                              child: SizedBox(
                                height: _rs(context, 56),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.gradientPrimarySoft,
                                    borderRadius: BorderRadius.circular(
                                      _rs(context, 18),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.18,
                                        ),
                                        blurRadius: 14,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: controller.addToCart,
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          _rs(context, 18),
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: _rs(context, 12),
                                      ),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'TAMBAH • ${Formatters.currency(controller.totalPrice)}',
                                        style: AppTextStyles.button.copyWith(
                                          fontSize: _rs(context, 15),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PriceBadge extends StatelessWidget {
  final bool isRedeemMode;
  final String label;

  const _PriceBadge({required this.isRedeemMode, required this.label});

  @override
  Widget build(BuildContext context) {
    final isRedeem = isRedeemMode;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _rs(context, 12),
        vertical: _rs(context, 9),
      ),
      decoration: BoxDecoration(
        color: isRedeem ? AppColors.tealLight : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(_rs(context, 14)),
        border: Border.all(
          color: isRedeem
              ? AppColors.secondary.withValues(alpha: 0.14)
              : AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: AppTextStyles.price.copyWith(
            color: isRedeem ? AppColors.teal : AppColors.primary,
            fontSize: _rs(context, 14),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _RedeemConfirmDialog extends StatelessWidget {
  final MenuDetailController controller;

  const _RedeemConfirmDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_rs(context, 24)),
      ),
      titlePadding: EdgeInsets.fromLTRB(
        _rs(context, 20),
        _rs(context, 20),
        _rs(context, 20),
        _rs(context, 10),
      ),
      contentPadding: EdgeInsets.fromLTRB(
        _rs(context, 20),
        0,
        _rs(context, 20),
        _rs(context, 8),
      ),
      actionsPadding: EdgeInsets.fromLTRB(
        _rs(context, 16),
        0,
        _rs(context, 16),
        _rs(context, 16),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Konfirmasi Penukaran',
            style: AppTextStyles.heading3.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: _rs(context, 20),
            ),
          ),
          SizedBox(height: _rs(context, 6)),
          Text(
            'Pastikan detail reward sudah sesuai sebelum ditukarkan.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
              fontSize: _rs(context, 12),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(_rs(context, 14)),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(_rs(context, 16)),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.item.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: _rs(context, 16),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: _rs(context, 12)),
                _dialogRow(context, 'Jumlah', '1 item'),
                _dialogRow(
                  context,
                  'Poin dipakai',
                  '${Formatters.commas(controller.totalRedeemPoints)} poin',
                ),
              ],
            ),
          ),
          SizedBox(height: _rs(context, 14)),
          Text(
            'Setelah dikonfirmasi, item akan masuk ke keranjang dengan harga Rp0 dan poin akan langsung dipotong.',
            style: AppTextStyles.caption.copyWith(
              fontSize: _rs(context, 12),
              height: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(
            'Batal',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: _rs(context, 14),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.gradientLuxury,
            borderRadius: BorderRadius.circular(_rs(context, 14)),
          ),
          child: ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_rs(context, 14)),
              ),
            ),
            child: Text(
              'Konfirmasi Tukar',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: _rs(context, 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dialogRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: _rs(context, 6)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: _rs(context, 13),
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.captionBold.copyWith(
                fontSize: _rs(context, 13),
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RedeemSuccessDialog extends StatelessWidget {
  final String itemName;
  final int pointsUsed;

  const _RedeemSuccessDialog({
    required this.itemName,
    required this.pointsUsed,
  });

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_rs(context, 24)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          _rs(context, 20),
          _rs(context, 22),
          _rs(context, 20),
          _rs(context, 18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _rs(context, 68),
              height: _rs(context, 68),
              decoration: BoxDecoration(
                gradient: AppColors.gradientLuxury,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: _rs(context, 36),
              ),
            ),
            SizedBox(height: _rs(context, 16)),
            Text(
              'Penukaran Berhasil',
              style: AppTextStyles.heading2.copyWith(
                fontSize: _rs(context, 20),
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: _rs(context, 8)),
            Text(
              '$itemName berhasil ditukar dengan ${Formatters.commas(pointsUsed)} poin.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary.copyWith(
                fontSize: _rs(context, 13),
                height: 1.5,
              ),
            ),
            SizedBox(height: _rs(context, 6)),
            Text(
              'Item sudah masuk ke keranjang dan siap dilanjutkan ke checkout.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary.copyWith(
                fontSize: _rs(context, 13),
                height: 1.5,
              ),
            ),
            SizedBox(height: _rs(context, 18)),
            SizedBox(
              width: double.infinity,
              height: _rs(context, 52),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimarySoft,
                  borderRadius: BorderRadius.circular(_rs(context, 16)),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    if (cart.isEmpty) return;
                    Get.find<OrderController>().goToCheckout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_rs(context, 16)),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Lanjut ke Checkout',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: _rs(context, 14),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: _rs(context, 8)),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Nanti Saja',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: _rs(context, 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroImageSection extends StatelessWidget {
  final String imageUrl;
  final bool isRedeemMode;

  const _HeroImageSection({required this.imageUrl, required this.isRedeemMode});

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
    final height = (MediaQuery.of(context).size.width * 0.60).clamp(
      210.0,
      280.0,
    );

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_rs(context, 28)),
        gradient: isRedeemMode
            ? AppColors.gradientLuxury
            : AppColors.gradientQueue,
        boxShadow: [
          BoxShadow(
            color: (isRedeemMode ? AppColors.secondary : AppColors.primary)
                .withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: _buildImage()),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.04),
                    Colors.black.withValues(alpha: 0.14),
                    Colors.black.withValues(alpha: 0.48),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: _rs(context, 16),
            right: _rs(context, 16),
            bottom: _rs(context, 16),
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: _rs(context, 12),
                      vertical: _rs(context, 8),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(_rs(context, 14)),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isRedeemMode ? 'REDEEM REWARD' : 'CUSTOMIZE ORDER',
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white,
                          fontSize: _rs(context, 10),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final normalizedPath = _normalizeAssetPath(imageUrl);

    if (normalizedPath.isEmpty) return _placeholder();

    if (normalizedPath.startsWith('http')) {
      return Image.network(
        normalizedPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return Image.asset(
      normalizedPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceGrey,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 44,
        color: AppColors.textHint,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.label.copyWith(
        fontSize: _rs(context, 11),
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = selected;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(_rs(context, 16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_rs(context, 16)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: _rs(context, 58),
          padding: EdgeInsets.symmetric(horizontal: _rs(context, 12)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_rs(context, 16)),
            color: active ? AppColors.primarySoft : AppColors.surface,
            border: Border.all(
              color: active ? AppColors.primary : AppColors.cardBorder,
              width: active ? 1.4 : 1,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: _rs(context, 13),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(width: _rs(context, 8)),
              Container(
                width: _rs(context, 18),
                height: _rs(context, 18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.textHint,
                    width: 1.6,
                  ),
                ),
                child: active
                    ? Center(
                        child: Container(
                          width: _rs(context, 8),
                          height: _rs(context, 8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddOnCard extends StatelessWidget {
  final String label;
  final String priceLabel;
  final bool selected;
  final VoidCallback onTap;

  const _AddOnCard({
    required this.label,
    required this.priceLabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = selected;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(_rs(context, 16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_rs(context, 16)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: _rs(context, 14),
            vertical: _rs(context, 15),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_rs(context, 16)),
            color: active ? AppColors.primarySoft : AppColors.surface,
            border: Border.all(
              color: active ? AppColors.primary : AppColors.cardBorder,
              width: active ? 1.4 : 1,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: _rs(context, 13),
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(width: _rs(context, 8)),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    priceLabel,
                    style: AppTextStyles.captionBold.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      fontSize: _rs(context, 12.5),
                    ),
                  ),
                ),
              ),
              SizedBox(width: _rs(context, 10)),
              Container(
                width: _rs(context, 18),
                height: _rs(context, 18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.textHint,
                    width: 1.6,
                  ),
                ),
                child: active
                    ? Center(
                        child: Container(
                          width: _rs(context, 8),
                          height: _rs(context, 8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QtyStepper({
    required this.qty,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _rs(context, 56),
      padding: EdgeInsets.symmetric(horizontal: _rs(context, 6)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_rs(context, 18)),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryDark.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(icon: Icons.remove_rounded, onTap: onDecrease),
          SizedBox(
            width: _rs(context, 36),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$qty',
                  style: AppTextStyles.heading3.copyWith(
                    fontSize: _rs(context, 16),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          _StepperButton(icon: Icons.add_rounded, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceSoft,
      borderRadius: BorderRadius.circular(_rs(context, 12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_rs(context, 12)),
        child: SizedBox(
          width: _rs(context, 36),
          height: _rs(context, 36),
          child: Icon(
            icon,
            size: _rs(context, 18),
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
