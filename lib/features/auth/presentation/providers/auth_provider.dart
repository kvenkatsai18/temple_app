import 'package:flutter/material.dart';
import '../../../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isDemoMode = true;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isDemoMode || _currentUser != null;
  bool get isSuperAdmin => _currentUser?.role == 'super_admin';
  bool get isTempleAdmin => _currentUser?.role == 'admin';
  bool get isUser => _currentUser?.role == 'user';
  bool get isDemoMode => _isDemoMode;

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // Check role based on email
    String role = 'user';
    if (email.toLowerCase().contains('superadmin') || email.toLowerCase().contains('developer')) {
      role = 'super_admin';
    } else if (email.toLowerCase().contains('admin')) {
      role = 'admin';
    }
    
    String displayName = 'Devotee';
    if (role == 'super_admin') {
      displayName = 'Super Admin';
    } else if (role == 'admin') {
      displayName = 'Temple Admin';
    }
    
    _currentUser = UserModel(
      id: '${role}_${DateTime.now().millisecondsSinceEpoch}',
      name: displayName,
      email: email,
      phone: '+91 9876543210',
      role: role,
    );

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
    _isDemoMode = false;
    _isLoading = false;
    notifyListeners();
  }

  // Super Admin: Create Temple Admin account
  Future<bool> createTempleAdmin({
    required String name,
    required String email,
    required String phone,
    required String templeId,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // In production, this would create an actual admin account
    // For demo, we just simulate success

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Super Admin: Onboard new temple
  Future<bool> onboardTemple({
    required String name,
    required String location,
    required String deity,
    String? imageUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // In production, this would create an actual temple
    // For demo, we just simulate success

    _isLoading = false;
    notifyListeners();
    return true;
  }
}
