import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/order/order_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_model.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController(), permanent: true);

    return GetBuilder<OrderController>(
      init: controller,
      builder: (controller) {
        final orders = controller.orders;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                    ),
                  )
                : orders.isEmpty
                ? const _EmptyState()
                : _OrderHistoryContent(orders: orders),
          ),
        );
      },
    );
  }
}

class _OrderHistoryContent extends StatefulWidget {
  final List<OrderModel> orders;

  const _OrderHistoryContent({required this.orders});

  @override
  State<_OrderHistoryContent> createState() => _OrderHistoryContentState();
}

class _OrderHistoryContentState extends State<_OrderHistoryContent> {
  int selectedTab = 0;

  List<OrderModel> get filteredOrders {
    switch (selectedTab) {
      case 1:
        return widget.orders.where((o) => o.status.isActive).toList();
      case 2:
        return widget.orders.where((o) => !o.status.isActive).toList();
      default:
        return widget.orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        const _HistoryHeader(),
        const SizedBox(height: 18),
        _HistoryTabBar(
          selectedTab: selectedTab,
          onChanged: (value) => setState(() => selectedTab = value),
        ),
        const SizedBox(height: 18),
        if (filteredOrders.isEmpty)
          const _FilteredEmptyState()
        else
          ...filteredOrders.map((order) => _HistoryCard(order: order)),
      ],
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: AppColors.gradientQueue,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORDER HISTORY',
                  style: AppTextStyles.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.80),
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Riwayat Pesananmu',
                  style: AppTextStyles.heading2.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lihat pesanan yang sedang berjalan dan yang sudah selesai.',
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.white.withValues(alpha: 0.86),
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

class _HistoryTabBar extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onChanged;

  const _HistoryTabBar({required this.selectedTab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryDark.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _FilterChip(
              label: 'Semua',
              selected: selectedTab == 0,
              onTap: () => onChanged(0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _FilterChip(
              label: 'Proses',
              selected: selectedTab == 1,
              onTap: () => onChanged(1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _FilterChip(
              label: 'Selesai',
              selected: selectedTab == 2,
              onTap: () => onChanged(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surfaceSoft,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.cardBorder,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilteredEmptyState extends StatelessWidget {
  const _FilteredEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.inbox_rounded,
                color: AppColors.textHint,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada pesanan di kategori ini',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading3.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba pindah filter untuk melihat riwayat pesanan lainnya.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary.copyWith(
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
                'Belum ada pesanan',
                style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mulai pesan dan nikmati menu favoritmu di Nomad.',
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

class _HistoryCard extends StatelessWidget {
  final OrderModel order;

  const _HistoryCard({required this.order});

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.done:
        return AppColors.teal;
      case OrderStatus.cancelled:
        return AppColors.primary;
      case OrderStatus.pending:
      case OrderStatus.confirmed:
      case OrderStatus.ready:
        return AppColors.warning;
    }
  }

  Color get _statusBg {
    switch (order.status) {
      case OrderStatus.done:
        return AppColors.tealLight;
      case OrderStatus.cancelled:
        return AppColors.primarySoft;
      case OrderStatus.pending:
      case OrderStatus.confirmed:
      case OrderStatus.ready:
        return const Color(0xFFFFF4DE);
    }
  }

  IconData get _statusIcon {
    switch (order.status) {
      case OrderStatus.pending:
        return Icons.hourglass_bottom_rounded;
      case OrderStatus.confirmed:
        return Icons.restaurant_rounded;
      case OrderStatus.ready:
        return Icons.notifications_active_rounded;
      case OrderStatus.done:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.close_rounded;
    }
  }

  String get _statusLabel {
    switch (order.status) {
      case OrderStatus.pending:
        return 'MENUNGGU';
      case OrderStatus.confirmed:
        return 'DIPROSES';
      case OrderStatus.ready:
        return 'SIAP';
      case OrderStatus.done:
        return 'SELESAI';
      case OrderStatus.cancelled:
        return 'DIBATALKAN';
    }
  }

  String get _itemSummary {
    if (order.items.isEmpty) return 'Tidak ada item';
    return order.items.map((e) => '${e.qty}x ${e.menuItem.name}').join(', ');
  }

  String get _dateText {
    final d = order.createdAt;
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy • $hh:$min';
  }

  void _openOrderDetail() {
    Get.toNamed(AppRoutes.orderStatus, arguments: order);
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final extraCount = order.items.length - 1;

    return GestureDetector(
      onTap: _openOrderDetail,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OrderThumb(imageUrl: firstItem?.menuItem.imageUrl ?? ''),
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
                                order.branchName.isNotEmpty
                                    ? order.branchName
                                    : 'Nomad Branch',
                                style: AppTextStyles.heading3.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: _statusBg,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _statusIcon,
                                    size: 13,
                                    color: _statusColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _statusLabel,
                                    style: AppTextStyles.captionBold.copyWith(
                                      fontSize: 10,
                                      color: _statusColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _dateText,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _itemSummary,
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
                                Formatters.currency(order.grandTotal),
                                style: AppTextStyles.price.copyWith(
                                  fontSize: 17,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            if (extraCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSoft,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.cardBorder,
                                  ),
                                ),
                                child: Text(
                                  '+$extraCount item',
                                  style: AppTextStyles.captionBold.copyWith(
                                    fontSize: 11,
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
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.receipt_outlined,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Lihat detail pesanan',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderThumb extends StatelessWidget {
  final String imageUrl;

  const _OrderThumb({required this.imageUrl});

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
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 88,
        height: 88,
        child: normalizedPath.isEmpty
            ? Container(
                color: AppColors.surfaceGrey,
                child: const Icon(
                  Icons.local_cafe_rounded,
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