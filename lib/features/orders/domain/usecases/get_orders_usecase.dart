import 'package:cobox_sv_mobile/core/errors/error_handler.dart';
import 'package:cobox_sv_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:cobox_sv_mobile/features/orders/domain/repository/order_repository.dart';
import 'package:cobox_sv_mobile/shared/enums/order_status.dart';

class GetOrdersUseCase {
  final OrderRepository _repository;

  GetOrdersUseCase(this._repository);

  Future<({List<OrderEntity> orders, int total})> call({
    int page = 1,
    int limit = 20,
    OrderStatus? status,
    String? search,
  }) async {
    try {
      return await _repository.getOrders(
        page: page,
        limit: limit,
        status: status,
        search: search,
      );
    } on Exception catch (e) {
      throw handleException(e);
    }
  }
}
