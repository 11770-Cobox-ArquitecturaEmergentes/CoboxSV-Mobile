import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/core/errors/error_handler.dart';
import 'package:cobox_sv_mobile/app/providers.dart';
import 'package:cobox_sv_mobile/features/orders/data/datasource/order_remote_datasource.dart';
import 'package:cobox_sv_mobile/features/orders/data/repository/order_repository_impl.dart';
import 'package:cobox_sv_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:cobox_sv_mobile/features/orders/domain/repository/order_repository.dart';
import 'package:cobox_sv_mobile/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:cobox_sv_mobile/features/orders/domain/usecases/get_order_detail_usecase.dart';
import 'package:cobox_sv_mobile/features/orders/domain/usecases/update_order_status_usecase.dart';
import 'package:cobox_sv_mobile/shared/enums/order_status.dart';

final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  return OrderRemoteDataSource(ref.watch(dioClientProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(ref.watch(orderRemoteDataSourceProvider));
});

final getOrdersUseCaseProvider = Provider<GetOrdersUseCase>((ref) {
  return GetOrdersUseCase(ref.watch(orderRepositoryProvider));
});

final getOrderDetailUseCaseProvider = Provider<GetOrderDetailUseCase>((ref) {
  return GetOrderDetailUseCase(ref.watch(orderRepositoryProvider));
});

final updateOrderStatusUseCaseProvider = Provider<UpdateOrderStatusUseCase>((ref) {
  return UpdateOrderStatusUseCase(ref.watch(orderRepositoryProvider));
});

enum OrdersFilter { all, pending, inProgress, completed }

class OrdersState {
  final List<OrderEntity> orders;
  final int total;
  final int page;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final OrdersFilter filter;
  final String search;
  final bool hasMore;

  const OrdersState({
    this.orders = const [],
    this.total = 0,
    this.page = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.filter = OrdersFilter.all,
    this.search = '',
    this.hasMore = false,
  });

  OrdersState copyWith({
    List<OrderEntity>? orders,
    int? total,
    int? page,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    OrdersFilter? filter,
    String? search,
    bool? hasMore,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      total: total ?? this.total,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      filter: filter ?? this.filter,
      search: search ?? this.search,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  final GetOrdersUseCase _getOrdersUseCase;
  final GetOrderDetailUseCase _getOrderDetailUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;

  OrdersNotifier({
    required GetOrdersUseCase getOrdersUseCase,
    required GetOrderDetailUseCase getOrderDetailUseCase,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
  })  : _getOrdersUseCase = getOrdersUseCase,
        _getOrderDetailUseCase = getOrderDetailUseCase,
        _updateOrderStatusUseCase = updateOrderStatusUseCase,
        super(const OrdersState());

  static const _pageSize = 20;

  OrderStatus? get _statusFilter {
    switch (state.filter) {
      case OrdersFilter.pending:
        return OrderStatus.pending;
      case OrdersFilter.inProgress:
        return OrderStatus.inProgress;
      case OrdersFilter.completed:
        return OrderStatus.completed;
      case OrdersFilter.all:
        return null;
    }
  }

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, error: null, page: 1);
    try {
      final result = await _getOrdersUseCase(
        page: 1,
        limit: _pageSize,
        status: _statusFilter,
        search: state.search.isNotEmpty ? state.search : null,
      );
      state = state.copyWith(
        orders: result.orders,
        total: result.total,
        isLoading: false,
        hasMore: result.orders.length < result.total,
      );
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, error: getErrorMessage(e));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.page + 1;
    try {
      final result = await _getOrdersUseCase(
        page: nextPage,
        limit: _pageSize,
        status: _statusFilter,
        search: state.search.isNotEmpty ? state.search : null,
      );
      state = state.copyWith(
        orders: [...state.orders, ...result.orders],
        total: result.total,
        page: nextPage,
        isLoadingMore: false,
        hasMore: state.orders.length + result.orders.length < result.total,
      );
    } on Failure catch (e) {
      state = state.copyWith(isLoadingMore: false, error: getErrorMessage(e));
    }
  }

  void setFilter(OrdersFilter filter) {
    if (state.filter == filter) return;
    state = state.copyWith(filter: filter, page: 1);
    loadOrders();
  }

  void setSearch(String search) {
    state = state.copyWith(search: search, page: 1);
    loadOrders();
  }

  Future<void> refresh() => loadOrders();

  Future<OrderEntity?> getOrderDetail(String id) async {
    try {
      return await _getOrderDetailUseCase(id);
    } on Failure catch (e) {
      state = state.copyWith(error: getErrorMessage(e));
      return null;
    }
  }

  Future<OrderEntity?> updateStatus({
    required String id,
    required OrderStatus status,
    String? notes,
    String? signature,
    List<String>? photoUrls,
  }) async {
    try {
      final updated = await _updateOrderStatusUseCase(
        id: id,
        status: status,
        notes: notes,
        signature: signature,
        photoUrls: photoUrls,
      );
      final orders = state.orders.map((o) => o.id == id ? updated : o).toList();
      state = state.copyWith(orders: orders);
      return updated;
    } on Failure catch (e) {
      state = state.copyWith(error: getErrorMessage(e));
      return null;
    }
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier(
    getOrdersUseCase: ref.watch(getOrdersUseCaseProvider),
    getOrderDetailUseCase: ref.watch(getOrderDetailUseCaseProvider),
    updateOrderStatusUseCase: ref.watch(updateOrderStatusUseCaseProvider),
  );
});
