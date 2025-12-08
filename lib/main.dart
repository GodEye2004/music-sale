import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/supabase_config.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
import 'package:flutter_application_1/screens/buyer/pages/home_screen.dart';
import 'package:flutter_application_1/screens/producer/dashboard_screen.dart';
import 'package:flutter_application_1/startup_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/config/theme.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  try {
    // Check if URL/Key are present
    if (SupabaseConfig.supabaseUrl.isEmpty ||
        SupabaseConfig.supabaseAnonKey.isEmpty) {
      throw Exception(
        'Supabase URL or Key is empty. Check lib/config/supabase_config.dart',
      );
    }

    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      debug: true, // Enable debug logging
    );

    // Initialize Services

    final storageService = StorageService();
    await storageService.init();

    final authService = AuthService();
    // No need to await init() as it's not async anymore or handles internals
  } catch (e, stackTrace) {
    runApp(ErrorApp(error: e.toString()));
    return;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeatMarket',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      // Temporarily use English locale (Persian support needs flutter_localizations properly configured)
      // locale: const Locale('fa', 'IR'),
      localizationsDelegates: const [
        // GlobalMaterialLocalizations.delegate,
        // GlobalWidgetsLocalizations.delegate,
        // GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fa', 'IR'), Locale('en', 'US')],
      home: FutureBuilder<void>(
        future: AuthService()
            .init(), // این باید session رو بازیابی کنه و currentUser ست بشه
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final user = AuthService().currentUser;

          if (user == null) {
            return const LoginScreen();
          } else if (user.role == UserRole.producer) {
            return const ProducerDashboardScreen();
          } else {
            return const HomeScreen();
          }
        },
      ),
    );
  }
}

// Error App for initialization failures
class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  'خطا در راه‌اندازی',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
