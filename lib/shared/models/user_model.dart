import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String accountType;
  final String? photoUrl;
  final double? lastLat;
  final double? lastLng;
  final DateTime? lastLocationUpdate;
  final String? experience;
  final double? rating;
  final int? totalBookings;
  final int? completedBookings;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isVerified;
  final bool isOnline;
  final Map<String, dynamic>? preferences;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.accountType,
    this.photoUrl,
    this.lastLat,
    this.lastLng,
    this.lastLocationUpdate,
    this.experience,
    this.rating,
    this.totalBookings,
    this.completedBookings,
    this.createdAt,
    this.updatedAt,
    this.isVerified = false,
    this.isOnline = false,
    this.preferences,
  });

  // Factory constructor from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    return UserModel(
      uid: doc.id,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      accountType: data['accountType']?.toString() ?? 'user',
      photoUrl: data['photoUrl']?.toString(),
      lastLat: _parseDouble(data['lastLat']),
      lastLng: _parseDouble(data['lastLng']),
      lastLocationUpdate: _parseTimestamp(data['lastLocationUpdate']),
      experience: data['experience']?.toString(),
      rating: _parseDouble(data['rating']),
      totalBookings: _parseInt(data['totalBookings']),
      completedBookings: _parseInt(data['completedBookings']),
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      isVerified: data['isVerified'] == true,
      isOnline: data['isOnline'] == true,
      preferences: data['preferences'] as Map<String, dynamic>?,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'accountType': accountType,
      'photoUrl': photoUrl,
      'lastLat': lastLat,
      'lastLng': lastLng,
      'lastLocationUpdate': lastLocationUpdate != null 
          ? Timestamp.fromDate(lastLocationUpdate!) 
          : null,
      'experience': experience,
      'rating': rating,
      'totalBookings': totalBookings,
      'completedBookings': completedBookings,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isVerified': isVerified,
      'isOnline': isOnline,
      'preferences': preferences,
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? accountType,
    String? photoUrl,
    double? lastLat,
    double? lastLng,
    DateTime? lastLocationUpdate,
    String? experience,
    double? rating,
    int? totalBookings,
    int? completedBookings,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    bool? isOnline,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      accountType: accountType ?? this.accountType,
      photoUrl: photoUrl ?? this.photoUrl,
      lastLat: lastLat ?? this.lastLat,
      lastLng: lastLng ?? this.lastLng,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      experience: experience ?? this.experience,
      rating: rating ?? this.rating,
      totalBookings: totalBookings ?? this.totalBookings,
      completedBookings: completedBookings ?? this.completedBookings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      preferences: preferences ?? this.preferences,
    );
  }

  // Validation methods
  bool get isValid {
    return name.isNotEmpty && 
           email.isNotEmpty && 
           accountType.isNotEmpty &&
           _isValidEmail(email);
  }

  bool get isPilot => accountType == 'pilot';
  bool get isUser => accountType == 'user';
  bool get hasLocation => lastLat != null && lastLng != null;
  bool get isRecentlyActive {
    if (lastLocationUpdate == null) return false;
    return DateTime.now().difference(lastLocationUpdate!) < const Duration(hours: 1);
  }

  // Business logic methods
  double get completionRate {
    if (totalBookings == null || totalBookings == 0) return 0.0;
    return (completedBookings ?? 0) / totalBookings! * 100;
  }

  String get displayName {
    return name.isNotEmpty ? name : 'Unknown User';
  }

  String get statusText {
    if (isPilot) {
      if (isOnline && isRecentlyActive) return 'Online';
      if (isRecentlyActive) return 'Recently Active';
      return 'Offline';
    }
    return 'User';
  }

  // Helper methods
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, accountType: $accountType)';
  }
} 