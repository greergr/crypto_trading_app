import 'dart:convert';

class User {
  final String id;
  final String email;
  final String username;
  final String? binanceApiKey;
  final String? binanceSecretKey;

  const User({
    required this.id,
    required this.email,
    required this.username,
    this.binanceApiKey,
    this.binanceSecretKey,
  });

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? binanceApiKey,
    String? binanceSecretKey,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      binanceApiKey: binanceApiKey ?? this.binanceApiKey,
      binanceSecretKey: binanceSecretKey ?? this.binanceSecretKey,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'binanceApiKey': binanceApiKey,
      'binanceSecretKey': binanceSecretKey,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      binanceApiKey: json['binanceApiKey'] as String?,
      binanceSecretKey: json['binanceSecretKey'] as String?,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, username: $username, binanceApiKey: $binanceApiKey, binanceSecretKey: $binanceSecretKey)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is User &&
      other.id == id &&
      other.email == email &&
      other.username == username &&
      other.binanceApiKey == binanceApiKey &&
      other.binanceSecretKey == binanceSecretKey;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      email.hashCode ^
      username.hashCode ^
      binanceApiKey.hashCode ^
      binanceSecretKey.hashCode;
  }
}
