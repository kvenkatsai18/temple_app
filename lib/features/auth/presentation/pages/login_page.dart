import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int _tapCount = 0;
  DateTime? _lastTap;

  void _handleSecretTap() {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!) > const Duration(seconds: 2)) {
      _tapCount = 0;
    }
    _lastTap = now;
    _tapCount++;
    
    if (_tapCount >= 5) {
      _tapCount = 0;
      _showDebugMenu();
    }
  }

  void _showDebugMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔧 Demo Mode',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a role to preview:',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.purple,
                child: Icon(Icons.admin_panel_settings, color: Colors.white),
              ),
              title: const Text('Super Admin'),
              subtitle: const Text('Manage all temples & admins'),
              onTap: () {
                Navigator.pop(ctx);
                _setRoleAndNavigate('super_admin');
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.temple_hindu, color: Colors.white),
              ),
              title: const Text('Temple Admin'),
              subtitle: const Text('Manage individual temple'),
              onTap: () {
                Navigator.pop(ctx);
                _setRoleAndNavigate('admin');
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: const Text('Regular User'),
              subtitle: const Text('Book poojas & donations'),
              onTap: () {
                Navigator.pop(ctx);
                _setRoleAndNavigate('user');
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setRoleAndNavigate(String role) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setDebugRole(role);
    
    if (mounted) {
      if (role == 'super_admin') {
        Navigator.pushReplacementNamed(context, '/super-admin-home');
      } else if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin-home');
      } else {
        Navigator.pushReplacementNamed(context, '/temple-selection');
      }
    }
  }

  void _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      _navigateBasedOnRole(authProvider);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Sign in failed. Please try again.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _navigateBasedOnRole(AuthProvider authProvider) {
    if (authProvider.isSuperAdmin) {
      Navigator.pushReplacementNamed(context, '/super-admin-home');
    } else if (authProvider.isTempleAdmin) {
      Navigator.pushReplacementNamed(context, '/admin-home');
    } else {
      Navigator.pushReplacementNamed(context, '/temple-selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.backgroundColor, Color(0xFFFFE0B2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                // Logo - Tap 5 times to open debug menu
                GestureDetector(
                  onTap: _handleSecretTap,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.temple_hindu,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Welcome to Temple App',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue your spiritual journey',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                // Google Sign In Button
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return ElevatedButton.icon(
                      onPressed: auth.isLoading ? null : _handleGoogleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      icon: auth.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.g_mobiledata,
                              size: 28,
                              color: Color(0xFF4285F4),
                            ),
                      label: Text(
                        auth.isLoading ? 'Signing in...' : 'Sign in with Google',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
