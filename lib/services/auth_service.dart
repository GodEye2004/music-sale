import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/config/supabase_config.dart';
import 'package:flutter_application_1/models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _supabase = Supabase.instance.client;

  UserModel? _currentUser;

  // Get current user
  UserModel? get currentUser => _currentUser;

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _loadCurrentUser();
      return _currentUser != null;
    }
    return false;
  }

  // Initialize auth (check if user was logged in)
  Future<void> init() async {
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _loadCurrentUser();
      } else {
        _currentUser = null;
      }
    });

    // Load current user if session exists
    if (_supabase.auth.currentSession != null) {
      await _loadCurrentUser();
    }
  }

  // Load current user from database
  Future<void> _loadCurrentUser() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', userId)
          .single();

      _currentUser = UserModel(
        uid: response['id'],
        email: response['email'],
        username: response['username'],
        displayName: response['display_name'],
        passwordHash: '', // Not needed from Supabase
        role: response['role'] == 'producer'
            ? UserRole.producer
            : UserRole.buyer,
        createdAt: DateTime.parse(response['created_at']),
        bio: response['bio'],
        totalEarnings: (response['total_earnings'] ?? 0).toDouble(),
        pendingBalance: (response['pending_balance'] ?? 0).toDouble(),
        totalSales: response['total_sales'] ?? 0,
      );
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  // Register new user
  Future<UserModel> register({
    required String email,
    required String username,
    required String password,
    required UserRole role,
  }) async {
    try {
      // Sign up with Supabase Auth
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('ثبت نام ناموفق بود');
      }

      // Create user profile in database
      final userPayload = {
        'id': authResponse.user!.id,
        'email': email.toLowerCase().trim(),
        'username': username.trim(),
        'display_name': username.trim(),
        'role': role == UserRole.producer ? 'producer' : 'buyer',
      };

      await _supabase.from(SupabaseConfig.usersTable).insert(userPayload);

      // Load the user
      await _loadCurrentUser();

      if (_currentUser == null) {
        throw Exception('خطا در بارگذاری اطلاعات کاربر');
      }

      return _currentUser!;
    } catch (e) {
      print('Registration error: $e');
      throw Exception('ثبت نام ناموفق: ${e.toString()}');
    }
  }

  // Login with email
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );

      if (response.user == null) {
        throw Exception('ایمیل یا رمز عبور اشتباه است');
      }

      await _loadCurrentUser();

      if (_currentUser == null) {
        throw Exception('خطا در بارگذاری اطلاعات کاربر');
      }

      return _currentUser!;
    } catch (e) {
      print('Login error: $e');
      throw Exception('ورود ناموفق: ایمیل یا رمز عبور اشتباه است');
    }
  }

  // Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUser = null;
  }

  // Refresh current user data from database
  Future<void> refreshCurrentUser() async {
    await _loadCurrentUser();
  }
}
