import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/user/presentation/pages/user_home_page.dart';
import 'features/user/presentation/pages/temple_selection_page.dart';
import 'features/admin/presentation/pages/admin_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TempleApp());
}

class TempleApp extends StatelessWidget {
  const TempleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Temple App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashPage(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/temple-selection': (context) => const TempleSelectionPage(),
          '/user-home': (context) => const UserHomePage(),
          '/admin-home': (context) => const AdminHomePage(),
          '/signup': (context) => const LoginPage(), // Placeholder - signup not implemented
        },
      ),
    );
  }
}
