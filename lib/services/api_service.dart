import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/cart_item.dart';
import 'package:shop_app/models/order.dart';
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

  // ---------- Orders ----------

  Future<List<Order>> getOrders() async {
    final res = await _dio.get('/orders');
    return _parseOrders(res.data['orders'] as List<dynamic>);
  }

  Future<Order> createOrder(List<CartItem> items, double total) async {
    final res = await _dio.post('/orders', data: {
      'items': items
          .map((i) => {
                'productId': i.product.id,
                'title': i.product.title,
                'imageUrl': i.product.imageUrl,
                'price': i.product.price,
                'size': i.size,
                'color': i.color?.toARGB32(),
                'quantity': i.quantity,
              })
          .toList(),
      'total': total,
    });
    return Order.fromJson(res.data['order'] as Map<String, dynamic>);
  }

  // ---------- Admin ----------

  Future<List<Order>> getAdminOrders() async {
    final res = await _dio.get('/admin/orders');
    return _parseOrders(res.data['orders'] as List<dynamic>);
  }

  Future<Order> updateOrderStatus(String orderId, String status) async {
    final res = await _dio.patch('/admin/orders/$orderId/status', data: {'status': status});
    return Order.fromJson(res.data['order'] as Map<String, dynamic>);
  }

  Future<List<Product>> getAdminProducts() async {
    final res = await _dio.get('/admin/products');
    return _parseProducts(res.data['products'] as List<dynamic>);
  }

  Future<Product> createProduct(Map<String, dynamic> data) async {
    final res = await _dio.post('/admin/products', data: data);
    return Product.fromJson(res.data['product'] as Map<String, dynamic>);
  }

  Future<Product> updateProduct(String id, Map<String, dynamic> data) async {
    final res = await _dio.put('/admin/products/$id', data: data);
    return Product.fromJson(res.data['product'] as Map<String, dynamic>);
  }

  Future<void> deleteProduct(String id) async {
    await _dio.delete('/admin/products/$id');
  }

  // ---------- Helpers ----------

  List<CartItem> _parseItems(List<dynamic> raw) =>
      raw.map((e) => CartItem.fromApiJson(e as Map<String, dynamic>)).toList();

  List<Product> _parseProducts(List<dynamic> raw) =>
      raw.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();

  List<Order> _parseOrders(List<dynamic> raw) =>
      raw.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
}
