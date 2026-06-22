import 'package:cobox_sv_mobile/features/orders/domain/entities/address_entity.dart';
import 'package:cobox_sv_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:cobox_sv_mobile/features/orders/domain/repository/order_repository.dart';
import 'package:cobox_sv_mobile/shared/enums/order_status.dart';

class MockOrderRepositoryImpl implements OrderRepository {
  MockOrderRepositoryImpl();

  final List<OrderEntity> _orders = [
    OrderEntity(
      id: '101',
      orderNumber: 'ORD-101',
      clientName: 'Cliente 1',
      deliveryAddress: const AddressEntity(
        street: 'Av. Belgrano',
        number: '3200',
        city: 'Buenos Aires',
        state: 'CABA',
        zipCode: '1200',
        latitude: -34.6037,
        longitude: -58.3816,
      ),
      status: OrderStatus.completed,
      actualDeliveryTime: DateTime(2026, 6, 18, 14, 30),
      weight: 12.5,
      notes: 'Entregado correctamente',
    ),
    OrderEntity(
      id: '102',
      orderNumber: 'ORD-102',
      clientName: 'Cliente 2',
      deliveryAddress: const AddressEntity(
        street: 'Av. Cordoba',
        number: '1450',
        city: 'Buenos Aires',
        state: 'CABA',
        zipCode: '1043',
        latitude: -34.5992,
        longitude: -58.3867,
      ),
      status: OrderStatus.inProgress,
      scheduledDate: DateTime(2026, 6, 18, 13, 15),
      weight: 8.0,
      notes: 'Ruta activa',
    ),
    OrderEntity(
      id: '103',
      orderNumber: 'ORD-103',
      clientName: 'Cliente 3',
      deliveryAddress: const AddressEntity(
        street: 'Av. Belgrano',
        number: '800',
        city: 'Buenos Aires',
        state: 'CABA',
        zipCode: '1092',
      ),
      status: OrderStatus.pending,
      scheduledDate: DateTime(2026, 6, 18, 12, 00),
      weight: 15.0,
      notes: 'Pendiente de salida',
    ),
    OrderEntity(
      id: '104',
      orderNumber: 'ORD-104',
      clientName: 'Cliente 4',
      deliveryAddress: const AddressEntity(
        street: 'Autopista 25 de Mayo',
        number: '500',
        city: 'Buenos Aires',
        state: 'CABA',
      ),
      status: OrderStatus.assigned,
      scheduledDate: DateTime(2026, 6, 18, 11, 30),
      weight: 20.0,
      notes: 'Asignada a conductor',
    ),
  ];

  @override
  Future<({List<OrderEntity> orders, int total})> getOrders({
    int page = 1,
    int limit = 20,
    OrderStatus? status,
    String? search,
  }) async {
    var filtered = _orders;
    if (status != null) {
      filtered = filtered.where((order) => order.status == status).toList();
    }
    if (search != null && search.isNotEmpty) {
      final normalized = search.toLowerCase();
      filtered = filtered.where((order) {
        return order.orderNumber.toLowerCase().contains(normalized) ||
            order.clientName.toLowerCase().contains(normalized) ||
            order.deliveryAddress.fullAddress.toLowerCase().contains(normalized);
      }).toList();
    }

    return (orders: filtered.take(limit).toList(), total: filtered.length);
  }

  @override
  Future<OrderEntity> getOrderDetail(String id) async {
    return _orders.firstWhere((order) => order.id == id);
  }

  @override
  Future<OrderEntity> updateOrderStatus({
    required String id,
    required OrderStatus status,
    String? notes,
    String? signature,
    List<String>? photoUrls,
  }) async {
    final order = _orders.firstWhere((item) => item.id == id);
    return OrderEntity(
      id: order.id,
      orderNumber: order.orderNumber,
      clientName: order.clientName,
      clientPhone: order.clientPhone,
      deliveryAddress: order.deliveryAddress,
      pickupAddress: order.pickupAddress,
      status: status,
      items: order.items,
      scheduledDate: order.scheduledDate,
      scheduledTimeWindow: order.scheduledTimeWindow,
      actualDeliveryTime: status == OrderStatus.completed ? DateTime(2026, 6, 18, 15, 00) : order.actualDeliveryTime,
      weight: order.weight,
      volume: order.volume,
      notes: notes ?? order.notes,
      signature: signature ?? order.signature,
      photoUrls: photoUrls ?? order.photoUrls,
    );
  }
}
