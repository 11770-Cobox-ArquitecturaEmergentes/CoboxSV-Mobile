import 'package:cobox_sv_mobile/core/api/dio_client.dart';
import 'package:cobox_sv_mobile/core/api/endpoints.dart';
import 'package:cobox_sv_mobile/features/orders/data/models/order_model.dart';

class OrderRemoteDataSource {
  final DioClient _client;

  OrderRemoteDataSource(this._client);

  Future<({List<OrderModel> orders, int total})> getOrders({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    final response = await _client.get(Endpoints.orders);
    if (response.data is! List) {
      throw const FormatException('Invalid orders response');
    }

    var orders = (response.data as List<dynamic>)
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();

    if (status != null && status.isNotEmpty) {
      orders = orders.where((order) => order.status == status).toList();
    }

    if (search != null && search.isNotEmpty) {
      final normalizedSearch = search.toLowerCase();
      orders = orders.where((order) {
        return order.orderNumber.toLowerCase().contains(normalizedSearch) ||
            order.clientName.toLowerCase().contains(normalizedSearch) ||
            order.deliveryAddress.fullAddress
                .toLowerCase()
                .contains(normalizedSearch);
      }).toList();
    }

    final total = orders.length;
    final start = ((page - 1) * limit).clamp(0, total).toInt();
    final end = (start + limit).clamp(0, total).toInt();
    final pagedOrders = orders.sublist(start, end);

    return (orders: pagedOrders, total: total);
  }

  Future<OrderModel> getOrderDetail(String id) async {
    final response = await _client.get('${Endpoints.orders}/$id');
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OrderModel> updateOrderStatus({
    required String id,
    required String status,
    String? notes,
    String? signature,
    List<String>? photoUrls,
  }) async {
    final body = <String, dynamic>{};
    if (notes != null) body['notes'] = notes;
    if (signature != null) body['signature'] = signature;
    if (photoUrls != null && photoUrls.isNotEmpty) body['photoUrls'] = photoUrls;

    final endpoint = switch (status) {
      'completed' => '${Endpoints.orders}/$id/completed',
      'in_progress' => '${Endpoints.orders}/$id/in-transit',
      'assigned' => '${Endpoints.orders}/$id/ready-for-dispatch',
      _ => '${Endpoints.orders}/$id',
    };

    final payload = switch (status) {
      'completed' => {
          'routeId': 0,
          'photoUrl': (photoUrls != null && photoUrls.isNotEmpty)
              ? photoUrls.first
              : '',
          'receiverName': notes ?? 'Entrega confirmada',
          'signatureData': signature ?? '',
        },
      _ => body,
    };

    final response = await _client.patch(endpoint, data: payload);
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }
}
