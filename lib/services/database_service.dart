import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/config/supabase_config.dart';
import 'package:flutter_application_1/models/beat_model.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/models/transaction_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final _supabase = Supabase.instance.client;

  // Initialize (no longer needed for Supabase, but keep for compatibility)
  Future<void> init() async {
    print('DatabaseService initialized with Supabase');
  }

  // ==================== BEAT OPERATIONS ====================

  // Add beat
  Future<void> addBeat(Beat beat) async {
    final payload = {
      'id': beat.id,
      'title': beat.title,
      'description': beat.description,
      'producer_id': beat.producerId,
      'genre': beat.genre,
      'bpm': beat.bpm,
      'musical_key': beat.musicalKey,
      'price': beat.price,
      'audio_url': beat.previewPath,
      'cover_url': beat.coverImagePath ?? '',
      'tags': beat.tags,
      'mp3_price': beat.mp3Price,
      'wav_price': beat.wavPrice,
      'stems_price': beat.stemsPrice,
      'exclusive_price': beat.exclusivePrice,
    };

    await _supabase.from(SupabaseConfig.beatsTable).insert(payload);
  }

  // Get all beats
  List<Beat> getAllBeats() {
    // This will be replaced with real-time stream
    // For now, return empty and use stream in UI
    return [];
  }

  // Get all beats (async version for Supabase)
  Future<List<Beat>> getAllBeatsAsync() async {
    final response = await _supabase
        .from(SupabaseConfig.beatsTable)
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((json) => _beatFromJson(json)).toList();
  }

  // Get beat by ID
  Future<Beat?> getBeatById(String id) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.beatsTable)
          .select()
          .eq('id', id)
          .single();

      return _beatFromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Get beats by producer ID
  Future<List<Beat>> getBeatsByProducer(String producerId) async {
    final response = await _supabase
        .from(SupabaseConfig.beatsTable)
        .select()
        .eq('producer_id', producerId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => _beatFromJson(json)).toList();
  }

  // Search beats
  Future<List<Beat>> searchBeats(String query) async {
    final response = await _supabase
        .from(SupabaseConfig.beatsTable)
        .select()
        .or('title.ilike.%$query%,genre.ilike.%$query%')
        .order('created_at', ascending: false);

    return (response as List).map((json) => _beatFromJson(json)).toList();
  }

  // Helper: Convert JSON to Beat
  Beat _beatFromJson(Map<String, dynamic> json) {
    return Beat(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      producerId: json['producer_id'],
      producerName: '', // Will be fetched separately if needed
      genre: json['genre'],
      bpm: json['bpm'],
      musicalKey: json['musical_key'],
      price: (json['price'] ?? 0).toDouble(),
      previewPath: json['audio_url'] ?? '',
      coverImagePath: json['cover_url'],
      uploadDate: DateTime.parse(json['created_at']),
      tags: List<String>.from(json['tags'] ?? []),
      likes: json['likes'] ?? 0,
      downloads: json['downloads'] ?? 0,
      mp3Price: (json['mp3_price'] ?? 0).toDouble(),
      wavPrice: (json['wav_price'] ?? 0).toDouble(),
      stemsPrice: (json['stems_price'] ?? 0).toDouble(),
      exclusivePrice: (json['exclusive_price'] ?? 0).toDouble(),
    );
  }

  // ==================== USER OPERATIONS ====================

  // Get user by ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', uid)
          .single();

      return _userFromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('email', email.toLowerCase())
          .single();

      return _userFromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Helper: Convert JSON to UserModel
  UserModel _userFromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['id'],
      email: json['email'],
      username: json['username'],
      displayName: json['display_name'],
      passwordHash: '', // Not needed
      role: json['role'] == 'producer' ? UserRole.producer : UserRole.buyer,
      createdAt: DateTime.parse(json['created_at']),
      bio: json['bio'],
      totalEarnings: (json['total_earnings'] ?? 0).toDouble(),
      pendingBalance: (json['pending_balance'] ?? 0).toDouble(),
      totalSales: json['total_sales'] ?? 0,
    );
  }

  // Update producer balance
  Future<void> updateProducerBalance(String producerId, double amount) async {
    final user = await getUserById(producerId);
    if (user != null && user.isProducer()) {
      await _supabase
          .from(SupabaseConfig.usersTable)
          .update({
            'pending_balance': user.pendingBalance + amount,
            'total_earnings': user.totalEarnings + amount,
            'total_sales': user.totalSales + 1,
          })
          .eq('id', producerId);
    }
  }

  // ==================== TRANSACTION OPERATIONS ====================

  // Add transaction
  Future<void> addTransaction(Transaction transaction) async {
    final payload = {
      'id': transaction.id,
      'beat_id': transaction.beatId,
      'buyer_id': transaction.buyerId,
      'producer_id': transaction.producerId,
      'license_type': transaction.licenseType.toString().split('.').last,
      'amount': transaction.amount,
      'status': transaction.status.toString().split('.').last,
    };

    await _supabase.from(SupabaseConfig.transactionsTable).insert(payload);
  }

  // Get transactions by producer
  Future<List<Transaction>> getTransactionsByProducer(String producerId) async {
    final response = await _supabase
        .from(SupabaseConfig.transactionsTable)
        .select()
        .eq('producer_id', producerId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => _transactionFromJson(json))
        .toList();
  }

  // Helper: Convert JSON to Transaction
  Transaction _transactionFromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      beatId: json['beat_id'],
      beatTitle: '', // Will need to fetch separately
      buyerId: json['buyer_id'],
      producerId: json['producer_id'],
      licenseType: _parseLicenseType(json['license_type']),
      amount: (json['amount'] ?? 0).toDouble(),
      status: _parseTransactionStatus(json['status']),
      timestamp: DateTime.parse(json['created_at']), transactionReference: '',
    );
  }

  LicenseType _parseLicenseType(String type) {
    switch (type.toLowerCase()) {
      case 'mp3':
        return LicenseType.mp3;
      case 'wav':
        return LicenseType.wav;
      case 'stems':
        return LicenseType.stems;
      case 'exclusive':
        return LicenseType.exclusive;
      default:
        return LicenseType.mp3;
    }
  }

  TransactionStatus _parseTransactionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TransactionStatus.pending;
      case 'completed':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      default:
        return TransactionStatus.completed;
    }
  }

  // ==================== PURCHASED BEATS ====================

  // Check if beat is purchased (query transactions)
  Future<bool> isBeatPurchased(String beatId, String userId) async {
    final response = await _supabase
        .from(SupabaseConfig.transactionsTable)
        .select()
        .eq('beat_id', beatId)
        .eq('buyer_id', userId)
        .limit(1);

    return (response as List).isNotEmpty;
  }

  // ==================== UTILITY ====================

  // Clear all data (for testing) - Not applicable for Supabase
  Future<void> clearAllData() async {
    print('Clear all data not supported in Supabase mode');
  }
}
