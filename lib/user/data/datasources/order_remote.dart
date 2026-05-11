import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/supabase_service.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';

class OrderRemote {
  final SupabaseClient client = SupabaseService.client;

  Future<String> generateQueueNumber() async {
    final now = DateTime.now();
    return "A${now.hour}${now.minute}${now.second}";
  }

  Future<OrderModel> createOrder(OrderModel order) async {
    final payload = {
      'user_id': order.userId,
      'branch_id': order.branchId,
      'queue_number': order.queueNumber,
      'status': _toDbStatus(order.status),
      'payment_method': order.paymentMethod,
      'subtotal': order.subtotal,
      'discount_amount': order.discountAmount,
      'service_fee': order.serviceFee,
      'grand_total': order.grandTotal,
      'points_earned': order.pointsEarned,
      'points_used': order.pointsUsed,
      'voucher_code': order.voucherCode,
      'order_type': order.orderType,
      'notes': order.notes,
      'created_at': DateTime.now().toIso8601String(),
    };

    print('=== PAYLOAD ORDER ===');
    print(payload);

    try {
      final orderRes = await client
          .from('orders')
          .insert(payload)
          .select()
          .single();

      final orderId = orderRes['id'].toString();

      for (final item in order.items) {
        await client.from('order_items').insert({
          'order_id': orderId,
          'menu_item_id': item.menuItem.id,
          'quantity': item.qty,
          'notes': item.notes,
          'price': item.unitPrice,
        });
      }

      // ─── Kurangi poin user jika ada poin yang dipakai ───────────────────────
      // SESUAIKAN: ganti 'profiles' dengan nama tabel user kamu
      //            ganti 'points' dengan nama kolom poin kamu
      if (order.pointsUsed > 0) {
        try {
          // Ambil poin user saat ini
          final userRes = await client
              .from('profiles') // <-- SESUAIKAN nama tabel
              .select('points') // <-- SESUAIKAN nama kolom poin
              .eq('id', order.userId)
              .single();

          final currentPoints = _toInt(userRes['points']); // <-- SESUAIKAN nama kolom poin
          final newPoints = (currentPoints - order.pointsUsed).clamp(0, double.maxFinite.toInt());

          await client
              .from('profiles') // <-- SESUAIKAN nama tabel
              .update({'points': newPoints}) // <-- SESUAIKAN nama kolom poin
              .eq('id', order.userId);

          print('=== POIN DIKURANGI ===');
          print('Sebelum : $currentPoints');
          print('Dipakai : ${order.pointsUsed}');
          print('Sesudah : $newPoints');
        } catch (e) {
          // Jangan gagalkan order hanya karena update poin gagal
          // Tapi tetap log supaya bisa dideteksi
          print('=== GAGAL UPDATE POIN USER ===');
          print(e);
        }
      }

      // ─── Tambahkan poin earned ke user ──────────────────────────────────────
      if (order.pointsEarned > 0) {
        try {
          final userRes = await client
              .from('profiles') // <-- SESUAIKAN nama tabel
              .select('points') // <-- SESUAIKAN nama kolom poin
              .eq('id', order.userId)
              .single();

          final currentPoints = _toInt(userRes['points']); // <-- SESUAIKAN nama kolom poin
          final newPoints = currentPoints + order.pointsEarned;

          await client
              .from('profiles') // <-- SESUAIKAN nama tabel
              .update({'points': newPoints}) // <-- SESUAIKAN nama kolom poin
              .eq('id', order.userId);

          print('=== POIN DITAMBAHKAN ===');
          print('Sebelum : $currentPoints');
          print('Earned  : ${order.pointsEarned}');
          print('Sesudah : $newPoints');
        } catch (e) {
          print('=== GAGAL TAMBAH POIN EARNED ===');
          print(e);
        }
      }

      return order.copyWith(id: orderId);
    } on PostgrestException catch (e) {
      print('=== POSTGREST ERROR ===');
      print('message : ${e.message}');
      print('code    : ${e.code}');
      print('details : ${e.details}');
      print('hint    : ${e.hint}');
      rethrow;
    } catch (e) {
      print('=== UNKNOWN ERROR ===');
      print(e);
      rethrow;
    }
  }

