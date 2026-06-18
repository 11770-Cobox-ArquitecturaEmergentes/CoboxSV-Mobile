import 'package:cobox_sv_mobile/core/errors/error_handler.dart';
import 'package:cobox_sv_mobile/core/errors/exceptions.dart';
import 'package:cobox_sv_mobile/features/orders/data/datasource/order_remote_datasource.dart';
import 'package:cobox_sv_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:cobox_sv_mobile/features/orders/domain/repository/order_repository.dart';
import 'package:cobox_sv_mobile/shared/enums/order_status.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _dataSource;

  OrderRepositoryImpl(this._dataSource);

  @override
  Future<({List<OrderEntity> orders, int total})> getOrders({
    int page = 1,
    int limit = 20,
    OrderStatus? status,
    String? search,
  }) async {
    try {
      final result = await _dataSource.getOrders(
        page: page,
        limit: limit,
        status: status?.value,
        search: search,
      );
      return (
        orders: result.orders.map((e) => e.toEntity()).toList(),
        total: result.total,
      );
    } on AppException catch (e) {
      throw handleException(e);
    }
  }

  @override
  Future<OrderEntity> getOrderDetail(String id) async {
    try {
      final model = await _dataSource.getOrderDetail(id);
      return model.toEntity();
    } on AppException catch (e) {
      throw handleException(e);
    }
  }

  @override
  Future<OrderEntity> updateOrderStatus({
    required String id,
    required OrderStatus status,
    String? notes,
    String? signature,
    List<String>? photoUrls,
  }) async {
    try {
      final model = await _dataSource.updateOrderStatus(
        id: id,
        status: status.value,
        notes: notes,
        signature: signature,
        photoUrls: photoUrls,
      );
      return model.toEntity();
    } on AppException catch (e) {
      throw handleException(e);
    }
  }
}
