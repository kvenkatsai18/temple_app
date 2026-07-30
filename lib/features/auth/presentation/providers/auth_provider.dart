import 'package:flutter/material.dart';
import '../../../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isDemoMode = true;
  bool _isLoading = false;
  bool _isAdmin = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isDemoMode || _currentUser != null;
  bool get isAdmin => _isAdmin;
  bool get isDemoMode => _isDemoMode;

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // Check if email contains 'admin' for admin access
    _isAdmin = email.toLowerCase().contains('admin');
    
    if (_isAdmin) {
      _currentUser = UserModel(
        id: 'admin_001',
        name: 'Admin User',
        email: email,
        phone: '+91 9876543210',
        role: 'admin',
        createdAt: DateTime.now(),
      );
    } else {
      _currentUser = UserModel(
        id: 'user_001',
        name: 'Demo Devotee',
        email: email,
        phone: '+91 9876543210',
        role: 'user',
        createdAt: DateTime.now(),
      );
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> signUp(String name, String email, String password, String phone) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      role: 'user',
      createdAt: DateTime.now(),
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _currentUser = null;
    _isAdmin = false;
    _isDemoMode = false;
    _isLoading = false;
    notifyListeners();
  }
}
