import 'package:cobox_sv_mobile/core/errors/error_handler.dart';
import 'package:cobox_sv_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:cobox_sv_mobile/features/orders/domain/repository/order_repository.dart';
import 'package:cobox_sv_mobile/shared/enums/order_status.dart';

class UpdateOrderStatusUseCase {
  final OrderRepository _repository;

  UpdateOrderStatusUseCase(this._repository);

  Future<OrderEntity> call({
    required String id,
    required OrderStatus status,
    String? notes,
    String? signature,
    List<String>? photoUrls,
    int? routeId,
  }) async {
    try {
      return await _repository.updateOrderStatus(
        id: id,
        status: status,
        notes: notes,
        signature: signature,
        photoUrls: photoUrls,
        routeId: routeId,
      );
    } on Exception catch (e) {
      throw handleException(e);
    }
  }
}
