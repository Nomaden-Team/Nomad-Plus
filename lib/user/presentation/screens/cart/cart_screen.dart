import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/cart/cart_controller.dart';
import '../../../controllers/order/order_controller.dart';
import '../../../core/app_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/formatters.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cart = Get.find<CartController>();
    final OrderController orderCtrl = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController(), permanent: true);
    final AppStateController appState = Get.find<AppStateController>();

    return GetBuilder<CartController>(
      init: cart,
      builder: (cart) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: false,
            titleSpacing: 8,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keranjang',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  appState.selectedBranch?.name ?? 'Cabang belum dipilih',
                  style: AppTextStyles.captionBold.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          body: cart.cartItems.isEmpty
              ? _EmptyCartState(branchName: appState.selectedBranch?.name)
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                        children: [
                          _StoreCard(
                            branchName:
                                appState.selectedBranch?.name ??
                                'Cabang belum dipilih',
                            address: appState.selectedBranch?.address ?? '',
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pilihan Kamu',
                                style: AppTextStyles.heading1.copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '${cart.totalQty} item',
                                style: AppTextStyles.bodySecondary.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ...cart.cartItems.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _CartItemCard(
                                item: item,
                                onDecrease: () =>
                                    cart.decreaseQty(item.entryId),
                                onIncrease: () =>
                                    cart.updateQty(item.entryId, item.qty + 1),
                                onRemove: () => cart.removeItem(item.entryId),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GetBuilder<OrderController>(
                      init: orderCtrl,
                      builder: (orderCtrl) {
                        return _CheckoutSummary(
                          subtotal: cart.subtotal,
                          total: cart.subtotal,
                          isLoading: orderCtrl.isLoading,
                          onCheckout: orderCtrl.goToCheckout,
                        );
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _StoreCard extends StatelessWidget {
  final String branchName;
  final String address;

  const _StoreCard({required this.branchName, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryDark.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: AppColors.primary,
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
                    color: AppColors.secondary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  branchName,
                  style: AppTextStyles.heading3.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                if (address.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    address,
                    style: AppTextStyles.bodySecondary.copyWith(
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutSummary extends StatelessWidget {
  final int subtotal;
  final int total;
  final bool isLoading;
  final VoidCallback onCheckout;

  const _CheckoutSummary({
    required this.subtotal,
    required this.total,
    required this.isLoading,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryRow(
                    label: 'Subtotal',
                    value: Formatters.currency(subtotal),
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'Total',
                    value: Formatters.currency(total),
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 158,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading ? null : onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  isLoading ? 'Memproses...' : 'Checkout',
                  style: AppTextStyles.button.copyWith(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isTotal) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.captionBold.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.priceLarge.copyWith(
              fontSize: 20,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySecondary.copyWith(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final menu = item.menuItem;
    final notes = item.notes.toString().trim();

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
          _MenuThumb(imageUrl: menu.imageUrl),
          const SizedBox(width: 14),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          menu.name,
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
                  if (notes.isNotEmpty)
                    Text(
                      notes,
                      style: AppTextStyles.bodySecondary.copyWith(
                        fontSize: 13,
                        height: 1.45,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      Formatters.currency(menu.price),
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
                          Formatters.currency(menu.price),
                          style: AppTextStyles.price.copyWith(fontSize: 16),
                        ),
                      ),
                      _QtyStepper(
                        qty: item.qty,
                        onDecrease: onDecrease,
                        onIncrease: onIncrease,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ),
          ),
        ],
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
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(icon: Icons.remove_rounded, onTap: onDecrease),
          SizedBox(
            width: 34,
            child: Center(
              child: Text(
                '$qty',
                style: AppTextStyles.heading3.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          _QtyButton(icon: Icons.add_rounded, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 26,
          height: 26,
          child: Icon(icon, size: 15, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _MenuThumb extends StatelessWidget {
  final String imageUrl;

  const _MenuThumb({required this.imageUrl});

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

class _EmptyCartState extends StatelessWidget {
  final String? branchName;

  const _EmptyCartState({this.branchName});

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
                  Icons.shopping_bag_outlined,
                  size: 34,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Keranjang kosong',
                style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                branchName == null
                    ? 'Tambahkan menu favoritmu terlebih dulu.'
                    : 'Belum ada item di keranjang untuk $branchName.',
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
