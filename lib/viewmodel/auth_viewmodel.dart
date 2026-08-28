import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoginPasswordVisible = false;
  bool _isSignupPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoginPasswordVisible => _isLoginPasswordVisible;
  bool get isSignupPasswordVisible => _isSignupPasswordVisible;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void toggleLoginPasswordVisibility() {
    _isLoginPasswordVisible = !_isLoginPasswordVisible;
    notifyListeners();
  }

  void toggleSignupPasswordVisibility() {
    _isSignupPasswordVisible = !_isSignupPasswordVisible;
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _errorMessage = 'Please enter email and password';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate auth / async operation (or hook Firebase Auth when active)
      await Future.delayed(const Duration(milliseconds: 300));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    if (username.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      _errorMessage = 'Please enter Username, email and password';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate auth / async operation
      await Future.delayed(const Duration(milliseconds: 300));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearErrors() {
    _errorMessage = null;
    notifyListeners();
  }
}
