import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/models/cart_item.dart';
import 'package:shop_app/models/order.dart';
import 'package:shop_app/services/api_service.dart';

class OrderNotifier extends StateNotifier<List<Order>> {
  OrderNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    try {
      state = await ApiService.instance.getOrders();
    } catch (_) {}
  }

  Future<Order?> placeOrder(List<CartItem> items, double total) async {
    try {
      final order = await ApiService.instance.createOrder(items, total);
      state = [order, ...state];
      return order;
    } catch (_) {
      return null;
    }
  }

  Future<void> refresh() => _load();
}

final orderProvider = StateNotifierProvider<OrderNotifier, List<Order>>(
  (ref) => OrderNotifier(),
);
