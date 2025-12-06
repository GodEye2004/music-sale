import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/theme.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/storage_service.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
import 'package:flutter_application_1/screens/buyer/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize services
    print('Initializing DatabaseService...');
    await DatabaseService().init();
    print('DatabaseService initialized');

    print('Initializing StorageService...');
    await StorageService().init();
    print('StorageService initialized');

    print('Initializing AuthService...');
    await AuthService().init();
    print('AuthService initialized');

    runApp(const MyApp());
  } catch (e, stackTrace) {
    print('Error during initialization: $e');
    print('Stack trace: $stackTrace');
    runApp(ErrorApp(error: e.toString()));
  }
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
      home: FutureBuilder<bool>(
        future: AuthService().isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final isLoggedIn = snapshot.data ?? false;
          if (isLoggedIn) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
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
