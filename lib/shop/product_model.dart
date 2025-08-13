import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int stock;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      stock: map['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'stock': stock,
    };
  }
}

class BookingModel {
  final String id;
  final String pilotId;
  final String pilotName;
  final String pilotEmail;
  final String userId;
  final String userName;
  final String userEmail;
  final DateTime dateTime;
  final String notes;
  final DateTime? createdAt;
  final String status;

  BookingModel({
    required this.id,
    required this.pilotId,
    required this.pilotName,
    required this.pilotEmail,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.dateTime,
    required this.notes,
    required this.createdAt,
    required this.status,
  });

  factory BookingModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime? dateTime;
    if (map['dateTime'] is Timestamp) {
      dateTime = (map['dateTime'] as Timestamp).toDate();
    } else if (map['dateTime'] is DateTime) {
      dateTime = map['dateTime'] as DateTime;
    } else {
      dateTime = null;
    }

    DateTime? createdAt;
    if (map['createdAt'] is Timestamp) {
      createdAt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is DateTime) {
      createdAt = map['createdAt'] as DateTime;
    } else {
      createdAt = null;
    }

    return BookingModel(
      id: id,
      pilotId: map['pilotId'] ?? '',
      pilotName: map['pilotName'] ?? '',
      pilotEmail: map['pilotEmail'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      dateTime: dateTime ?? DateTime.now(),
      notes: map['notes'] ?? '',
      createdAt: createdAt,
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pilotId': pilotId,
      'pilotName': pilotName,
      'pilotEmail': pilotEmail,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'dateTime': dateTime,
      'notes': notes,
      'createdAt': createdAt,
      'status': status,
    };
  }
} 