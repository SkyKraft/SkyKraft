import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'SKYKRAFT';
  static const String appVersion = '7.0.0';
  static const String appDescription = 'The Ultimate Drone Pilot Aggregator Platform';
  
  // Company Information
  static const String companyName = 'Skykraft Technologies';
  static const String companyWebsite = 'https://skykraft.com';
  static const String companyEmail = 'support@skykraft.com';
  static const String companyPhone = '+1-800-SKYKRAFT';
  
  // Brand Colors
  static const int primaryColorValue = 0xFF1976D2;
  static const int secondaryColorValue = 0xFF00B8D9;
  static const int accentColorValue = 0xFF4CAF50;
  static const int warningColorValue = 0xFFFF9800;
  static const int errorColorValue = 0xFFD32F2F;
  
  // API Configuration
  static const String mapboxAccessToken = 'pk.eyJ1IjoidGhlZHJvbmFjaGFyeWEiLCJhIjoiY21kN3Jyczk2MG1sdDJuc2QxajBndWx5ZiJ9.xqtrf0d-wWFEPfLKin_M2g';
  static const String firebaseProjectId = 'skykraft-app';
  static const String firebaseRegion = 'us-central1';
  
  // Feature Flags
  static const bool enableRealTimeLocation = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePerformanceMonitoring = true;
  
  // Location Settings
  static const double defaultSearchRadius = 50.0; // km
  static const double maxSearchRadius = 200.0; // km
  static const double minSearchRadius = 5.0; // km
  static const int maxLocationAge = 3600000; // 1 hour in milliseconds
  
  // Pilot Discovery
  static const int maxPilotsPerPage = 20;
  static const int maxSpecializationsDisplay = 3;
  static const double minRatingThreshold = 0.0;
  static const double maxHourlyRate = 5000.0; // ₹
  static const double minHourlyRate = 100.0; // ₹
  
  // Booking System
  static const int maxAdvanceBookingDays = 365;
  static const int minAdvanceBookingHours = 2;
  static const int maxBookingDurationHours = 24;
  static const double defaultCancellationFee = 0.1; // 10%
  
  // Payment Settings
  static const String defaultCurrency = 'INR';
  static const List<String> supportedCurrencies = ['INR', 'USD', 'EUR', 'GBP'];
  static const double platformCommission = 0.15; // 15%
  static const double escrowHoldPercentage = 0.8; // 80%
  
  // Security Settings
  static const int passwordMinLength = 8;
  static const int maxLoginAttempts = 5;
  static const int sessionTimeoutMinutes = 60;
  static const bool requireEmailVerification = true;
  static const bool requirePhoneVerification = false;
  
  // Cache Settings
  static const int pilotDataCacheDuration = 300000; // 5 minutes
  static const int userProfileCacheDuration = 600000; // 10 minutes
  static const int mapTileCacheDuration = 86400000; // 24 hours
  static const int imageCacheDuration = 604800000; // 7 days
  
  // Animation Durations
  static const int splashAnimationDuration = 2500; // milliseconds
  static const int pageTransitionDuration = 300; // milliseconds
  static const int buttonPressDuration = 150; // milliseconds
  static const int loadingAnimationDuration = 2000; // milliseconds
  
  // UI Constants
  static const double defaultBorderRadius = 12.0;
  static const double buttonElevation = 2.0;
  static const double appBarElevation = 0.0;
  
  // Spacing Values
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Font Sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeXXXL = 24.0;
  
  // Icon Sizes
  static const double iconSizeXS = 16.0;
  static const double iconSizeS = 20.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;
  static const double iconSizeXXL = 64.0;
  
  // Map Settings
  static const double minMapZoom = 3.0;
  static const double maxMapZoom = 20.0;
  static const double pilotMarkerSize = 1.0;
  static const List<double> pilotMarkerOffset = [0.0, -20.0];
  
  // Error Messages
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String locationErrorMessage = 'Unable to get location. Please enable location services.';
  static const String authenticationErrorMessage = 'Authentication failed. Please try again.';
  static const String generalErrorMessage = 'Something went wrong. Please try again.';
  
  // Success Messages
  static const String bookingSuccessMessage = 'Booking confirmed successfully!';
  static const String profileUpdateMessage = 'Profile updated successfully!';
  static const String pilotFoundMessage = 'Pilot found and added to map!';
  
  // Validation Messages
  static const String emailRequiredMessage = 'Email is required';
  static const String passwordRequiredMessage = 'Password is required';
  static const String nameRequiredMessage = 'Name is required';
  static const String invalidEmailMessage = 'Please enter a valid email address';
  static const String passwordTooShortMessage = 'Password must be at least 8 characters';
  
  // Pilot Specializations
  static const List<String> pilotSpecializations = [
    'Aerial Photography',
    'Videography',
    'Surveying',
    'Inspection',
    'Delivery',
    'Agriculture',
    'Search & Rescue',
    'Entertainment',
    'Racing',
    'Custom'
  ];
  
  // Pilot Certifications
  static const List<String> pilotCertifications = [
    'None',
    'Basic',
    'Advanced',
    'Commercial',
    'Instructor'
  ];
  
  // Booking Statuses
  static const List<String> bookingStatuses = [
    'Pending',
    'Accepted',
    'Rejected',
    'Cancelled',
    'Completed',
    'In Progress'
  ];
  
  // Payment Statuses
  static const List<String> paymentStatuses = [
    'Pending',
    'Processing',
    'Completed',
    'Failed',
    'Refunded',
    'Cancelled'
  ];
  
  // Notification Types
  static const List<String> notificationTypes = [
    'Booking Request',
    'Booking Confirmed',
    'Booking Cancelled',
    'Payment Received',
    'Pilot Available',
    'System Update'
  ];
  
  // File Upload Limits
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxVideoSize = 50 * 1024 * 1024; // 50MB
  static const int maxDocumentSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedVideoFormats = ['mp4', 'mov', 'avi', 'mkv'];
  
  // Legacy Constants (for backward compatibility)
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 700);
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double smallPadding = 8.0;
  static const double borderRadius = 12.0;
  static const double largeBorderRadius = 20.0;
  static const double avatarRadius = 32.0;
  static const double largeAvatarRadius = 50.0;
  static const double logoSize = 100.0;
  static const double titleFontSize = 24.0;
  static const double subtitleFontSize = 18.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 14.0;
  static const double smallFontSize = 12.0;
  static const double cardElevation = 6.0;
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(hours: 24);
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
  static const int minBookingAdvanceHours = 2;
  static const int maxBookingAdvanceDays = 365;
  static const int defaultWalletBalance = 100;
  static const int minWalletBalance = 0;
  static const int maxWalletBalance = 100000;
  static const double defaultMapZoom = 3.8;
  static const double userLocationZoom = 14.0;
  static const double indiaLat = 22.5937;
  static const double indiaLng = 78.9629;
  static const double markerOffset = -20.0;
  static const Duration locationUpdateInterval = Duration(minutes: 5);
  static const double locationAccuracy = 10.0;
  static const String authErrorMessage = 'Authentication failed. Please try again.';
  static const String permissionErrorMessage = 'Permission denied. Please enable required permissions.';
  static const String locationUpdateMessage = 'Location updated successfully!';
  
  // Rate Limiting
  static const int maxApiRequestsPerMinute = 100;
  static const int maxLoginAttemptsPerHour = 10;
  static const int maxBookingRequestsPerDay = 5;
  static const int maxProfileUpdatesPerHour = 20;
  
  // Analytics Events
  static const String eventPilotSearched = 'pilot_searched';
  static const String eventPilotViewed = 'pilot_viewed';
  static const String eventBookingRequested = 'booking_requested';
  static const String eventBookingConfirmed = 'booking_confirmed';
  static const String eventPaymentCompleted = 'payment_completed';
  static const String eventAppOpened = 'app_opened';
  static const String eventMapViewed = 'map_viewed';
  
  // Deep Link Schemes
  static const String deepLinkScheme = 'skykraft';
  static const String deepLinkHost = 'skykraft.com';
  static const String deepLinkPilotPath = '/pilot';
  static const String deepLinkBookingPath = '/booking';
  static const String deepLinkProfilePath = '/profile';
  
  // Social Media
  static const String facebookUrl = 'https://facebook.com/skykraft';
  static const String twitterUrl = 'https://twitter.com/skykraft';
  static const String instagramUrl = 'https://instagram.com/skykraft';
  static const String linkedinUrl = 'https://linkedin.com/company/skykraft';
  static const String youtubeUrl = 'https://youtube.com/skykraft';
  
  // Support Information
  static const String supportEmail = 'support@skykraft.com';
  static const String supportPhone = '+1-800-SKYKRAFT';
  static const String supportHours = '24/7';
  static const String faqUrl = 'https://skykraft.com/faq';
  static const String helpCenterUrl = 'https://help.skykraft.com';
  
  // Legal Information
  static const String termsOfServiceUrl = 'https://skykraft.com/terms';
  static const String privacyPolicyUrl = 'https://skykraft.com/privacy';
  static const String cookiePolicyUrl = 'https://skykraft.com/cookies';
  static const String refundPolicyUrl = 'https://skykraft.com/refund';
  
  // Development Settings
  static const bool enableDebugMode = true;
  static const bool enableLogging = true;
  static const bool enablePerformanceProfiling = false;
  static const bool enableMockData = false;
  static const String mockDataPath = 'assets/mock/';
  
  // Testing Configuration
  static const int testTimeout = 30000; // milliseconds
  static const bool enableTestMode = false;
  static const String testApiEndpoint = 'https://test-api.skykraft.com';
  static const String testFirebaseProject = 'skykraft-test';
  
  // Localization
  static const String defaultLanguage = 'en';
  static const List<String> supportedLanguages = ['en', 'hi', 'es', 'fr', 'de', 'zh'];
  static const String defaultCountry = 'IN';
  static const List<String> supportedCountries = ['IN', 'US', 'GB', 'CA', 'AU'];
  
  // Accessibility
  static const bool enableLargeText = true;
  static const bool enableHighContrast = true;
  static const bool enableScreenReader = true;
  static const bool enableVoiceCommands = false;
  
  // Offline Support
  static const bool enableOfflineMode = true;
  static const int offlineDataRetentionDays = 7;
  static const bool enableBackgroundSync = true;
  static const int syncIntervalMinutes = 15;
  
  // Privacy Settings
  static const bool enableLocationTracking = true;
  static const bool enableAnalyticsTracking = true;
  static const bool enableUserBehaviorTracking = false;
  static const int dataRetentionDays = 365;
  
  // Performance Settings
  static const bool enableImageCompression = true;
  static const bool enableLazyLoading = true;
  static const bool enableCaching = true;
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int cacheExpirationDays = 30;
}

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF1565C0);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF00B8D9);
  static const Color secondaryLight = Color(0xFF4DD0E1);
  static const Color secondaryDark = Color(0xFF0097A7);
  
  // Background Colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF121212);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [primary, secondary];
  static const List<Color> darkGradient = [Color(0xFF101C2C), Color(0xFF22304A)];
  
  // Transparent Colors
  static const Color transparent = Colors.transparent;
  static const Color overlay = Color(0x80000000);
  static const Color shadow = Color(0x1A000000);
}

