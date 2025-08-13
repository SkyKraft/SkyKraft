import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../constants/app_constants.dart';

enum BookingStatus {
  pending,
  accepted,
  rejected,
  cancelled,
  completed,
  inProgress
}

class BookingModel {
  final String id;
  final String pilotId;
  final String pilotName;
  final String pilotEmail;
  final String userId;
  final String userEmail;
  final String userName;
  final DateTime dateTime;
  final String? notes;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double? amount;
  final String? paymentStatus;
  final Map<String, dynamic>? metadata;

  const BookingModel({
    required this.id,
    required this.pilotId,
    required this.pilotName,
    required this.pilotEmail,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.dateTime,
    this.notes,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.amount,
    this.paymentStatus,
    this.metadata,
  });

  // Factory constructor from Firestore document
  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    return BookingModel(
      id: doc.id,
      pilotId: data['pilotId']?.toString() ?? '',
      pilotName: data['pilotName']?.toString() ?? '',
      pilotEmail: data['pilotEmail']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      userEmail: data['userEmail']?.toString() ?? '',
      userName: data['userName']?.toString() ?? '',
      dateTime: _parseTimestamp(data['dateTime']) ?? DateTime.now(),
      notes: data['notes']?.toString(),
      status: _parseStatus(data['status']?.toString()),
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
      updatedAt: _parseTimestamp(data['updatedAt']),
      amount: _parseDouble(data['amount']),
      paymentStatus: data['paymentStatus']?.toString(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'pilotId': pilotId,
      'pilotName': pilotName,
      'pilotEmail': pilotEmail,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'dateTime': Timestamp.fromDate(dateTime),
      'notes': notes,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'amount': amount,
      'paymentStatus': paymentStatus,
      'metadata': metadata,
    };
  }

  // Create a copy with updated fields
  BookingModel copyWith({
    String? id,
    String? pilotId,
    String? pilotName,
    String? pilotEmail,
    String? userId,
    String? userEmail,
    String? userName,
    DateTime? dateTime,
    String? notes,
    BookingStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? amount,
    String? paymentStatus,
    Map<String, dynamic>? metadata,
  }) {
    return BookingModel(
      id: id ?? this.id,
      pilotId: pilotId ?? this.pilotId,
      pilotName: pilotName ?? this.pilotName,
      pilotEmail: pilotEmail ?? this.pilotEmail,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      amount: amount ?? this.amount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      metadata: metadata ?? this.metadata,
    );
  }

  // Validation methods
  bool get isValid {
    return pilotId.isNotEmpty && 
           pilotName.isNotEmpty && 
           pilotEmail.isNotEmpty &&
           userId.isNotEmpty && 
           userEmail.isNotEmpty && 
           userName.isNotEmpty &&
           dateTime.isAfter(DateTime.now().add(const Duration(hours: 2)));
  }

  bool get isPending => status == BookingStatus.pending;
  bool get isAccepted => status == BookingStatus.accepted;
  bool get isRejected => status == BookingStatus.rejected;
  bool get isCancelled => status == BookingStatus.cancelled;
  bool get isCompleted => status == BookingStatus.completed;
  bool get isInProgress => status == BookingStatus.inProgress;
  bool get isActive => isAccepted || isInProgress;
  bool get canBeCancelled => isPending || isAccepted;
  bool get canBeAccepted => isPending;
  bool get canBeRejected => isPending;
  bool get canBeCompleted => isInProgress;

  // Business logic methods
  bool get isUpcoming {
    return dateTime.isAfter(DateTime.now()) && isActive;
  }

  bool get isPast {
    return dateTime.isBefore(DateTime.now());
  }

  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
           dateTime.month == now.month &&
           dateTime.day == now.day;
  }

  String get statusText {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.inProgress:
        return 'In Progress';
    }
  }

  String get statusColor {
    switch (status) {
      case BookingStatus.pending:
        return '#FF9800'; // Orange
      case BookingStatus.accepted:
        return '#4CAF50'; // Green
      case BookingStatus.rejected:
        return '#F44336'; // Red
      case BookingStatus.cancelled:
        return '#9E9E9E'; // Grey
      case BookingStatus.completed:
        return '#2196F3'; // Blue
      case BookingStatus.inProgress:
        return '#9C27B0'; // Purple
    }
  }

  String get formattedDateTime {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String get timeUntilBooking {
    final difference = dateTime.difference(DateTime.now());
    if (difference.isNegative) {
      return 'Past';
    }
    
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    
    if (days > 0) {
      return '$days day${days > 1 ? 's' : ''} $hours hour${hours > 1 ? 's' : ''}';
    } else if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''} $minutes minute${minutes > 1 ? 's' : ''}';
    } else {
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    }
  }

  // Helper methods
  static BookingStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'accepted':
        return BookingStatus.accepted;
      case 'rejected':
        return BookingStatus.rejected;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      case 'inprogress':
        return BookingStatus.inProgress;
      default:
        return BookingStatus.pending;
    }
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BookingModel(id: $id, pilot: $pilotName, user: $userName, status: $status, date: $formattedDateTime)';
  }
} 