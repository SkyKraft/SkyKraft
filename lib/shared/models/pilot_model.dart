import 'package:cloud_firestore/cloud_firestore.dart';

enum PilotSpecialization {
  aerialPhotography,
  videography,
  surveying,
  inspection,
  delivery,
  agriculture,
  searchAndRescue,
  entertainment,
  racing,
  custom
}

enum PilotCertification {
  none,
  basic,
  advanced,
  commercial,
  instructor
}

class PilotModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? bio;
  final String? phone;
  final String? location;
  
  // Pilot-specific fields
  final List<PilotSpecialization> specializations;
  final PilotCertification certification;
  final String? licenseNumber;
  final DateTime? licenseExpiry;
  final int yearsOfExperience;
  final double rating;
  final int totalBookings;
  final int completedBookings;
  final int cancelledBookings;
  final List<String> certifications;
  final List<String> droneModels;
  final Map<String, dynamic>? insurance;
  final Map<String, dynamic>? availability;
  
  // Location & Status
  final double? lastLat;
  final double? lastLng;
  final DateTime? lastLocationUpdate;
  final bool isOnline;
  final bool isAvailable;
  final bool isVerified;
  
  // Financial
  final double hourlyRate;
  final String? currency;
  final bool acceptsNegotiation;
  
  // Portfolio
  final List<String> portfolioImages;
  final List<String> portfolioVideos;
  final String? portfolioDescription;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const PilotModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.bio,
    this.phone,
    this.location,
    required this.specializations,
    required this.certification,
    this.licenseNumber,
    this.licenseExpiry,
    required this.yearsOfExperience,
    required this.rating,
    required this.totalBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.certifications,
    required this.droneModels,
    this.insurance,
    this.availability,
    this.lastLat,
    this.lastLng,
    this.lastLocationUpdate,
    required this.isOnline,
    required this.isAvailable,
    required this.isVerified,
    required this.hourlyRate,
    this.currency,
    required this.acceptsNegotiation,
    required this.portfolioImages,
    required this.portfolioVideos,
    this.portfolioDescription,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from Firestore document
  factory PilotModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    return PilotModel(
      uid: doc.id,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      photoUrl: data['photoUrl']?.toString(),
      bio: data['bio']?.toString(),
      phone: data['phone']?.toString(),
      location: data['location']?.toString(),
      specializations: _parseSpecializations(data['specializations']),
      certification: _parseCertification(data['certification']),
      licenseNumber: data['licenseNumber']?.toString(),
      licenseExpiry: _parseTimestamp(data['licenseExpiry']),
      yearsOfExperience: data['yearsOfExperience']?.toInt() ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalBookings: data['totalBookings']?.toInt() ?? 0,
      completedBookings: data['completedBookings']?.toInt() ?? 0,
      cancelledBookings: data['cancelledBookings']?.toInt() ?? 0,
      certifications: List<String>.from(data['certifications'] ?? []),
      droneModels: List<String>.from(data['droneModels'] ?? []),
      insurance: data['insurance'] as Map<String, dynamic>?,
      availability: data['availability'] as Map<String, dynamic>?,
      lastLat: _parseDouble(data['lastLat']),
      lastLng: _parseDouble(data['lastLng']),
      lastLocationUpdate: _parseTimestamp(data['lastLocationUpdate']),
      isOnline: data['isOnline'] == true,
      isAvailable: data['isAvailable'] == true,
      isVerified: data['isVerified'] == true,
      hourlyRate: (data['hourlyRate'] ?? 0.0).toDouble(),
      currency: data['currency']?.toString() ?? 'USD',
      acceptsNegotiation: data['acceptsNegotiation'] == true,
      portfolioImages: List<String>.from(data['portfolioImages'] ?? []),
      portfolioVideos: List<String>.from(data['portfolioVideos'] ?? []),
      portfolioDescription: data['portfolioDescription']?.toString(),
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
      updatedAt: _parseTimestamp(data['updatedAt']) ?? DateTime.now(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'phone': phone,
      'location': location,
      'specializations': specializations.map((s) => s.name).toList(),
      'certification': certification.name,
      'licenseNumber': licenseNumber,
      'licenseExpiry': licenseExpiry != null ? Timestamp.fromDate(licenseExpiry!) : null,
      'yearsOfExperience': yearsOfExperience,
      'rating': rating,
      'totalBookings': totalBookings,
      'completedBookings': completedBookings,
      'cancelledBookings': cancelledBookings,
      'certifications': certifications,
      'droneModels': droneModels,
      'insurance': insurance,
      'availability': availability,
      'lastLat': lastLat,
      'lastLng': lastLng,
      'lastLocationUpdate': lastLocationUpdate != null ? Timestamp.fromDate(lastLocationUpdate!) : null,
      'isOnline': isOnline,
      'isAvailable': isAvailable,
      'isVerified': isVerified,
      'hourlyRate': hourlyRate,
      'currency': currency,
      'acceptsNegotiation': acceptsNegotiation,
      'portfolioImages': portfolioImages,
      'portfolioVideos': portfolioVideos,
      'portfolioDescription': portfolioDescription,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Create a copy with updated fields
  PilotModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    String? bio,
    String? phone,
    String? location,
    List<PilotSpecialization>? specializations,
    PilotCertification? certification,
    String? licenseNumber,
    DateTime? licenseExpiry,
    int? yearsOfExperience,
    double? rating,
    int? totalBookings,
    int? completedBookings,
    int? cancelledBookings,
    List<String>? certifications,
    List<String>? droneModels,
    Map<String, dynamic>? insurance,
    Map<String, dynamic>? availability,
    double? lastLat,
    double? lastLng,
    DateTime? lastLocationUpdate,
    bool? isOnline,
    bool? isAvailable,
    bool? isVerified,
    double? hourlyRate,
    String? currency,
    bool? acceptsNegotiation,
    List<String>? portfolioImages,
    List<String>? portfolioVideos,
    String? portfolioDescription,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PilotModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      specializations: specializations ?? this.specializations,
      certification: certification ?? this.certification,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      rating: rating ?? this.rating,
      totalBookings: totalBookings ?? this.totalBookings,
      completedBookings: completedBookings ?? this.completedBookings,
      cancelledBookings: cancelledBookings ?? this.cancelledBookings,
      certifications: certifications ?? this.certifications,
      droneModels: droneModels ?? this.droneModels,
      insurance: insurance ?? this.insurance,
      availability: availability ?? this.availability,
      lastLat: lastLat ?? this.lastLat,
      lastLng: lastLng ?? this.lastLng,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      isOnline: isOnline ?? this.isOnline,
      isAvailable: isAvailable ?? this.isAvailable,
      isVerified: isVerified ?? this.isVerified,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      currency: currency ?? this.currency,
      acceptsNegotiation: acceptsNegotiation ?? this.acceptsNegotiation,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      portfolioVideos: portfolioVideos ?? this.portfolioVideos,
      portfolioDescription: portfolioDescription ?? this.portfolioDescription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Business logic methods
  bool get isRecentlyActive {
    if (lastLocationUpdate == null) return false;
    return DateTime.now().difference(lastLocationUpdate!) < const Duration(hours: 1);
  }

  bool get hasValidLicense {
    if (licenseExpiry == null) return false;
    return licenseExpiry!.isAfter(DateTime.now());
  }

  double get completionRate {
    if (totalBookings == 0) return 0.0;
    return (completedBookings / totalBookings) * 100;
  }

  double get cancellationRate {
    if (totalBookings == 0) return 0.0;
    return (cancelledBookings / totalBookings) * 100;
  }

  String get statusText {
    if (!isAvailable) return 'Unavailable';
    if (isOnline && isRecentlyActive) return 'Online';
    if (isRecentlyActive) return 'Recently Active';
    return 'Offline';
  }

  String get experienceText {
    if (yearsOfExperience == 0) return 'New Pilot';
    if (yearsOfExperience == 1) return '1 year experience';
    return '$yearsOfExperience years experience';
  }

  String get certificationText {
    switch (certification) {
      case PilotCertification.none:
        return 'No Certification';
      case PilotCertification.basic:
        return 'Basic Certification';
      case PilotCertification.advanced:
        return 'Advanced Certification';
      case PilotCertification.commercial:
        return 'Commercial Certification';
      case PilotCertification.instructor:
        return 'Instructor Certification';
    }
  }

  List<String> get specializationTexts {
    return specializations.map((s) => s.name.replaceAll('_', ' ').toUpperCase()).toList();
  }

  // Validation methods
  bool get isValid {
    return name.isNotEmpty && 
           email.isNotEmpty && 
           specializations.isNotEmpty &&
           hourlyRate > 0 &&
           _isValidEmail(email);
  }

  bool get isPremium {
    return isVerified && 
           hasValidLicense && 
           rating >= 4.5 && 
           completionRate >= 90 &&
           yearsOfExperience >= 2;
  }

  // Helper methods
  static List<PilotSpecialization> _parseSpecializations(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) {
        if (item is String) {
          return PilotSpecialization.values.firstWhere(
            (e) => e.name == item,
            orElse: () => PilotSpecialization.custom,
          );
        }
        return PilotSpecialization.custom;
      }).toList();
    }
    return [];
  }

  static PilotCertification _parseCertification(dynamic value) {
    if (value == null) return PilotCertification.none;
    if (value is String) {
      return PilotCertification.values.firstWhere(
        (e) => e.name == value,
        orElse: () => PilotCertification.none,
      );
    }
    return PilotCertification.none;
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
    return other is PilotModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'PilotModel(uid: $uid, name: $name, rating: $rating, specializations: $specializations)';
  }
}
