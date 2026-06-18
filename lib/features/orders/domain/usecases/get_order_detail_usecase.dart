import 'package:cobox_sv_mobile/core/errors/error_handler.dart';
import 'package:cobox_sv_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:cobox_sv_mobile/features/orders/domain/repository/order_repository.dart';

class GetOrderDetailUseCase {
  final OrderRepository _repository;

  GetOrderDetailUseCase(this._repository);

  Future<OrderEntity> call(String id) async {
    try {
      return await _repository.getOrderDetail(id);
    } on Exception catch (e) {
      throw handleException(e);
    }
  }
}
