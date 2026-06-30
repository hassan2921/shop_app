import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/wishlist_provider.dart';
import 'package:shop_app/services/api_service.dart';

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String userName;
  final String email;
  final bool isAdmin;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = true,
    this.userName = '',
    this.email = '',
    this.isAdmin = false,
  });
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState(isLoading: true)) {
    _checkStoredToken();
  }

  Future<void> _checkStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      state = const AuthState(isLoading: false);
      return;
    }
    try {
      final data = await ApiService.instance.getMe();
      final user = data['user'] as Map<String, dynamic>;
      state = AuthState(
        isLoggedIn: true,
        isLoading: false,
        userName: user['name'] as String,
        email: user['email'] as String,
        isAdmin: user['isAdmin'] as bool? ?? false,
      );
    } catch (_) {
      await prefs.remove('token');
      state = const AuthState(isLoading: false);
    }
  }

  Future<void> signIn(String email, String password) async {
    final result = await ApiService.instance.signIn(email, password);
    await _applyAuthResult(result);
  }

  Future<void> signUp(String name, String email, String password) async {
    final result = await ApiService.instance.signUp(name, email, password);
    await _applyAuthResult(result);
  }

  Future<void> _applyAuthResult(Map<String, dynamic> result) async {
    final token = result['token'] as String;
    final user = result['user'] as Map<String, dynamic>;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    state = AuthState(
      isLoggedIn: true,
      isLoading: false,
      userName: user['name'] as String,
      email: user['email'] as String,
      isAdmin: user['isAdmin'] as bool? ?? false,
    );
    // Reload per-user data with the new identity.
    _ref.invalidate(cartProvider);
    _ref.invalidate(wishlistProvider);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    state = const AuthState(isLoading: false);
    _ref.invalidate(cartProvider);
    _ref.invalidate(wishlistProvider);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);
