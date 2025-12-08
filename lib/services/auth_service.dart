import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/config/supabase_config.dart';
import 'package:flutter_application_1/models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _supabase = Supabase.instance.client;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  Future<void> init() async {
    print('🔄 Initializing AuthService...');

    // Listen to auth changes (برای لاگ‌اوت، لاگین، تغییر session)
    _supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        await _loadCurrentUser();
      } else {
        _currentUser = null;
      }
    });

    final currentSession = _supabase.auth.currentSession;
    if (currentSession != null) {
      print('🔑 Restoring session… loading user profile');
      await _loadCurrentUser();
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        final data = response;
        _currentUser = UserModel(
          uid: data['id'],
          email: data['email'],
          username: data['username'],
          displayName: data['display_name'] ?? data['username'],
          passwordHash: '', // Not stored in public table
          role: data['role'] == 'producer' ? UserRole.producer : UserRole.buyer,
          createdAt: DateTime.parse(data['created_at']),
          bio: data['bio'],
          profilePictureUrl: data['profile_picture_url'],
          totalEarnings: (data['total_earnings'] ?? 0).toDouble(),
          pendingBalance: (data['pending_balance'] ?? 0).toDouble(),
          totalSales: data['total_sales'] ?? 0,
        );
      }
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  // Register
  Future<UserModel?> register({
    required String email,
    required String password,
    required String username,
    required UserRole role,
  }) async {
    try {
      print('📝 Registering: $email');
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username}, // Meta data
      );

      if (authResponse.user == null) {
        throw Exception('ثبت نام انجام نشد (User null)');
      }

      final userId = authResponse.user!.id;

      // Insert profile
      // Note: We need to handle the case where the user might already exist in 'users' table
      // if the trigger created it (but we don't have a trigger).
      // We are inserting manually.

      final userPayload = {
        'id': userId,
        'email': email.toLowerCase().trim(),
        'username': username.trim(),
        'display_name': username.trim(),
        'role': role == UserRole.producer ? 'producer' : 'buyer',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from(SupabaseConfig.usersTable).insert(userPayload);

      // Auto Login Check
      if (authResponse.session != null) {
        print('✅ Session active, logging in...');
        await _loadCurrentUser();
        return _currentUser;
      } else {
        // Try sign in just in case
        try {
          await _supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );
          if (_supabase.auth.currentSession != null) {
            await _loadCurrentUser();
            return _currentUser;
          }
        } catch (_) {}

        print('✉️ Email confirmation might be needed');
        return null;
      }
    } on AuthException catch (e) {
      // Catch specific config error again just in case
      if (e.code == 'email_provider_disabled') {
        throw Exception(
          'لطفاً گزینه Enable Email Provider را در تنظیمات Supabase روشن کنید.',
        );
      }
      throw Exception('خطای ثبت نام: ${e.message}');
    } catch (e) {
      throw Exception('خطای ثبت نام: $e');
    }
  }

  // Login
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('ورود ناموفق');
      }

      await _loadCurrentUser();
      if (_currentUser == null) {
        throw Exception('پروفایل کاربر یافت نشد');
      }
      return _currentUser!;
    } catch (e) {
      throw Exception('خطای ورود: $e');
    }
  }

  Future<UserModel?> fetchCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    await _loadCurrentUser();
    return _currentUser;
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUser = null;
  }

  Future<bool> isLoggedIn() async {
    return _supabase.auth.currentSession != null;
  }
}
