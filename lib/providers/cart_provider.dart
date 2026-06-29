import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/models/cart_item.dart';
import 'package:shop_app/services/api_service.dart';

final searchProvider = StateProvider<String>((ref) => '');

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]) {
    _loadFromApi();
  }

  Future<void> _loadFromApi() async {
    try {
      state = await ApiService.instance.getCart();
    } catch (_) {}
  }

  Future<void> addItem(CartItem item) async {
    try {
      state = await ApiService.instance.addToCart(item);
    } catch (_) {}
  }

  Future<void> removeItem(CartItem item) async {
    try {
      state = await ApiService.instance.removeFromCart(item);
    } catch (_) {}
  }

  Future<void> incrementQuantity(CartItem item) async {
    try {
      state = await ApiService.instance.incrementCartItem(item);
    } catch (_) {}
  }

  Future<void> decrementQuantity(CartItem item) async {
    try {
      state = await ApiService.instance.decrementCartItem(item);
    } catch (_) {}
  }

  Future<void> clearCart() async {
    try {
      await ApiService.instance.clearCart();
      state = [];
    } catch (_) {}
  }

  double get totalPrice =>
      state.fold(0.0, (sum, i) => sum + i.product.price * i.quantity);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);
