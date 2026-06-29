import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/cart_item.dart';
import 'package:shop_app/models/product.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: kApiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) {
          final msg = e.response?.data is Map
              ? e.response!.data['message'] as String? ?? 'Server error'
              : e.message ?? 'Network error';
          handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              message: msg,
            ),
          );
        },
      ),
    );

  // ---------- Auth ----------

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final res = await _dio.post('/auth/login',
        data: {'email': email, 'password': password});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> signUp(
      String name, String email, String password) async {
    final res = await _dio.post('/auth/register',
        data: {'name': name, 'email': email, 'password': password});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/auth/me');
    return res.data as Map<String, dynamic>;
  }

  // ---------- Products ----------

  Future<List<Product>> getProducts() async {
    final res = await _dio.get('/products');
    return (res.data as List<dynamic>)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------- Cart ----------

  Future<List<CartItem>> getCart() async {
    final res = await _dio.get('/cart');
    return _parseItems(res.data['items'] as List<dynamic>);
  }

  Future<List<CartItem>> addToCart(CartItem item) async {
    final res = await _dio.post('/cart/add', data: {
      'productId': item.product.id,
      'size': item.size,
      'color': item.color?.toARGB32(),
    });
    return _parseItems(res.data['items'] as List<dynamic>);
  }

  Future<List<CartItem>> incrementCartItem(CartItem item) async {
    final res = await _dio.post('/cart/increment', data: {
      'productId': item.product.id,
      'size': item.size,
      'color': item.color?.toARGB32(),
    });
    return _parseItems(res.data['items'] as List<dynamic>);
  }

  Future<List<CartItem>> decrementCartItem(CartItem item) async {
    final res = await _dio.post('/cart/decrement', data: {
      'productId': item.product.id,
      'size': item.size,
      'color': item.color?.toARGB32(),
    });
    return _parseItems(res.data['items'] as List<dynamic>);
  }

  Future<List<CartItem>> removeFromCart(CartItem item) async {
    final res = await _dio.delete('/cart/remove', data: {
      'productId': item.product.id,
      'size': item.size,
      'color': item.color?.toARGB32(),
    });
    return _parseItems(res.data['items'] as List<dynamic>);
  }

  Future<void> clearCart() async {
    await _dio.delete('/cart/clear');
  }

  // ---------- Wishlist ----------

  Future<List<Product>> getWishlist() async {
    final res = await _dio.get('/wishlist');
    return _parseProducts(res.data['products'] as List<dynamic>);
  }

  Future<List<Product>> toggleWishlist(String productId) async {
    final res =
        await _dio.post('/wishlist/toggle', data: {'productId': productId});
    return _parseProducts(res.data['products'] as List<dynamic>);
  }

  // ---------- Helpers ----------

  List<CartItem> _parseItems(List<dynamic> raw) =>
      raw.map((e) => CartItem.fromApiJson(e as Map<String, dynamic>)).toList();

  List<Product> _parseProducts(List<dynamic> raw) =>
      raw.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
}
