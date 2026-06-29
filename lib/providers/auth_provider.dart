import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isLoggedIn;
  final String userName;
  final String email;

  const AuthState({
    this.isLoggedIn = false,
    this.userName = '',
    this.email = '',
  });
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void signIn(String email, String password) {
    state = AuthState(
      isLoggedIn: true,
      email: email,
      userName: email.split('@')[0],
    );
  }

  void signUp(String name, String email, String password) {
    state = AuthState(isLoggedIn: true, email: email, userName: name);
  }

  void signOut() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
