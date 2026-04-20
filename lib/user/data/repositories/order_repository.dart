import '../datasources/order_remote.dart';
import '../models/order_model.dart';

class OrderRepository {
  final OrderRemote remote;

  OrderRepository(this.remote);

  Future<String> generateQueueNumber() {
    return remote.generateQueueNumber();
  }

  Future<OrderModel> createOrder(OrderModel order) {
    return remote.createOrder(order);
  }

  Future<List<OrderModel>> getOrders(String userId) {
    return remote.getOrdersByUser(userId);
  }
} 