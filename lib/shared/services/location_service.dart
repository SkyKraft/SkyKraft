import 'dart:async';
import 'package:location/location.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final Location _location = Location();
  LocationData? _lastKnownLocation;
  bool _isListening = false;

  // Location data stream
  final StreamController<LocationData> _locationController = 
      StreamController<LocationData>.broadcast();
  Stream<LocationData> get locationStream => _locationController.stream;

  // Initialize location service
  Future<bool> initialize() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return false;
        }
      }

      // Check and request permissions
      PermissionStatus permissionStatus = await _location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await _location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          return false;
        }
      }

      // Get initial location
      await getCurrentLocation();
      return true;
    } catch (e) {
      print('LocationService initialization error: $e');
      return false;
    }
  }

  // Get current location
  Future<LocationData?> getCurrentLocation() async {
    try {
      final location = await _location.getLocation();
      _lastKnownLocation = location;
      _locationController.add(location);
      return location;
    } catch (e) {
      print('Get current location error: $e');
      return _lastKnownLocation;
    }
  }

  // Start listening to location updates
  Future<void> startLocationUpdates() async {
    if (_isListening) return;

    try {
      _isListening = true;
      
      // Listen to location changes
      _location.onLocationChanged.listen(
        (LocationData location) {
          _lastKnownLocation = location;
          _locationController.add(location);
        },
        onError: (e) {
          print('Location stream error: $e');
          _isListening = false;
        },
      );

    } catch (e) {
      print('Start location updates error: $e');
      _isListening = false;
    }
  }

  // Stop location updates
  void stopLocationUpdates() {
    _isListening = false;
  }

  // Get last known location
  LocationData? get lastKnownLocation => _lastKnownLocation;

  // Check if location service is active
  bool get isListening => _isListening;

  // Check if we have a valid location
  bool get hasValidLocation {
    return _lastKnownLocation != null &&
           _lastKnownLocation!.latitude != null &&
           _lastKnownLocation!.longitude != null;
  }

  // Get formatted location string
  String getFormattedLocation(LocationData? location) {
    if (location == null || location.latitude == null || location.longitude == null) {
      return 'Location not available';
    }
    
    return '${location.latitude!.toStringAsFixed(6)}, ${location.longitude!.toStringAsFixed(6)}';
  }

  // Dispose resources
  void dispose() {
    stopLocationUpdates();
    _locationController.close();
  }
} 