import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/cart_item.dart';

final searchProvider = StateProvider<String>((ref) => '');

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]) {
    _loadCart();
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cart');
    if (raw != null) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      state = decoded
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'cart', jsonEncode(state.map((e) => e.toJson()).toList()));
  }

  // Uses CartItem.== (product id + size + color) — no silent reference bugs.
  void addItem(CartItem newItem) {
    final index = state.indexWhere((i) => i == newItem);
    if (index >= 0) {
      state = [
        ...state.sublist(0, index),
        state[index].copyWith(quantity: state[index].quantity + 1),
        ...state.sublist(index + 1),
      ];
    } else {
      state = [...state, newItem];
    }
    _save();
  }

  void removeItem(CartItem item) {
    state = state.where((i) => i != item).toList();
    _save();
  }

  void incrementQuantity(CartItem item) {
    state = state
        .map((i) => i == item ? i.copyWith(quantity: i.quantity + 1) : i)
        .toList();
    _save();
  }

  void decrementQuantity(CartItem item) {
    final index = state.indexWhere((i) => i == item);
    if (index < 0) return;
    if (state[index].quantity <= 1) {
      state = state.where((i) => i != item).toList();
    } else {
      state = state
          .map((i) => i == item ? i.copyWith(quantity: i.quantity - 1) : i)
          .toList();
    }
    _save();
  }

  void clearCart() {
    state = [];
    _save();
  }

  double get totalPrice =>
      state.fold(0.0, (sum, i) => sum + i.product.price * i.quantity);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);
