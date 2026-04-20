import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../user/core/constants/app_colors.dart';
import '../../../../user/core/constants/app_text_styles.dart';

class AdminOrderDetailScreen extends StatelessWidget {
  const AdminOrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = Map<String, dynamic>.from(Get.arguments ?? {});
    final userData = _asMap(order['users']);
    final branchData = _asMap(order['branches']);

    final queueNumber = (order['queue_number'] ?? '-').toString();
    final orderId = (order['id'] ?? '-').toString();
    final customerName = (userData['name'] ?? 'Tanpa Nama').toString();
    final customerEmail = (userData['email'] ?? '-').toString();
    final branchName = (branchData['name'] ?? '-').toString();
    final status = (order['status'] ?? '-').toString();
    final subtotalValue = _toDouble(order['subtotal']);
    final discountValue = _toDouble(order['discount_amount']);
    final totalValue = _toDouble(order['grand_total']);
    final orderType = (order['order_type'] ?? '-').toString();
    final createdAt = (order['created_at'] ?? '-').toString();

    final serviceFeeValue = _toDouble(order['service_fee']);
    final taxValue = _toDouble(order['tax']);
    final pointsEarned = (order['points_earned'] ?? '').toString();
    final pointsUsed = (order['points_used'] ?? '').toString();
    final voucherCode = (order['voucher_code'] ?? '').toString();

    final itemsRaw = order['order_items'];
    final List<Map<String, dynamic>> orderItems = itemsRaw is List
        ? itemsRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList()
        : [];

