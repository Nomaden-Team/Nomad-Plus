import '../datasources/admin_order_remote.dart';
import '../models/admin_order_model.dart';

class AdminOrderRepository {
  final AdminOrderRemote remote;

  AdminOrderRepository(this.remote);

  Future<List<AdminOrderModel>> fetchOrdersByStatus(String status) =>
      remote.fetchOrdersByStatus(status);

  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) => remote.updateOrderStatus(orderId: orderId, newStatus: newStatus);
}
