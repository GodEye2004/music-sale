import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
enum UserRole {
  @HiveField(0)
  buyer,
  @HiveField(1)
  producer,
}

@HiveType(typeId: 2)
class UserModel extends HiveObject {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final String displayName;

  @HiveField(4)
  final String passwordHash;

  @HiveField(5)
  final UserRole role;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  String? profilePicturePath;

  @HiveField(8)
  String? bio;

  // For producers
  @HiveField(9)
  double totalEarnings;

  @HiveField(10)
  double pendingBalance;

  @HiveField(11)
  int totalSales;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.displayName,
    required this.passwordHash,
    required this.role,
    required this.createdAt,
    this.profilePicturePath,
    this.bio,
    this.totalEarnings = 0,
    this.pendingBalance = 0,
    this.totalSales = 0,
  });

  // Helper methods
  bool isProducer() => role == UserRole.producer;

  bool isBuyer() => role == UserRole.buyer;

  String getFormattedEarnings() {
    return '${totalEarnings.toStringAsFixed(0)} تومان';
  }

  String getFormattedPendingBalance() {
    return '${pendingBalance.toStringAsFixed(0)} تومان';
  }
}
