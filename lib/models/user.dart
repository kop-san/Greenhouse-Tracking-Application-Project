import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:developer' as developer;

enum UserRole {
  ADMIN,
  USER
}

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? token;
  final DateTime? tokenExpiry;
  final DateTime? lastLogin;
  final DateTime? lastLogout;
  final DateTime? createdAt;
  final String? profileImage;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.token,
    this.tokenExpiry,
    this.lastLogin,
    this.lastLogout,
    this.createdAt,
    this.profileImage,
  });

  bool get hasValidToken {
    if (token == null || tokenExpiry == null) return false;
    return DateTime.now().isBefore(tokenExpiry!);
  }

  factory User.fromAuthResponse(Map<String, dynamic> json) {
    return User.fromJson({
      ...json,
      'token': json['token'],
    });
  }

  factory User.fromJson(Map<String, dynamic> json) {
    String? token = json['token'];
    DateTime? tokenExpiry;
    
    if (token != null) {
      try {
        final decodedToken = JwtDecoder.decode(token);
        tokenExpiry = DateTime.fromMillisecondsSinceEpoch(decodedToken['exp'] * 1000);
      } catch (e) {
        developer.log(
          'Error decoding JWT token',
          name: 'User.fromJson',
          error: e,
        );
        token = null;
        tokenExpiry = null;
      }
    }

    // Handle both 'role' and 'roles' fields from server
    String roleStr = json['role'] ?? json['roles'] ?? 'USER';

    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: _parseRole(roleStr),
      token: token,
      tokenExpiry: tokenExpiry,
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      lastLogout: json['lastLogout'] != null ? DateTime.parse(json['lastLogout']) : null,
      createdAt: json['createdate'] != null ? DateTime.parse(json['createdate']) : 
                json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'roles': role.toString().split('.').last,
      if (token != null) 'token': token,
      'lastLogin': lastLogin?.toIso8601String(),
      'lastLogout': lastLogout?.toIso8601String(),
      'createdate': createdAt?.toIso8601String(),
      'profileImage': profileImage,
    };
  }

  static UserRole _parseRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return UserRole.ADMIN;
      default:
        return UserRole.USER;
    }
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? token,
    DateTime? tokenExpiry,
    DateTime? lastLogin,
    DateTime? lastLogout,
    DateTime? createdAt,
    String? profileImage,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      token: token ?? this.token,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      lastLogin: lastLogin ?? this.lastLogin,
      lastLogout: lastLogout ?? this.lastLogout,
      createdAt: createdAt ?? this.createdAt,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  bool get isAdmin => role == UserRole.ADMIN;
  bool get isUser => role == UserRole.USER;
  
  // For backward compatibility
  String get userName => name;
}