  Future<List<OrderModel>> getOrdersByUser(String userId) async {
    print('=== FETCHING ORDERS FOR USER: $userId ===');

    try {
      final response = await client
          .from('orders')
          .select('''
            *,
            branches (name),
            order_items (
              *,
              menu_items (
                *,
                categories (name)
              )
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final rawList = response as List;
      print('=== TOTAL ORDERS DITEMUKAN: ${rawList.length} ===');

      if (rawList.isEmpty) {
        print('=== TIDAK ADA ORDER — cek RLS policy di Supabase untuk tabel orders, order_items, menu_items, categories ===');
        return [];
      }

      final orders = <OrderModel>[];

      for (final e in rawList) {
        try {
          final itemsRaw = e['order_items'] as List? ?? [];
          print('--- Order ID: ${e['id']} | Jumlah items: ${itemsRaw.length}');

          // Jika order_items kosong padahal harusnya ada, kemungkinan RLS tabel order_items
          // memblokir akses. Cek policy SELECT di tabel order_items di Supabase dashboard.
          final items = <CartItem>[];

          for (final item in itemsRaw) {
            try {
              final menu = item['menu_items'] as Map<String, dynamic>?;

              if (menu == null) {
                // Lewati item ini saja, jangan gagalkan seluruh order
                print('!!! SKIP item ${item['id']} — menu_items null (cek RLS tabel menu_items)');
                continue;
              }

              final category = menu['categories'];

              final menuItem = MenuItem(
                id: menu['id'].toString(),
                branchId: menu['branch_id'].toString(),
                categoryId: menu['category_id'].toString(),
                name: menu['name'],
                description: menu['description'] ?? '',
                price: _toInt(menu['price']),
                imageUrl: menu['image_url'] ?? '',
                isAvailable: menu['is_available'] ?? true,
                orderCount: _toInt(menu['order_count']),
                categoryName: category is Map ? (category['name'] ?? '') : '',
              );

              final notes = (item['notes'] ?? '').toString();
              final unitPrice = _toInt(item['price']);

              items.add(CartItem(
                entryId: CartItem.entryKey(menuItem.id, 'history', notes: notes),
                menuItem: menuItem,
                qty: _toInt(item['quantity']),
                notes: notes,
                unitPrice: unitPrice,
                customizationKey: 'history',
              ));
            } catch (itemErr) {
              // Lewati item yang error, jangan crash seluruh list
              print('!!! ERROR parsing item ${item['id']}: $itemErr');
              continue;
            }
          }

          orders.add(OrderModel(
            id: e['id'].toString(),
            userId: e['user_id'].toString(),
            queueNumber: e['queue_number'] ?? '',
            branchId: e['branch_id'] ?? '',
            branchName: e['branches']?['name'] ?? '',
            items: items,
            paymentMethod: (e['payment_method'] ?? 'NomadPay').toString(),
            status: _parseStatus(e['status']),
            createdAt: DateTime.parse(e['created_at']),
            subtotal: _toInt(e['subtotal']),
            discountAmount: _toInt(e['discount_amount']),
            serviceFee: _toInt(e['service_fee']),
            grandTotal: _toInt(e['grand_total']),
            pointsEarned: _toInt(e['points_earned']),
            pointsUsed: _toInt(e['points_used']),
            voucherCode: e['voucher_code']?.toString(),
            orderType: e['order_type'] ?? 'dine_in',
            notes: e['notes'],
          ));
        } catch (orderErr) {
          // Lewati order yang error, jangan crash seluruh list
          print('!!! ERROR parsing order ${e['id']}: $orderErr');
          continue;
        }
      }

      print('=== BERHASIL PARSE ${orders.length} ORDERS ===');
      return orders;
    } on PostgrestException catch (e) {
      print('=== POSTGREST ERROR getOrdersByUser ===');
      print('message : ${e.message}');
      print('code    : ${e.code}');
      print('details : ${e.details}');
      print('hint    : ${e.hint}');
      rethrow;
    } catch (e) {
      print('=== UNKNOWN ERROR getOrdersByUser ===');
      print(e);
      rethrow;
    }
  }

  String _toDbStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return 'diproses';
      case OrderStatus.ready:
        return 'siap';
      case OrderStatus.done:
        return 'selesai';
      case OrderStatus.cancelled:
        return 'dibatalkan';
      default:
        return 'menunggu';
    }
  }

  OrderStatus _parseStatus(String? value) {
    switch (value) {
      case 'diproses':
        return OrderStatus.confirmed;
      case 'siap':
        return OrderStatus.ready;
      case 'selesai':
        return OrderStatus.done;
      case 'dibatalkan':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }
}