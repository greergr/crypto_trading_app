import 'package:uuid/uuid.dart';

enum AccountType {
  demo,
  live
}

class User {
  final String id;
  final String email;
  String username;
  String? fullName;
  AccountType accountType;
  double demoBalance;
  String? binanceApiKey;
  String? binanceSecretKey;
  DateTime createdAt;
  DateTime lastLogin;
  bool isActive;
  Map<String, dynamic> preferences;

  User({
    String? id,
    required this.email,
    required this.username,
    this.fullName,
    this.accountType = AccountType.demo,
    this.demoBalance = 10000.0, // رصيد افتراضي 10,000 دولار
    this.binanceApiKey,
    this.binanceSecretKey,
    DateTime? createdAt,
    DateTime? lastLogin,
    this.isActive = true,
    Map<String, dynamic>? preferences,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        lastLogin = lastLogin ?? DateTime.now(),
        preferences = preferences ?? {};

  // تحويل البيانات إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'fullName': fullName,
      'accountType': accountType.toString(),
      'demoBalance': demoBalance,
      'binanceApiKey': binanceApiKey,
      'binanceSecretKey': binanceSecretKey,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'isActive': isActive,
      'preferences': preferences,
    };
  }

  // إنشاء كائن من JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      fullName: json['fullName'],
      accountType: AccountType.values.firstWhere(
        (e) => e.toString() == json['accountType'],
        orElse: () => AccountType.demo,
      ),
      demoBalance: json['demoBalance'] ?? 10000.0,
      binanceApiKey: json['binanceApiKey'],
      binanceSecretKey: json['binanceSecretKey'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: DateTime.parse(json['lastLogin']),
      isActive: json['isActive'] ?? true,
      preferences: json['preferences'] ?? {},
    );
  }

  // نسخ المستخدم مع تحديث بعض الحقول
  User copyWith({
    String? email,
    String? username,
    String? fullName,
    AccountType? accountType,
    double? demoBalance,
    String? binanceApiKey,
    String? binanceSecretKey,
    bool? isActive,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      accountType: accountType ?? this.accountType,
      demoBalance: demoBalance ?? this.demoBalance,
      binanceApiKey: binanceApiKey ?? this.binanceApiKey,
      binanceSecretKey: binanceSecretKey ?? this.binanceSecretKey,
      createdAt: createdAt,
      lastLogin: lastLogin,
      isActive: isActive ?? this.isActive,
      preferences: preferences ?? this.preferences,
    );
  }
}
