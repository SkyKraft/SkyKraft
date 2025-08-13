import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';
import '../../constants/app_constants.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User Management
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'user_fetch_error',
        message: 'Failed to fetch user: $e',
      );
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'user_creation_error',
        message: 'Failed to create user: $e',
      );
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toFirestore());
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'user_update_error',
        message: 'Failed to update user: $e',
      );
    }
  }

  Future<void> updateUserLocation(String uid, double lat, double lng) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLat': lat,
        'lastLng': lng,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
        'isOnline': true,
      });
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'location_update_error',
        message: 'Failed to update location: $e',
      );
    }
  }

  // Pilot Discovery
  Stream<List<UserModel>> getPilotsStream() {
    return _firestore
        .collection('users')
        .where('accountType', isEqualTo: 'pilot')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .where((pilot) => pilot.hasLocation)
            .toList());
  }

  Future<List<UserModel>> getPilots() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('accountType', isEqualTo: 'pilot')
          .get();
      
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((pilot) => pilot.hasLocation)
          .toList();
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'pilots_fetch_error',
        message: 'Failed to fetch pilots: $e',
      );
    }
  }

  // Booking Management
  Future<String> createBooking(BookingModel booking) async {
    try {
      final docRef = await _firestore.collection('bookings').add(booking.toFirestore());
      return docRef.id;
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'booking_creation_error',
        message: 'Failed to create booking: $e',
      );
    }
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'booking_update_error',
        message: 'Failed to update booking: $e',
      );
    }
  }

  Stream<List<BookingModel>> getUserBookingsStream(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<BookingModel>> getPilotBookingsStream(String pilotId) {
    return _firestore
        .collection('bookings')
        .where('pilotId', isEqualTo: pilotId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('dateTime', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'bookings_fetch_error',
        message: 'Failed to fetch bookings: $e',
      );
    }
  }

  // Wallet Management
  Future<int> getWalletBalance(String userId) async {
    try {
      final doc = await _firestore.collection('wallets').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['balance'] as int? ?? AppConstants.defaultWalletBalance;
      }
      return AppConstants.defaultWalletBalance;
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'wallet_fetch_error',
        message: 'Failed to fetch wallet balance: $e',
      );
    }
  }

  Future<void> updateWalletBalance(String userId, int newBalance) async {
    try {
      await _firestore.collection('wallets').doc(userId).set({
        'balance': newBalance,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'wallet_update_error',
        message: 'Failed to update wallet balance: $e',
      );
    }
  }

  // Product Management
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'products_fetch_error',
        message: 'Failed to fetch products: $e',
      );
    }
  }

  // Analytics and Statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final bookings = await getUserBookings(userId);
      
      return {
        'totalBookings': bookings.length,
        'completedBookings': bookings.where((b) => b.isCompleted).length,
        'pendingBookings': bookings.where((b) => b.isPending).length,
        'totalSpent': bookings
            .where((b) => b.isCompleted)
            .fold(0.0, (sum, b) => sum + (b.amount ?? 0)),
      };
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'stats_fetch_error',
        message: 'Failed to fetch user stats: $e',
      );
    }
  }

  // Search and Filter
  Future<List<UserModel>> searchPilots({
    String? query,
    double? maxDistance,
    double? userLat,
    double? userLng,
  }) async {
    try {
      Query pilotsQuery = _firestore
          .collection('users')
          .where('accountType', isEqualTo: 'pilot');

      if (query != null && query.isNotEmpty) {
        // Note: Firestore doesn't support full-text search
        // This is a basic implementation
        pilotsQuery = pilotsQuery.where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThan: query + '\uf8ff');
      }

      final snapshot = await pilotsQuery.get();
      List<UserModel> pilots = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((pilot) => pilot.hasLocation)
          .toList();

      // Filter by distance if coordinates provided
      if (maxDistance != null && userLat != null && userLng != null) {
        pilots = pilots.where((pilot) {
          final distance = _calculateDistance(
            userLat, userLng,
            pilot.lastLat!, pilot.lastLng!,
          );
          return distance <= maxDistance;
        }).toList();
      }

      return pilots;
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'pilot_search_error',
        message: 'Failed to search pilots: $e',
      );
    }
  }

  // Utility methods
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // km
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(_degreesToRadians(lat1)) * sin(_degreesToRadians(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Error handling
  String getErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You don\'t have permission to perform this action.';
      case 'not-found':
        return 'The requested resource was not found.';
      case 'already-exists':
        return 'This resource already exists.';
      case 'resource-exhausted':
        return 'Service temporarily unavailable. Please try again later.';
      case 'failed-precondition':
        return 'Operation failed due to a precondition not being met.';
      case 'aborted':
        return 'Operation was aborted. Please try again.';
      case 'out-of-range':
        return 'Operation is out of valid range.';
      case 'unimplemented':
        return 'This operation is not implemented.';
      case 'internal':
        return 'An internal error occurred. Please try again.';
      case 'unavailable':
        return 'Service is currently unavailable. Please try again later.';
      case 'data-loss':
        return 'Data loss occurred. Please try again.';
      case 'unauthenticated':
        return 'You must be logged in to perform this action.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }
} 