import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/register_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const ShelterApp());

class ShelterApp extends StatelessWidget {
  const ShelterApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ThemeData is defined ONCE (AppTheme.light) and applied to the whole app.
    return MaterialApp(
      title: 'SafeHaven',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const DashboardScreen(),
      },
    );
  }
}
