import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
import 'package:flutter_application_1/screens/buyer/pages/home_screen.dart';
import 'package:flutter_application_1/screens/producer/dashboard_screen.dart';
import 'package:flutter_application_1/services/auth_service.dart';

class StartupRouter extends StatelessWidget {
  const StartupRouter({super.key});

  Future<Widget> _routeUser() async {
    // Check login status
    final isLoggedIn = await AuthService().isLoggedIn();
    if (!isLoggedIn) {
      return const LoginScreen();
    }

    // Get stored role
    final prefs = await SharedPreferences.getInstance();
    final roleString = prefs.getString('user_role');

    // Default if missing
    if (roleString == null) {
      return const HomeScreen();
    }

    final role = UserRole.values.firstWhere(
      (e) => e.name == roleString,
      orElse: () => UserRole.buyer,
    );

    // Route based on role
    if (role == UserRole.producer) {
      return const ProducerDashboardScreen();
    } else {
      return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _routeUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return snapshot.data!;
      },
    );
  }
}
