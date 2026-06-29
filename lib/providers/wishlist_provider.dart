import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/services/api_service.dart';

class WishlistNotifier extends StateNotifier<List<Product>> {
  WishlistNotifier() : super([]) {
    _loadFromApi();
  }

  Future<void> _loadFromApi() async {
    try {
      state = await ApiService.instance.getWishlist();
    } catch (_) {}
  }

  Future<void> toggle(Product product) async {
    try {
      state = await ApiService.instance.toggleWishlist(product.id);
    } catch (_) {}
  }
}

final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, List<Product>>(
  (ref) => WishlistNotifier(),
);
