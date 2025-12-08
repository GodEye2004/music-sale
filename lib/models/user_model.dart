enum UserRole { buyer, producer }

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String displayName;
  final String
  passwordHash; // Kept for legacy compatibility, but unused in Supabase Auth
  final UserRole role;
  final DateTime createdAt;
  final String? bio;
  final String? profilePictureUrl;
  final double totalEarnings; // For producers
  final double pendingBalance; // For producers
  final int totalSales; // For producers

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.displayName,
    required this.passwordHash,
    required this.role,
    required this.createdAt,
    this.bio,
    this.profilePictureUrl,
    this.totalEarnings = 0,
    this.pendingBalance = 0,
    this.totalSales = 0,
  });

  bool isProducer() {
    return role == UserRole.producer;
  }

  String getFormattedEarnings() {
    return '${totalEarnings.toStringAsFixed(0)} تومان';
  }

  // Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'displayName': displayName,
      'passwordHash': passwordHash,
      'role': role.index, // Store enum index
      'createdAt': createdAt.toIso8601String(),
      'bio': bio,
      'profilePictureUrl': profilePictureUrl,
      'totalEarnings': totalEarnings,
      'pendingBalance': pendingBalance,
      'totalSales': totalSales,
    };
  }

  // Create from JSON (Local Storage)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      username: json['username'],
      displayName: json['displayName'],
      passwordHash: json['passwordHash'] ?? '',
      role: UserRole.values[json['role']],
      createdAt: DateTime.parse(json['createdAt']),
      bio: json['bio'],
      profilePictureUrl: json['profilePictureUrl'],
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
      pendingBalance: (json['pendingBalance'] ?? 0).toDouble(),
      totalSales: json['totalSales'] ?? 0,
    );
  }

  // Factory to update user from current instance
  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? displayName,
    String? passwordHash,
    UserRole? role,
    DateTime? createdAt,
    String? bio,
    String? profilePictureUrl,
    double? totalEarnings,
    double? pendingBalance,
    int? totalSales,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      bio: bio ?? this.bio,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      totalSales: totalSales ?? this.totalSales,
    );
  }
}
