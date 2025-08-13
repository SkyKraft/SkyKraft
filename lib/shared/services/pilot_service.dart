import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/pilot_model.dart';

class PilotService extends GetxService {
  static PilotService get to => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Observable lists for real-time updates
  final RxList<PilotModel> _allPilots = <PilotModel>[].obs;
  final RxList<PilotModel> _filteredPilots = <PilotModel>[].obs;
  final RxList<PilotModel> _nearbyPilots = <PilotModel>[].obs;
  
  // Search and filter state
  final RxString _searchQuery = ''.obs;
  final RxList<PilotSpecialization> _selectedSpecializations = <PilotSpecialization>[].obs;
  final RxDouble _maxDistance = 50.0.obs; // km
  final RxDouble _minRating = 0.0.obs;
  final RxDouble _maxHourlyRate = 1000.0.obs;
  final RxBool _verifiedOnly = false.obs;
  final RxBool _availableOnly = true.obs;
  
  // Getters
  List<PilotModel> get allPilots => _allPilots;
  List<PilotModel> get filteredPilots => _filteredPilots;
  List<PilotModel> get nearbyPilots => _nearbyPilots;
  String get searchQuery => _searchQuery.value;
  List<PilotSpecialization> get selectedSpecializations => _selectedSpecializations;
  double get maxDistance => _maxDistance.value;
  double get minRating => _minRating.value;
  double get maxHourlyRate => _maxHourlyRate.value;
  bool get verifiedOnly => _verifiedOnly.value;
  bool get availableOnly => _availableOnly.value;
  
  @override
  void onInit() {
    super.onInit();
    _initializePilotStream();
  }
  
  // Initialize real-time pilot stream
  void _initializePilotStream() {
    _firestore
        .collection('users')
        .where('accountType', isEqualTo: 'pilot')
        .snapshots()
        .listen((snapshot) {
      _allPilots.clear();
      for (final doc in snapshot.docs) {
        try {
          final pilot = PilotModel.fromFirestore(doc);
          _allPilots.add(pilot);
        } catch (e) {
          print('Error parsing pilot: $e');
        }
      }
      _applyFilters();
    });
  }
  
  // Search pilots by query
  void searchPilots(String query) {
    _searchQuery.value = query.toLowerCase();
    _applyFilters();
  }
  
  // Filter by specializations
  void filterBySpecializations(List<PilotSpecialization> specializations) {
    _selectedSpecializations.clear();
    _selectedSpecializations.addAll(specializations);
    _applyFilters();
  }
  
  // Filter by distance
  void filterByDistance(double maxDistance) {
    _maxDistance.value = maxDistance;
    _applyFilters();
  }
  
  // Filter by rating
  void filterByRating(double minRating) {
    _minRating.value = minRating;
    _applyFilters();
  }
  
  // Filter by hourly rate
  void filterByHourlyRate(double maxHourlyRate) {
    _maxHourlyRate.value = maxHourlyRate;
    _applyFilters();
  }
  
  // Filter by verification status
  void filterByVerification(bool verifiedOnly) {
    _verifiedOnly.value = verifiedOnly;
    _applyFilters();
  }
  
  // Filter by availability
  void filterByAvailability(bool availableOnly) {
    _availableOnly.value = availableOnly;
    _applyFilters();
  }
  
  // Apply all filters
  void _applyFilters() {
    _filteredPilots.clear();
    
    for (final pilot in _allPilots) {
      if (_matchesSearchQuery(pilot) &&
          _matchesSpecializations(pilot) &&
          _matchesRating(pilot) &&
          _matchesHourlyRate(pilot) &&
          _matchesVerification(pilot) &&
          _matchesAvailability(pilot)) {
        _filteredPilots.add(pilot);
      }
    }
    
    // Sort by relevance (rating, distance, availability)
    _filteredPilots.sort((a, b) {
      // Premium pilots first
      if (a.isPremium != b.isPremium) {
        return a.isPremium ? -1 : 1;
      }
      
      // Then by rating
      if (a.rating != b.rating) {
        return b.rating.compareTo(a.rating);
      }
      
      // Then by availability
      if (a.isAvailable != b.isAvailable) {
        return a.isAvailable ? -1 : 1;
      }
      
      // Then by experience
      return b.yearsOfExperience.compareTo(a.yearsOfExperience);
    });
  }
  
  // Check if pilot matches search query
  bool _matchesSearchQuery(PilotModel pilot) {
    if (_searchQuery.value.isEmpty) return true;
    
    final query = _searchQuery.value;
    return pilot.name.toLowerCase().contains(query) ||
           pilot.location?.toLowerCase().contains(query) == true ||
           pilot.specializationTexts.any((spec) => spec.toLowerCase().contains(query)) ||
           pilot.droneModels.any((model) => model.toLowerCase().contains(query));
  }
  