    final bool hasOrderItems = orderItems.isNotEmpty;
    final bool hasLoyaltyInfo =
        voucherCode.isNotEmpty ||
        (pointsEarned.isNotEmpty && pointsEarned != '0') ||
        (pointsUsed.isNotEmpty && pointsUsed != '0');

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
                    onPressed: Get.back,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Detail Pesanan',
                      style: AppTextStyles.heading3.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.8,
                      ),
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _HeaderCard(
            queueNumber: queueNumber,
            status: status,
            orderType: orderType,
            branchName: branchName,
            createdAt: createdAt,
          ),
          const SizedBox(height: 16),

          if (hasOrderItems) ...[
            const _SectionTitle(
              title: 'ITEM PESANAN',
              icon: Icons.receipt_long_outlined,
            ),
            const SizedBox(height: 10),
            ...orderItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _OrderItemCard(item: item),
              ),
            ),
            const SizedBox(height: 4),
          ],

          _InfoCard(
            title: 'INFORMASI PELANGGAN',
            accentIcon: Icons.person_outline_rounded,
            child: _CustomerBlock(
              customerName: customerName,
              customerEmail: customerEmail,
              orderId: orderId,
            ),
          ),
          const SizedBox(height: 14),

          if (hasLoyaltyInfo) ...[
            _InfoCard(
              title: 'LOYALTY & PROMO',
              accentIcon: Icons.local_offer_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (voucherCode.isNotEmpty)
                    _RewardRow(
                      label: 'Voucher',
                      value: voucherCode.toUpperCase(),
                    ),
                  if (pointsEarned.isNotEmpty && pointsEarned != '0')
                    _RewardRow(
                      label: 'Poin Didapat',
                      value: '+$pointsEarned pts',
                      valueColor: AppColors.success,
                    ),
                  if (pointsUsed.isNotEmpty && pointsUsed != '0')
                    _RewardRow(
                      label: 'Poin Dipakai',
                      value: '$pointsUsed pts',
                      valueColor: AppColors.primary,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          _InfoCard(
            title: 'RINGKASAN PEMBAYARAN',
            accentIcon: Icons.payments_outlined,
            child: Column(
              children: [
                _BillRow(
                  label: 'Subtotal',
                  value: _formatCurrency(subtotalValue),
                ),
                if (serviceFeeValue > 0)
                  _BillRow(
                    label: 'Biaya Layanan',
                    value: _formatCurrency(serviceFeeValue),
                  ),
                if (taxValue > 0)
                  _BillRow(
                    label: 'Pajak',
                    value: _formatCurrency(taxValue),
                  ),
                _BillRow(
                  label: 'Diskon Voucher',
                  value: discountValue > 0
                      ? '-${_formatCurrency(discountValue)}'
                      : _formatCurrency(0),
                  valueColor: discountValue > 0 ? AppColors.primary : null,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.cardBorder),
                ),
                _BillRow(
                  label: 'TOTAL',
                  value: _formatCurrency(totalValue),
                  isBold: true,
                  labelSize: 16,
                  valueSize: 18,
                  valueColor: AppColors.primary,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pembayaran dikonfirmasi manual oleh admin cabang',
                        style: AppTextStyles.captionBold.copyWith(
                          fontSize: 12,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static String _formatCurrency(dynamic value) {
    final number = _toDouble(value).round();
    final text = number.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final positionFromEnd = text.length - i;
      buffer.write(text[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'Rp $buffer';
  }
}

class _HeaderCard extends StatelessWidget {
  final String queueNumber;
  final String status;
  final String orderType;
  final String branchName;
  final String createdAt;

  const _HeaderCard({
    required this.queueNumber,
    required this.status,
    required this.orderType,
    required this.branchName,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${orderType.toUpperCase()} • ${branchName.toUpperCase()}',
                  style: AppTextStyles.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontSize: 11,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              _StatusChip(status: status),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '#$queueNumber',
            style: AppTextStyles.display.copyWith(
              fontSize: 34,
              height: 1,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _formatDateTime(createdAt),
            style: AppTextStyles.bodySecondary.copyWith(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.84),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDateTime(String raw) {
    if (raw.isEmpty || raw == '-') return '-';

    try {
      final dt = DateTime.parse(raw).toLocal();
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      final day = dt.day.toString().padLeft(2, '0');
      final month = _monthName(dt.month);
      final year = dt.year.toString();

      return 'Dibuat $hour:$minute • $day $month $year';
    } catch (_) {
      return raw;
    }
  }

  static String _monthName(int month) {
    const names = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return names[month];
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    Color bg;
    Color fg;
    String label;

    switch (normalized) {
      case 'menunggu':
        bg = Colors.white.withValues(alpha: 0.16);
        fg = Colors.white;
        label = 'MENUNGGU';
        break;
      case 'diproses':
        bg = Colors.white.withValues(alpha: 0.16);
        fg = Colors.white;
        label = 'DIPROSES';
        break;
      case 'selesai':
        bg = const Color(0xFFEAF7EC);
        fg = AppColors.success;
        label = 'SELESAI';
        break;

      default:
        bg = Colors.white.withValues(alpha: 0.16);
        fg = Colors.white;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.captionBold.copyWith(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;

  const _SectionTitle({required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
        ],
        Text(
          title,
          style: AppTextStyles.label.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _OrderItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final name = (item['name'] ?? item['menu_name'] ?? 'Menu Item').toString();
    final qty = (item['qty'] ?? item['quantity'] ?? 1).toString();
    final note = (item['note'] ?? item['notes'] ?? '').toString();
    final imageUrl = (item['image_url'] ?? item['image'] ?? '').toString();

    final rawOptions = item['options'];
    final List<String> options = rawOptions is List
        ? rawOptions
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList()
        : [];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryDark.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ItemImage(imageUrl: imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'x$qty',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '"$note"',
                    style: AppTextStyles.bodySecondary.copyWith(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (options.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: options
                        .map((e) => _OptionChip(label: e))
                        .toList(),
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

class _ItemImage extends StatelessWidget {
  final String imageUrl;

  const _ItemImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.fastfood_rounded,
        color: AppColors.textHint,
        size: 28,
      ),
    );

    if (imageUrl.isEmpty) return box;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        imageUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => box,
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String label;

  const _OptionChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5F4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.captionBold.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.secondary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? accentIcon;

  const _InfoCard({
    required this.title,
    required this.child,
    this.accentIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryDark.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (accentIcon != null) ...[
                Icon(accentIcon, size: 15, color: AppColors.primary),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: AppTextStyles.label.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _CustomerBlock extends StatelessWidget {
  final String customerName;
  final String customerEmail;
  final String orderId;

  const _CustomerBlock({
    required this.customerName,
    required this.customerEmail,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _buildInitials(customerName);

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customerName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                customerEmail == '-' ? 'Order #$orderId' : customerEmail,
                style: AppTextStyles.bodySecondary.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _buildInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || name.trim().isEmpty) return 'NA';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}

class _RewardRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _RewardRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodySecondary.copyWith(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  final double labelSize;
  final double valueSize;

  const _BillRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
    this.labelSize = 15,
    this.valueSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTextStyles.bodyMedium.copyWith(
      fontSize: labelSize,
      color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
      fontWeight: isBold ? FontWeight.w900 : FontWeight.w500,
    );

    final valueStyle = AppTextStyles.bodyMedium.copyWith(
      fontSize: valueSize,
      color: valueColor ?? AppColors.textPrimary,
      fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}