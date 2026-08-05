import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/config/app_config.dart';
import '../../../../data/services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  String _userRole = 'user';

  User? get currentUser => _user;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  String get userRole => _userRole;

  // Check if user is Super Admin (specific email only)
  bool get isSuperAdmin => _user?.email?.toLowerCase() == AppConfig.superAdminEmail.toLowerCase();
  
  // Check if user is Temple Admin (by role or email domain)
  bool get isTempleAdmin {
    if (isSuperAdmin) return false;
    if (_userRole == 'temple_admin') return true;
    // Also check by email domain
    final email = _user?.email?.toLowerCase() ?? '';
    return email.endsWith('@templeadmin.com') || email.endsWith('@admin.temple');
  }

  AuthProvider() {
    _auth.authStateChanges().listen((user) async {
      _user = user;
      if (user != null) {
        await _loadUserRole();
      } else {
        _userRole = 'user';
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserRole() async {
    if (_user == null) return;
    
    try {
      final userEmail = _user!.email?.toLowerCase() ?? '';
      print('🔍 DEBUG _loadUserRole: Loading role for $userEmail');
      
      // First check if user is in superAdmins collection
      final superAdminDocs = await _firestore.collection('superAdmins').get();
      print('🔍 DEBUG: superAdmins count = ${superAdminDocs.size}');
      for (final doc in superAdminDocs.docs) {
        final adminEmail = (doc['email'] as String?)?.toLowerCase() ?? '';
        if (adminEmail == userEmail) {
          _userRole = 'super_admin';
          print('🔍 DEBUG: Found in superAdmins, role = super_admin');
          await _createUserDocument();
          notifyListeners();
          return;
        }
      }
      
      // Then check if user is in admins collection (temple admin)
      final adminDocs = await _firestore.collection('admins').get();
      print('🔍 DEBUG: admins count = ${adminDocs.size}');
      for (final doc in adminDocs.docs) {
        final adminEmail = (doc['email'] as String?)?.toLowerCase() ?? '';
        print('🔍 DEBUG: Checking admin email: $adminEmail');
        if (adminEmail == userEmail) {
          _userRole = 'temple_admin';
          print('🔍 DEBUG: Found in admins, role = temple_admin');
          await _createUserDocument();
          notifyListeners();
          return;
        }
      }
      
      // Then check users collection for existing role
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      print('🔍 DEBUG: users doc exists = ${doc.exists}');
      if (doc.exists) {
        _userRole = doc['role'] ?? 'user';
        print('🔍 DEBUG: Read role from users collection = $_userRole');
      } else {
        // Keep existing role if already set (from signup)
        if (_userRole == 'user') {
          // Check by email domain as fallback
          if (userEmail.endsWith('@templeadmin.com') || userEmail.endsWith('@admin.temple')) {
            _userRole = 'temple_admin';
            print('🔍 DEBUG: Detected by email domain, role = temple_admin');
          } else if (userEmail == AppConfig.superAdminEmail.toLowerCase()) {
            _userRole = 'super_admin';
            print('🔍 DEBUG: Super admin email detected, role = super_admin');
          }
        }
      }
      print('🔍 DEBUG: Final role = $_userRole');
    } catch (e) {
      print('🔍 DEBUG _loadUserRole ERROR: $e');
      
      // FALLBACK: Check users collection directly for the user's own document
      // This should work even if other collections are blocked
      try {
        // Force refresh to get latest data from server
        final userDoc = await _firestore.collection('users').doc(_user!.uid).get(
          GetOptions(source: Source.server),
        );
        print('🔍 DEBUG: Fallback - checking users doc: exists=${userDoc.exists}, source=${userDoc.metadata.isFromCache ? "cache" : "server"}');
        if (userDoc.exists && userDoc['role'] != null) {
          _userRole = userDoc['role'] ?? 'user';
          print('🔍 DEBUG: Fallback - got role from users collection = $_userRole');
          notifyListeners();
          return;
        }
      } catch (e2) {
        print('🔍 DEBUG: Fallback users doc also failed: $e2');
      }
      
      // Final fallback - check by email domain
      final userEmail = _user?.email?.toLowerCase() ?? '';
      if (userEmail.endsWith('@templeadmin.com') || userEmail.endsWith('@admin.temple')) {
        _userRole = 'temple_admin';
      } else if (userEmail == AppConfig.superAdminEmail.toLowerCase()) {
        _userRole = 'super_admin';
      }
    }
    notifyListeners();
  }

  Future<void> _createUserDocument() async {
    if (_user == null) return;
    
    final userData = {
      'email': _user!.email,
      'name': _user!.displayName ?? _user!.email?.split('@').first ?? 'User',
      'role': _userRole, // Use the determined role (super_admin, temple_admin, or user)
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    };
    
    await _firestore.collection('users').doc(_user!.uid).set(userData, SetOptions(merge: true));
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = credential.user;
      await _loadUserRole();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name, String role) async {
    return signUpWithEmail(email, password, name, role);
  }

  Future<bool> signUpWithEmail(String email, String password, String name, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = credential.user;
      
      // Update display name
      await _user?.updateDisplayName(name);
      
      // Determine role - super admin email always gets super_admin role
      String finalRole = role;
      print('🔍 DEBUG signUpWithEmail: email=$email, initial role=$role');
      
      if (email.toLowerCase() == AppConfig.superAdminEmail.toLowerCase()) {
        finalRole = 'super_admin';
        print('🔍 DEBUG: Super admin detected by email');
      } else {
        // Check if user is in admins collection (added by super admin)
        final adminData = await FirebaseService.getAdminByEmail(email);
        print('🔍 DEBUG: adminData for $email = $adminData');
        if (adminData != null) {
          finalRole = 'temple_admin';
          print('🔍 DEBUG: Temple admin detected from admins collection');
        }
      }
      
      _userRole = finalRole;
      print('🔍 DEBUG: Final role set to $finalRole');
      
      // Create user document in Firestore
      await _createUserDocument();
      print('🔍 DEBUG: User document created');
      
      // If user was in admins collection, update that record with userId
      if (finalRole == 'temple_admin') {
        final adminData = await FirebaseService.getAdminByEmail(email);
        if (adminData != null && adminData['id'] != null) {
          await _firestore.collection('admins').doc(adminData['id']).update({
            'userId': _user!.uid,
          });
          print('🔍 DEBUG: Updated admins collection with userId');
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;
      
      // Load role FIRST before creating user document
      await _loadUserRole();
      await _createUserDocument();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _user = null;
    _userRole = 'user';
    notifyListeners();
  }

  // Debug mode setter (for testing purposes - bypasses Firebase auth)
  void setDebugRole(String role) {
    _userRole = role;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email';
        case 'wrong-password':
          return 'Incorrect password';
        case 'email-already-in-use':
          return 'An account already exists with this email';
        case 'invalid-email':
          return 'Invalid email address';
        case 'weak-password':
          return 'Password should be at least 6 characters';
        default:
          return error.message ?? 'An error occurred';
      }
    }
    return 'An error occurred';
  }
}
