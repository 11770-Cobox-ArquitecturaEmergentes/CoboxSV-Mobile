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
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null) queryParams['status'] = status;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _client.get(
      Endpoints.orders,
      queryParameters: queryParams,
    );

    final data = response.data as Map<String, dynamic>;
    final list = (data['data'] as List<dynamic>?)
            ?.map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final total = data['total'] as int? ?? list.length;
    return (orders: list, total: total);
  }

  Future<OrderModel> getOrderDetail(String id) async {
    final response = await _client.get('${Endpoints.orders}/$id');
    final data = response.data as Map<String, dynamic>;
    final orderData = data['data'] as Map<String, dynamic>? ?? data;
    return OrderModel.fromJson(orderData);
  }

  Future<OrderModel> updateOrderStatus({
    required String id,
    required String status,
    String? notes,
    String? signature,
    List<String>? photoUrls,
  }) async {
    final body = <String, dynamic>{
      'status': status,
    };
    if (notes != null) body['notes'] = notes;
    if (signature != null) body['signature'] = signature;
    if (photoUrls != null && photoUrls.isNotEmpty) body['photoUrls'] = photoUrls;

    final response = await _client.patch(
      '${Endpoints.orders}/$id/status',
      data: body,
    );
    final data = response.data as Map<String, dynamic>;
    final orderData = data['data'] as Map<String, dynamic>? ?? data;
    return OrderModel.fromJson(orderData);
  }
}
