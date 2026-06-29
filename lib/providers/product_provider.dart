import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/services/api_service.dart';

final productListProvider = FutureProvider<List<Product>>((ref) async {
  return ApiService.instance.getProducts();
});