  // Check if pilot matches specializations
  bool _matchesSpecializations(PilotModel pilot) {
    if (_selectedSpecializations.isEmpty) return true;
    return _selectedSpecializations.any((spec) => pilot.specializations.contains(spec));
  }
  
  // Check if pilot matches rating
  bool _matchesRating(PilotModel pilot) {
    return pilot.rating >= _minRating.value;
  }
  
  // Check if pilot matches hourly rate
  bool _matchesHourlyRate(PilotModel pilot) {
    return pilot.hourlyRate <= _maxHourlyRate.value;
  }
  
  // Check if pilot matches verification
  bool _matchesVerification(PilotModel pilot) {
    if (!_verifiedOnly.value) return true;
    return pilot.isVerified;
  }
  
  // Check if pilot matches availability
  bool _matchesAvailability(PilotModel pilot) {
    if (!_availableOnly.value) return true;
    return pilot.isAvailable;
  }
  
  // Get pilots near a specific location
  Future<List<PilotModel>> getPilotsNearLocation(double lat, double lng, double radiusKm) async {
    // For now, we'll filter by approximate distance
    // In production, you might want to use Firestore GeoPoint queries
    final nearbyPilots = _allPilots.where((pilot) {
      if (pilot.lastLat == null || pilot.lastLng == null) return false;
      
      final distance = _calculateDistance(
        lat, lng, 
        pilot.lastLat!, pilot.lastLng!
      );
      
      return distance <= radiusKm;
    }).toList();
    
    // Sort by distance
    nearbyPilots.sort((a, b) {
      final distanceA = _calculateDistance(lat, lng, a.lastLat!, a.lastLng!);
      final distanceB = _calculateDistance(lat, lng, b.lastLat!, b.lastLng!);
      return distanceA.compareTo(distanceB);
    });
    
    return nearbyPilots;
  }
  
  // Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // km
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
               cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
               sin(dLng / 2) * sin(dLng / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
  
  // Get pilot by ID
  Future<PilotModel?> getPilotById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return PilotModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting pilot: $e');
      return null;
    }
  }
  
  // Update pilot location
  Future<void> updatePilotLocation(String uid, double lat, double lng) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLat': lat,
        'lastLng': lng,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
        'isOnline': true,
      });
    } catch (e) {
      print('Error updating pilot location: $e');
    }
  }
  
  // Update pilot availability
  Future<void> updatePilotAvailability(String uid, bool isAvailable) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating pilot availability: $e');
    }
  }
  
  // Update pilot online status
  Future<void> updatePilotOnlineStatus(String uid, bool isOnline) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isOnline': isOnline,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating pilot online status: $e');
    }
  }
  
  // Get pilots by specialization
  List<PilotModel> getPilotsBySpecialization(PilotSpecialization specialization) {
    return _allPilots.where((pilot) => 
      pilot.specializations.contains(specialization)
    ).toList();
  }
  
  // Get premium pilots
  List<PilotModel> getPremiumPilots() {
    return _allPilots.where((pilot) => pilot.isPremium).toList();
  }
  
  // Get verified pilots
  List<PilotModel> getVerifiedPilots() {
    return _allPilots.where((pilot) => pilot.isVerified).toList();
  }
  
  // Get available pilots
  List<PilotModel> getAvailablePilots() {
    return _allPilots.where((pilot) => pilot.isAvailable).toList();
  }
  
  // Get online pilots
  List<PilotModel> getOnlinePilots() {
    return _allPilots.where((pilot) => pilot.isOnline).toList();
  }
  
  // Clear all filters
  void clearFilters() {
    _searchQuery.value = '';
    _selectedSpecializations.clear();
    _maxDistance.value = 50.0;
    _minRating.value = 0.0;
    _maxHourlyRate.value = 1000.0;
    _verifiedOnly.value = false;
    _availableOnly.value = true;
    _applyFilters();
  }
  
  // Get filter summary
  Map<String, dynamic> getFilterSummary() {
    return {
      'totalPilots': _allPilots.length,
      'filteredPilots': _filteredPilots.length,
      'searchQuery': _searchQuery.value,
      'specializations': _selectedSpecializations.map((s) => s.name).toList(),
      'maxDistance': _maxDistance.value,
      'minRating': _minRating.value,
      'maxHourlyRate': _maxHourlyRate.value,
      'verifiedOnly': _verifiedOnly.value,
      'availableOnly': _availableOnly.value,
    };
  }
  
  // Dispose
  @override
  void onClose() {
    _allPilots.clear();
    _filteredPilots.clear();
    _nearbyPilots.clear();
    super.onClose();
  }
}
