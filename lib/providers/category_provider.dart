import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/services/api_service.dart';

final categoryProvider = FutureProvider<List<String>>((ref) async {
  final cats = await ApiService.instance.getCategories();
  return cats.map((c) => c.name).toList();
});
