import 'package:cobox_sv_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:cobox_sv_mobile/shared/enums/order_status.dart';

abstract class OrderRepository {
  Future<({List<OrderEntity> orders, int total})> getOrders({
    int page = 1,
    int limit = 20,
    OrderStatus? status,
    String? search,
  });

  Future<OrderEntity> getOrderDetail(String id);

  Future<OrderEntity> updateOrderStatus({
    required String id,
    required OrderStatus status,
    String? notes,
    String? signature,
    List<String>? photoUrls,
  });
}
