import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/auth_service.dart';
import '../data/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? user;
  bool isLoading = true;

  AuthViewModel() {
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final wasLoggedIn = prefs.getBool('loggedIn') ?? false;
    if (wasLoggedIn) {
      final account = await _authService.trySilentSignIn();
      if (account != null) {
        user = UserModel(name: account.displayName ?? '', email: account.email);
        await prefs.setBool('loggedIn', true);
      } else {
        await prefs.setBool('loggedIn', false);
      }
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> signIn() async {
    final account = await _authService.signInWithGoogle();
    if (account != null) {
      user = UserModel(
        name: account.displayName ?? '',
        email: account.email ?? '',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loggedIn', true); // Persist login state

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', false);

    notifyListeners();
  }
}
