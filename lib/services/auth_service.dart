import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/services/database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _db = DatabaseService();
  final Uuid _uuid = const Uuid();

  static const String _currentUserIdKey = 'current_user_id';
  static const String _isLoggedInKey = 'is_logged_in';

  UserModel? _currentUser;

  // Get current user
  UserModel? get currentUser => _currentUser;

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Initialize auth (check if user was logged in)
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    if (isLoggedIn) {
      final userId = prefs.getString(_currentUserIdKey);
      if (userId != null) {
        _currentUser = _db.getUserById(userId);
      }
    }
  }

  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // Register new user
  Future<UserModel> register({
    required String email,
    required String username,
    required String password,
    required UserRole role,
  }) async {
    // Check if email already exists
    final existingUser = _db.getUserByEmail(email);
    if (existingUser != null) {
      throw Exception('کاربری با این ایمیل قبلاً ثبت نام کرده است');
    }

    // Create new user
    final user = UserModel(
      uid: _uuid.v4(),
      email: email.toLowerCase().trim(),
      username: username.trim(),
      displayName: username.trim(),
      role: role,
      createdAt: DateTime.now(),
      passwordHash: _hashPassword(password),
    );

    // Save to database
    await _db.addUser(user);

    // Log in the user
    await _loginUser(user);

    return user;
  }

  // Login with email
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final user = _db.getUserByEmail(email.toLowerCase().trim());

    if (user == null) {
      throw Exception('ایمیل یا رمز عبور اشتباه است');
    }

    final passwordHash = _hashPassword(password);
    if (user.passwordHash != passwordHash) {
      throw Exception('ایمیل یا رمز عبور اشتباه است');
    }

    await _loginUser(user);
    return user;
  }

  // Internal method to log in user
  Future<void> _loginUser(UserModel user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserIdKey, user.uid);
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserIdKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Refresh current user data from database
  Future<void> refreshCurrentUser() async {
    if (_currentUser != null) {
      final updatedUser = _db.getUserById(_currentUser!.uid);
      if (updatedUser != null) {
        _currentUser = updatedUser;
      }
    }
  }
}
