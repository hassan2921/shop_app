import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple StateProvider for search query
final searchProvider = StateProvider<String>((ref) => "");

// CartProvider using Riverpod
class CartNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  CartNotifier() : super([]);

  void addProduct(Map<String, dynamic> product) {
    state = [...state, product];
  }

  void removeProduct(Map<String, dynamic> product) {
    state = state.where((item) => item != product).toList();
  }
}

// Global provider
final cartProvider =
    StateNotifierProvider<CartNotifier, List<Map<String, dynamic>>>(
  (ref) => CartNotifier(),
);