class AppSizes {
  // Button Sizes
  static const double buttonHeight = 48.0;
  static const double buttonRadius = 12.0;
  static const double iconButtonSize = 48.0;
  
  // Input Sizes
  static const double inputHeight = 56.0;
  static const double inputRadius = 12.0;
  
  // Card Sizes
  static const double cardRadius = 20.0;
  static const double cardPadding = 16.0;
  
  // Logo Sizes
  static const double logoSize = 80.0;
  static const double logoSmall = 40.0;
  static const double logoLarge = 120.0;
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
}

class AppStrings {
  // Navigation
  static const String mapTab = 'Map';
  static const String shopTab = 'Shop';
  static const String bookingsTab = 'Bookings';
  static const String profileTab = 'Profile';
  
  // Auth
  static const String loginTitle = 'Welcome Back';
  static const String signupTitle = 'Create Account';
  static const String emailHint = 'Email';
  static const String passwordHint = 'Password';
  static const String nameHint = 'Full Name';
  static const String accountTypeHint = 'Account Type';
  
  // Map
  static const String mapTitle = 'Find Pilots';
  static const String pilotMarker = 'Pilot Location';
  static const String refreshLocations = 'Refresh Pilot Locations';
  static const String liveLocation = 'Live Location Available';
  
  // Booking
  static const String bookPilot = 'Book Pilot';
  static const String viewProfile = 'View Profile';
  static const String bookingSuccess = 'Booking requested!';
  static const String selectDateTime = 'Please select date and time';
  
  // Profile
  static const String editProfile = 'Edit Profile';
  static const String saveChanges = 'Save Changes';
  static const String logout = 'Logout';
  static const String deleteAccount = 'Delete Account';
  
  // Shop
  static const String shopTitle = 'SkyShop';
  static const String addToCart = 'Add to Cart';
  static const String buyNow = 'Buy Now';
  
  // Wallet
  static const String walletTitle = 'Skycoins Wallet';
  static const String balance = 'Balance';
  static const String skycoinValue = '1 Skycoin = ₹1';
  
  // Errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Network error. Please check your connection.';
  static const String authError = 'Authentication failed. Please try again.';
} 
// App Version Information
class AppVersion {
  static const String version = '7.0.0';
  static const int buildNumber = 1;
  static const String fullVersion = '7.0.0+1';
}
