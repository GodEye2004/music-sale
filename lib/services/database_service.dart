import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_1/models/beat_model.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'package:flutter_application_1/models/settlement_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Box names
  static const String _beatsBoxName = 'beats';
  static const String _usersBoxName = 'users';
  static const String _transactionsBoxName = 'transactions';
  static const String _settlementsBoxName = 'settlements';
  static const String _purchasedBeatsBoxName = 'purchased_beats';

  // Boxes
  late Box<Beat> _beatsBox;
  late Box<UserModel> _usersBox;
  late Box<Transaction> _transactionsBox;
  late Box<Settlement> _settlementsBox;
  late Box<String> _purchasedBeatsBox; // Store beat IDs that user purchased

  // Initialize Hive and open boxes
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(BeatAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserRoleAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(LicenseTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(TransactionStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(TransactionAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(SettlementStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(SettlementAdapter());
    }

    // Open boxes
    _beatsBox = await Hive.openBox<Beat>(_beatsBoxName);
    _usersBox = await Hive.openBox<UserModel>(_usersBoxName);
    _transactionsBox = await Hive.openBox<Transaction>(_transactionsBoxName);
    _settlementsBox = await Hive.openBox<Settlement>(_settlementsBoxName);
    _purchasedBeatsBox = await Hive.openBox<String>(_purchasedBeatsBoxName);
  }

  // ==================== BEAT OPERATIONS ====================

  // Add beat
  Future<void> addBeat(Beat beat) async {
    await _beatsBox.put(beat.id, beat);
  }

  // Get all beats
  List<Beat> getAllBeats() {
    return _beatsBox.values.toList();
  }

  // Get beat by ID
  Beat? getBeatById(String id) {
    return _beatsBox.get(id);
  }

  // Get beats by producer ID
  List<Beat> getBeatsByProducer(String producerId) {
    return _beatsBox.values
        .where((beat) => beat.producerId == producerId)
        .toList();
  }

  // Search beats
  List<Beat> searchBeats(String query) {
    query = query.toLowerCase();
    return _beatsBox.values.where((beat) {
      return beat.title.toLowerCase().contains(query) ||
          beat.producerName.toLowerCase().contains(query) ||
          beat.genre.toLowerCase().contains(query) ||
          beat.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  // Filter beats
  List<Beat> filterBeats({
    String? genre,
    int? minBpm,
    int? maxBpm,
    double? minPrice,
    double? maxPrice,
    String? key,
  }) {
    var beats = _beatsBox.values;

    if (genre != null) {
      beats = beats.where((beat) => beat.genre == genre);
    }
    if (minBpm != null) {
      beats = beats.where((beat) => beat.bpm >= minBpm);
    }
    if (maxBpm != null) {
      beats = beats.where((beat) => beat.bpm <= maxBpm);
    }
    if (minPrice != null) {
      beats = beats.where((beat) => beat.price >= minPrice);
    }
    if (maxPrice != null) {
      beats = beats.where((beat) => beat.price <= maxPrice);
    }
    if (key != null) {
      beats = beats.where((beat) => beat.musicalKey == key);
    }

    return beats.toList();
  }

  // Update beat
  Future<void> updateBeat(Beat beat) async {
    await _beatsBox.put(beat.id, beat);
  }

  // Delete beat
  Future<void> deleteBeat(String id) async {
    await _beatsBox.delete(id);
  }

  // Increment beat likes
  Future<void> incrementBeatLikes(String beatId) async {
    final beat = _beatsBox.get(beatId);
    if (beat != null) {
      beat.likes++;
      await _beatsBox.put(beatId, beat);
    }
  }

  // Increment beat downloads
  Future<void> incrementBeatDownloads(String beatId) async {
    final beat = _beatsBox.get(beatId);
    if (beat != null) {
      beat.downloads++;
      await _beatsBox.put(beatId, beat);
    }
  }

  // ==================== USER OPERATIONS ====================

  // Add user
  Future<void> addUser(UserModel user) async {
    await _usersBox.put(user.uid, user);
  }

  // Get user by ID
  UserModel? getUserById(String uid) {
    return _usersBox.get(uid);
  }

  // Get user by email
  UserModel? getUserByEmail(String email) {
    return _usersBox.values.firstWhere(
      (user) => user.email == email,
      orElse: () => throw Exception('User not found'),
    );
  }

  // Update user
  Future<void> updateUser(UserModel user) async {
    await _usersBox.put(user.uid, user);
  }

  // Update producer balance
  Future<void> updateProducerBalance(String producerId, double amount) async {
    final user = _usersBox.get(producerId);
    if (user != null && user.isProducer()) {
      user.pendingBalance += amount;
      user.totalEarnings += amount;
      user.totalSales++;
      await _usersBox.put(producerId, user);
    }
  }

  // Deduct from producer balance (for settlements)
  Future<void> deductProducerBalance(String producerId, double amount) async {
    final user = _usersBox.get(producerId);
    if (user != null && user.isProducer()) {
      user.pendingBalance -= amount;
      await _usersBox.put(producerId, user);
    }
  }

  // ==================== TRANSACTION OPERATIONS ====================

  // Add transaction
  Future<void> addTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  // Get transactions by buyer
  List<Transaction> getTransactionsByBuyer(String buyerId) {
    return _transactionsBox.values.where((t) => t.buyerId == buyerId).toList();
  }

  // Get transactions by producer
  List<Transaction> getTransactionsByProducer(String producerId) {
    return _transactionsBox.values
        .where((t) => t.producerId == producerId)
        .toList();
  }

  // Get all transactions
  List<Transaction> getAllTransactions() {
    return _transactionsBox.values.toList();
  }

  // Update transaction
  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  // ==================== SETTLEMENT OPERATIONS ====================

  // Add settlement
  Future<void> addSettlement(Settlement settlement) async {
    await _settlementsBox.put(settlement.id, settlement);
  }

  // Get settlements by producer
  List<Settlement> getSettlementsByProducer(String producerId) {
    return _settlementsBox.values
        .where((s) => s.producerId == producerId)
        .toList();
  }

  // Get all settlements
  List<Settlement> getAllSettlements() {
    return _settlementsBox.values.toList();
  }

  // Update settlement
  Future<void> updateSettlement(Settlement settlement) async {
    await _settlementsBox.put(settlement.id, settlement);
  }

  // ==================== PURCHASED BEATS ====================

  // Mark beat as purchased by user
  Future<void> markBeatAsPurchased(String beatId) async {
    await _purchasedBeatsBox.put(beatId, beatId);
  }

  // Check if beat is purchased
  bool isBeatPurchased(String beatId) {
    return _purchasedBeatsBox.containsKey(beatId);
  }

  // Get all purchased beat IDs
  List<String> getPurchasedBeatIds() {
    return _purchasedBeatsBox.values.toList();
  }

  // ==================== UTILITY ====================

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    await _beatsBox.clear();
    await _usersBox.clear();
    await _transactionsBox.clear();
    await _settlementsBox.clear();
    await _purchasedBeatsBox.clear();
  }

  // Close all boxes
  Future<void> close() async {
    await _beatsBox.close();
    await _usersBox.close();
    await _transactionsBox.close();
    await _settlementsBox.close();
    await _purchasedBeatsBox.close();
  }
}
