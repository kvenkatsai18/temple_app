import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'data/services/firebase_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/temple/presentation/providers/temple_provider.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/user/presentation/pages/user_home_page.dart';
import 'features/user/presentation/pages/temple_selection_page.dart';
import 'features/user/presentation/pages/pooja_booking_page.dart';
import 'features/user/presentation/pages/darshan_booking_page.dart';
import 'features/user/presentation/pages/donation_page.dart';
import 'features/admin/presentation/pages/admin_home_page.dart';
import 'features/admin/presentation/pages/admin_temples_page.dart';
import 'features/admin/presentation/pages/add_pooja_page.dart';
import 'features/admin/presentation/pages/add_event_page.dart';
import 'features/admin/presentation/pages/create_announcement_page.dart';
import 'features/super_admin/presentation/pages/super_admin_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(const TempleApp());
}

class TempleApp extends StatelessWidget {
  const TempleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TempleProvider()),
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
          '/super-admin-home': (context) => const SuperAdminHomePage(),
          '/admin-home': (context) => const AdminHomePage(),
          '/admin-temples': (context) => const AdminTemplesPage(),
          '/pooja-booking': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final pooja = args is Map<String, dynamic> ? args : <String, dynamic>{};
            return PoojaBookingPage(pooja: pooja);
          },
          '/darshan-booking': (context) => const DarshanBookingPage(),
          '/donation': (context) => const DonationPage(),
          '/add-pooja': (context) => const AddPoojaPage(),
          '/add-event': (context) => const AddEventPage(),
          '/announcement': (context) => const CreateAnnouncementPage(),
          '/signup': (context) => const SignUpPage(),
        },
      ),
    );
  }
}
