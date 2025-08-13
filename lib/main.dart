import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth/auth_controller.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:location/location.dart' as loc;
import 'package:app_settings/app_settings.dart';
import 'shared/widgets/app_logo.dart';
import 'user/user_model.dart';
import 'shop/product_model.dart';
import 'core/theme_controller.dart';
import 'core/app_theme.dart';
import 'shared/widgets/theme_toggle.dart';
import 'shared/services/pilot_service.dart';
import 'shared/services/error_service.dart';
import 'features/pilot_discovery/pilot_discovery_page.dart';

// Place this at the top-level, after imports and before any widget/class definitions
class PilotAnnotationClickListener extends mapbox.OnPointAnnotationClickListener {
  final List<mapbox.PointAnnotation> annotations;
  final List<Map<String, dynamic>> pilotDataList;
  final void Function(Map<String, dynamic>?) onPilotSelected;

  PilotAnnotationClickListener({
    required this.annotations,
    required this.pilotDataList,
    required this.onPilotSelected,
  });

  @override
  void onPointAnnotationClick(mapbox.PointAnnotation annotation) {
    final idx = annotations.indexOf(annotation);
    if (idx != -1) {
      onPilotSelected(pilotDataList[idx]);
    }
  }
}

void main() async {
  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    ErrorService().handleError(
      details.exception,
      context: 'Flutter Framework Error',
    );
  };

  // Handle async errors
  FlutterError.onError = (FlutterErrorDetails details) {
    ErrorService().handleError(
      details.exception,
      context: 'Flutter Framework Error',
    );
  };

  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Test Firebase connection
    try {
      await FirebaseFirestore.instance.collection('test').get();
    } catch (e) {
      // Ignore test collection errors
      ErrorService().showInfo('Firebase connection established');
    }
    
    // Register controllers globally for GetX
    Get.put(AuthController());
    Get.put(ThemeController());
    Get.put(PilotService());
    Get.put(ErrorService());
    
    runApp(const SkykraftApp());
  } catch (e, stackTrace) {
    // Handle initialization errors
    ErrorService().handleError(
      e,
      context: 'App Initialization',
    );
    
    // Show error screen if critical initialization fails
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Failed to initialize app',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Please restart the app'),
            ],
          ),
        ),
      ),
    ));
  }
}

class SkykraftApp extends StatelessWidget {
  const SkykraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SKYKRAFT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/auth', page: () => const LoginScreen()),
        GetPage(name: '/signup', page: () => const SignupScreen()),
        GetPage(name: '/main', page: () => const MainNavScreen()),
      ],
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _textFadeAnim;
  late Animation<double> _shimmerAnim;
  late Animation<double> _logoRotateAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _textFadeAnim = CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeIn));
    _shimmerAnim = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _logoRotateAnim = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 3000), () {
      final user = AuthController.to.firebaseUser.value;
      if (user == null) {
        Get.offAllNamed('/auth');
      } else {
        Get.offAllNamed('/main');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController());
    }
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF00B8D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: Colors.white,
                      child: Center(
                        child: SkykraftSmallLogo(
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _textFadeAnim,
                child: AnimatedBuilder(
                  animation: _shimmerAnim,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.5),
                            Colors.white.withValues(alpha: _shimmerAnim.value),
                            Colors.white.withValues(alpha: 0.5),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ).createShader(bounds);
                      },
                      child: child,
                    );
                  },
                  child: Text(
                    'Take flight with Skykraft',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: AnimatedGradientLoader(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Skycoins Wallet (mock logic)
class SkycoinsWallet {
  // For MVP, fetch a mock value from Firestore or return a default
  static Future<int> getBalance(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('wallets').doc(uid).get();
    if (doc.exists && doc.data() != null && doc.data()!['balance'] != null) {
      return doc.data()!['balance'] as int;
    }
    return 100; // Default mock value
  }
}

// Main Navigation (Map, Shop, Profile)
class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const MapPage(),
    const PilotDiscoveryPage(),
    const MyBookingsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = AuthController.to.firebaseUser.value;
    return FutureBuilder<int>(
      future: user != null ? SkycoinsWallet.getBalance(user.uid) : Future.value(0),
      builder: (context, snapshot) {
        final balance = snapshot.data ?? 0;
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                SkykraftSmallLogo(size: 32),
                const SizedBox(width: 12),
                                  const Text(
                    'SKYKRAFT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
              ],
            ),
            actions: [
              Row(
                children: [
                  Text('₹$balance', style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.account_balance_wallet),
                    tooltip: 'Skycoins Wallet',
                    onPressed: () => Get.to(() => SkycoinsDetailsPage(balance: balance)),
                  ),
                  const SizedBox(width: 8),
                  const ThemeToggle(),
                ],
              ),
            ],
          ),
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black54,
            selectedLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14),
            unselectedLabelStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w400, fontSize: 13),
            elevation: 8,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
              BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'Bookings'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}

// Skycoins Details Page
class SkycoinsDetailsPage extends StatefulWidget {
  final int balance;
  const SkycoinsDetailsPage({super.key, required this.balance});

  @override
  State<SkycoinsDetailsPage> createState() => _SkycoinsDetailsPageState();
}

class _SkycoinsDetailsPageState extends State<SkycoinsDetailsPage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skycoins Wallet')),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance_wallet, size: 64),
                const SizedBox(height: 24),
                Text('Your Skycoins Balance', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('₹${widget.balance}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                const Text('1 Skycoin = ₹1'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Profile Page
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late Future<UserModel?> _userFuture;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<UserModel?> _fetchUser() async {
    final user = AuthController.to.firebaseUser.value;
    if (user == null) return null;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      // Fallback: create a minimal user document
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? 'Unknown',
        'email': user.email ?? '',
        'accountType': 'pilot',
        'photoUrl': user.photoURL ?? '',
      });
      return UserModel(
        uid: user.uid,
        name: user.displayName ?? 'Unknown',
        email: user.email ?? '',
        accountType: 'pilot',
        photoUrl: user.photoURL ?? '',
      );
    }
    return UserModel.fromMap(doc.data()!);
  }

  void _retry() {
    setState(() {
      _userFuture = _fetchUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = AuthController.to.firebaseUser.value;
    if (user == null) {
      // Not logged in, redirect to login
      Future.delayed(Duration.zero, () => Get.offAllNamed('/auth'));
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load profile:\n\t${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _retry,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: const Center(
              child: Text('No user data found.', style: TextStyle(color: Colors.red)),
            ),
          );
        }
        final userModel = snapshot.data!;
        final String? photoUrl = userModel.photoUrl is String ? userModel.photoUrl as String : null;
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF101C2C) : const Color(0xFFF5F7FA),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header with gradient and avatar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 64, bottom: 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF22304A), const Color(0xFF101C2C)]
                          : [theme.primaryColor, const Color(0xFF00B8D9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withAlpha(60) : Colors.black.withAlpha(20),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: _fadeAnim,
                        child: CircleAvatar(
                          radius: 54,
                          backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                          child: (photoUrl == null || photoUrl.isEmpty) ? const Icon(Icons.person, size: 54) : null,
                        ),
                      ),
                      const SizedBox(height: 18),
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Text(
                          userModel.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Text(
                          userModel.email,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Account type: ${userModel.accountType}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        color: isDark ? theme.colorScheme.surface : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await AuthController.to.signOut();
                                    Get.offAllNamed('/auth');
                                  },
                                  icon: const Icon(Icons.logout),
                                  label: const Text('Logout'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Get.to(() => EditProfilePage(userModel: userModel));
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Edit Profile'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: theme.colorScheme.primary,
                                    side: BorderSide(color: theme.colorScheme.primary, width: 2),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Map Page - Clean, Efficient, and Maintainable
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Core map components
  mapbox.MapboxMap? _mapboxMap;
  mapbox.PointAnnotationManager? _annotationManager;
  
  // Location services
  final loc.Location _location = loc.Location();
  loc.LocationData? _currentLocation;
  StreamSubscription<loc.LocationData>? _locationSubscription;
  
  // State management
  bool _isDisposed = false;
  bool _isLoadingLocation = false;
  Map<String, dynamic>? _selectedPilot;
  
  // Pilot data
  final List<mapbox.PointAnnotation> _pilotAnnotations = [];
  final List<Map<String, dynamic>> _pilotDataList = [];

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _initializeLocation();
  }



  @override
  void dispose() {
    _isDisposed = true;
    _locationSubscription?.cancel();
    super.dispose();
  }

  // Initialize Mapbox
  void _initializeMap() {
    mapbox.MapboxOptions.setAccessToken(
      'pk.eyJ1IjoidGhlZHJvbmFjaGFyeWEiLCJhIjoiY21kN3Jyczk2MG1sdDJuc2QxajBndWx5ZiJ9.xqtrf0d-wWFEPfLKin_M2g'
    );
  }

  // Test location plugin functionality
  Future<void> _testLocationPlugin() async {
    try {
      debugPrint('=== LOCATION PLUGIN TEST ===');
      
      // Check plugin accessibility
      final hasLocation = _location != null;
      debugPrint('Location object exists: $hasLocation');
      
      // Check service status
      bool serviceEnabled = false;
      try {
        serviceEnabled = await _location.serviceEnabled();
        debugPrint('Service enabled: $serviceEnabled');
      } catch (e) {
        debugPrint('Service check failed: $e');
      }
      
      // Check permission status
      loc.PermissionStatus permissionStatus = loc.PermissionStatus.denied;
      try {
        permissionStatus = await _location.hasPermission();
        debugPrint('Permission status: $permissionStatus');
      } catch (e) {
        debugPrint('Permission check failed: $e');
      }
      
      // Test basic location functionality
      bool canGetLocation = false;
      if (permissionStatus == loc.PermissionStatus.granted) {
        try {
          final testLocation = await _location.getLocation();
          canGetLocation = testLocation.latitude != null && testLocation.longitude != null;
          debugPrint('Location test: ${canGetLocation ? 'Success' : 'Failed'}');
        } catch (e) {
          debugPrint('Location test failed: $e');
        }
      }
      
      // Show results to user
      final message = '''
Plugin Test Results:
• Plugin accessible: $hasLocation
• Service enabled: $serviceEnabled
• Permission status: $permissionStatus
• Can get location: $canGetLocation
• Current location: ${_currentLocation != null ? 'Available' : 'Not available'}
      ''';
      
      _showLocationInfo(message);
      
    } catch (e) {
      debugPrint('Plugin test error: $e');
      _showLocationError('Plugin test failed: $e');
    }
  }

  // Check if location plugin is working
  Future<bool> _checkLocationPlugin() async {
    try {
      debugPrint('Checking location plugin status...');
      
      // Test basic functionality
      final serviceEnabled = await _location.serviceEnabled();
      debugPrint('Service enabled check: $serviceEnabled');
      
      final permissionStatus = await _location.hasPermission();
      debugPrint('Permission status check: $permissionStatus');
      
      debugPrint('Location plugin is working properly');
      return true;
    } catch (e) {
      debugPrint('Location plugin error: $e');
      return false;
    }
  }

  // Verify location plugin import
  void _verifyLocationPlugin() {
    try {
      debugPrint('=== LOCATION PLUGIN VERIFICATION ===');
      debugPrint('Location instance type: ${_location.runtimeType}');
      debugPrint('PermissionStatus enum: ${loc.PermissionStatus.values}');
      debugPrint('LocationData type: ${_currentLocation?.runtimeType ?? 'null'}');
      debugPrint('=== VERIFICATION COMPLETE ===');
    } catch (e) {
      debugPrint('Plugin verification error: $e');
    }
  }

  // Robust location initialization with step-by-step debugging
  Future<void> _initializeLocation() async {
    try {
      setState(() {
        _isLoadingLocation = true;
      });

      debugPrint('=== LOCATION INITIALIZATION START ===');

      // Step 1: Verify location object
      debugPrint('Step 1: Verifying location object...');
      if (_location == null) {
        _showLocationError('Location service not available. Please restart the app.');
        return;
      }
      debugPrint('✓ Location object verified');

      // Step 2: Check location service
      debugPrint('Step 2: Checking location service...');
      bool serviceEnabled = false;
      try {
        serviceEnabled = await _location.serviceEnabled();
        debugPrint('Location service status: $serviceEnabled');
      } catch (e) {
        debugPrint('Error checking service: $e');
        _showLocationError('Cannot check location service. Please restart the app.');
        return;
      }

      if (!serviceEnabled) {
        debugPrint('Requesting to enable location service...');
        try {
          serviceEnabled = await _location.requestService();
          debugPrint('Service enable result: $serviceEnabled');
        } catch (e) {
          debugPrint('Error enabling service: $e');
          _showLocationError('Cannot enable location service. Please enable it manually in settings.');
          return;
        }
      }

      if (!serviceEnabled) {
        _showLocationError('Location service is disabled. Please enable it in your device settings.');
        return;
      }
      debugPrint('✓ Location service enabled');

      // Step 3: Check permission status
      debugPrint('Step 3: Checking permission status...');
      loc.PermissionStatus permissionStatus;
      try {
        permissionStatus = await _location.hasPermission();
        debugPrint('Current permission: $permissionStatus');
      } catch (e) {
        debugPrint('Error checking permission: $e');
        _showLocationError('Cannot check permission status. Please restart the app.');
        return;
      }

      // Step 4: Request permission if needed
      if (permissionStatus == loc.PermissionStatus.denied) {
        debugPrint('Requesting location permission...');
        try {
          permissionStatus = await _location.requestPermission();
          debugPrint('Permission request result: $permissionStatus');
        } catch (e) {
          debugPrint('Error requesting permission: $e');
          _showLocationError('Permission request failed. Please try opening settings.');
          return;
        }
      }

      // Step 5: Handle permission result
      if (permissionStatus == loc.PermissionStatus.granted) {
        debugPrint('✓ Permission granted, getting location...');
        
        try {
          _currentLocation = await _location.getLocation();
          debugPrint('Location obtained: ${_currentLocation?.latitude}, ${_currentLocation?.longitude}');
          
          if (_currentLocation?.latitude != null && _currentLocation?.longitude != null) {
            _startLocationUpdates();
            _showLocationSuccess('Location access granted! Your position is now visible.');
            setState(() {});
            debugPrint('✓ Location initialization complete');
          } else {
            _showLocationError('Invalid location data received. Please try again.');
          }
        } catch (e) {
          debugPrint('Error getting location: $e');
          _showLocationError('Could not get your location. Please check your GPS and try again.');
        }
      } else if (permissionStatus == loc.PermissionStatus.deniedForever) {
        debugPrint('Permission denied forever');
        _showLocationError('Location access permanently denied. Please enable it in settings.');
        _showLocationSettingsDialog();
      } else {
        debugPrint('Permission not granted: $permissionStatus');
        _showLocationError('Location permission not granted. Please try again or open settings.');
      }

    } catch (e) {
      debugPrint('Location initialization error: $e');
      _showLocationError('Location setup failed: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
      debugPrint('=== LOCATION INITIALIZATION END ===');
    }
  }





  // Show location error message
  void _showLocationError(String message) {
    if (!mounted) return;
    
    Get.snackbar(
      'Location Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.location_off, color: Colors.white),
    );
  }

  // Show location success message
  void _showLocationSuccess(String message) {
    if (!mounted) return;
    
    Get.snackbar(
      'Location Access',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.location_on, color: Colors.white),
    );
  }

  // Show location info message
  void _showLocationInfo(String message) {
    if (!mounted) return;
    
    Get.snackbar(
      'Location Info',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 6),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }



  // Refresh permission status and UI
  Future<void> _refreshPermissionStatus() async {
    try {
      final status = await _location.hasPermission();
      debugPrint('Refreshed permission status: $status');
      
      if (mounted) {
        setState(() {});
        
        if (status == loc.PermissionStatus.granted) {
          _initializeLocation();
        }
      }
    } catch (e) {
      debugPrint('Error refreshing permission: $e');
    }
  }

  // Reset location state and try again
  Future<void> _resetLocationState() async {
    try {
      debugPrint('Resetting location state...');
      
      // Cancel any existing location subscription
      _locationSubscription?.cancel();
      _locationSubscription = null;
      
      // Clear current location
      _currentLocation = null;
      
      // Reset loading state
      setState(() {
        _isLoadingLocation = false;
      });
      
      // Wait a moment for cleanup
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Try to initialize location again
      debugPrint('Retrying location initialization after reset...');
      await _initializeLocation();
      
    } catch (e) {
      debugPrint('Error resetting location state: $e');
      _showLocationError('Error resetting location. Please try again.');
    }
  }





  // Start location updates
  void _startLocationUpdates() {
    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      if (!_isDisposed && mounted) {
        setState(() => _currentLocation = locationData);
        _updateMapPosition(locationData);
      }
    });
  }

  // Update map position
  void _updateMapPosition(loc.LocationData locationData) {
    if (_mapboxMap == null || locationData.latitude == null || locationData.longitude == null) return;
    
    try {
      _mapboxMap!.flyTo(
        mapbox.CameraOptions(
          center: mapbox.Point(
            coordinates: mapbox.Position(locationData.longitude!, locationData.latitude!)
          ),
          zoom: 14.0,
        ),
        null,
      );
    } catch (e) {
      debugPrint('Map position update error: $e');
    }
  }

  // Initialize map operations
  Future<void> _initializeMapOperations() async {
    if (_isDisposed || _mapboxMap == null) return;
    
    try {
      // Set initial camera to India
      await _mapboxMap!.setCamera(
        mapbox.CameraOptions(
          center: mapbox.Point(coordinates: mapbox.Position(78.9629, 22.5937)),
          zoom: 3.8,
        ),
      );
      
      // Configure location component
      await _mapboxMap!.location.updateSettings(
        mapbox.LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
          showAccuracyRing: true,
        ),
      );
      
      // Fly to current location if available
      if (_currentLocation != null) {
        _updateMapPosition(_currentLocation!);
      }
      
      // Load pilot data
      await _loadPilotData();
      
    } catch (e) {
      debugPrint('Map initialization error: $e');
    }
  }

  // Load pilot data from Firestore
  Future<void> _loadPilotData() async {
    if (_isDisposed || _mapboxMap == null) return;
    
    try {
      // Use the pilot service to get filtered pilots
      final pilotService = Get.find<PilotService>();
      final pilots = pilotService.filteredPilots;
      
      if (_isDisposed) return;
      
      // Convert pilot models to map data
      final pilotDataList = pilots.map((pilot) => {
        'uid': pilot.uid,
        'name': pilot.name,
        'email': pilot.email,
        'photoUrl': pilot.photoUrl,
        'lastLat': pilot.lastLat,
        'lastLng': pilot.lastLng,
        'rating': pilot.rating,
        'specializations': pilot.specializationTexts,
        'hourlyRate': pilot.hourlyRate,
        'isVerified': pilot.isVerified,
        'isOnline': pilot.isOnline,
        'isAvailable': pilot.isAvailable,
      }).toList();
      
      await _createPilotMarkersFromData(pilotDataList);
      
    } catch (e) {
      debugPrint('Error loading pilot data: $e');
    }
  }

  // Create pilot markers on the map
  Future<void> _createPilotMarkers(List<QueryDocumentSnapshot> pilots) async {
    if (_isDisposed || _mapboxMap == null) return;
    
    try {
      // Create annotation manager
      _annotationManager ??= await _mapboxMap!.annotations.createPointAnnotationManager();
      
      // Load marker image
      final markerImage = await _loadMarkerImage();
      
      // Clear existing annotations
      _clearAnnotations();
      
      // Create annotations for each pilot
      for (final pilot in pilots) {
        if (_isDisposed) return;
        await _createPilotAnnotation(pilot.data() as Map<String, dynamic>, markerImage);
      }
      
      // Add click listener
      _addAnnotationClickListener();
      
    } catch (e) {
      debugPrint('Error creating pilot markers: $e');
    }
  }

  // Create pilot markers from pilot data
  Future<void> _createPilotMarkersFromData(List<Map<String, dynamic>> pilotDataList) async {
    if (_isDisposed || _mapboxMap == null) return;
    
    try {
      // Create annotation manager
      _annotationManager ??= await _mapboxMap!.annotations.createPointAnnotationManager();
      
      // Load marker image
      final markerImage = await _loadMarkerImage();
      
      // Clear existing annotations
      _clearAnnotations();
      
      // Create annotations for each pilot
      for (final pilotData in pilotDataList) {
        if (_isDisposed) return;
        await _createPilotAnnotation(pilotData, markerImage);
      }
      
      // Add click listener
      _addAnnotationClickListener();
      
    } catch (e) {
      debugPrint('Error creating pilot markers: $e');
    }
  }

  // Load marker image asset
  Future<Uint8List> _loadMarkerImage() async {
    final bytes = await rootBundle.load('assets/pilot_marker.png');
    return bytes.buffer.asUint8List();
  }

  // Clear existing annotations
  void _clearAnnotations() {
    _pilotAnnotations.clear();
    _pilotDataList.clear();
  }

  // Create individual pilot annotation
  Future<void> _createPilotAnnotation(Map<String, dynamic> pilotData, Uint8List markerImage) async {
    final lat = pilotData['lastLat'] ?? pilotData['lat'] ?? 22.5937;
    final lng = pilotData['lastLng'] ?? pilotData['lng'] ?? 78.9629;
    
    if (lat == null || lng == null) return;
    
    try {
      final annotation = await _annotationManager!.create(
        mapbox.PointAnnotationOptions(
          geometry: mapbox.Point(coordinates: mapbox.Position(lng, lat)),
          image: markerImage,
          iconSize: 1.0,
          iconOffset: [0, -20],
        ),
      );
      
      _pilotAnnotations.add(annotation);
      _pilotDataList.add({...pilotData, 'uid': pilotData['uid'] ?? 'unknown'});
      
    } catch (e) {
      debugPrint('Error creating annotation: $e');
    }
  }

  // Add annotation click listener
  void _addAnnotationClickListener() {
    if (_annotationManager == null) return;
    
    try {
      _annotationManager!.addOnPointAnnotationClickListener(
        PilotAnnotationClickListener(
          annotations: _pilotAnnotations,
          pilotDataList: _pilotDataList,
          onPilotSelected: (pilot) {
            if (!_isDisposed && mounted && pilot != null) {
              setState(() => _selectedPilot = pilot);
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('Error adding click listener: $e');
    }
  }

  // Refresh pilot markers
  Future<void> _refreshPilotMarkers() async {
    await _loadPilotData();
  }

  // Test Firestore connection
  Future<void> _testFirestore() async {
    try {
      final result = await FirebaseFirestore.instance.collection('users').limit(1).get();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firestore connected! Found ${result.docs.length} users'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firestore error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show booking sheet
  void _showBookingSheet(Map<String, dynamic> pilot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => BookingForm(pilot: pilot),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildMapContent(),
    );
  }

  // Build map content
  Widget _buildMapContent() {
    if (_currentLocation == null) {
      return _buildLocationPermissionRequest();
    }
    
    return _buildMapInterface();
  }

  // Show location settings dialog
  void _showLocationSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Permission Required'),
          content: Text(
            'Location access is required to show your position on the map and find nearby pilots. '
            'Please enable location access in Settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Open app settings
                _openAppSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  // Open app settings
  void _openAppSettings() async {
    try {
      // Open the app's settings page
      await AppSettings.openAppSettings();
    } catch (e) {
      debugPrint('Could not open settings: $e');
    }
  }

  // Build location permission request
  Widget _buildLocationPermissionRequest() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Location Permission Required',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Location access is required to:\n• Show your position on the map\n• Find nearby drone pilots\n• Enable real-time location services',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.4),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoadingLocation ? null : _initializeLocation,
            child: _isLoadingLocation
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Requesting...'),
                    ],
                  )
                : Text('Grant Permission'),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: _testLocationPlugin,
                child: Text('Test Plugin'),
              ),
              OutlinedButton(
                onPressed: _verifyLocationPlugin,
                child: Text('Verify Import'),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: _refreshPermissionStatus,
                child: Text('Refresh'),
              ),
              TextButton(
                onPressed: _resetLocationState,
                child: Text('Reset'),
              ),
              TextButton(
                onPressed: _openAppSettings,
                child: Text('Open Settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build map interface
  Widget _buildMapInterface() {
    return Stack(
      children: [
        // Map widget
        mapbox.MapWidget(
          key: ValueKey('mapbox_map_${widget.hashCode}'),
          onMapCreated: _onMapCreated,
        ),
        
        // Pilot bottom sheet
        if (_selectedPilot != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildPilotBottomSheet(context, _selectedPilot!),
          ),
        
        // Action buttons
        _buildActionButtons(),
        

      ],
    );
  }

  // Build action buttons
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Refresh button
        Positioned(
          top: 100,
          right: 24,
          child: FloatingActionButton.small(
            heroTag: 'refresh_pilots',
            onPressed: _refreshPilotMarkers,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            child: Icon(Icons.refresh),
            tooltip: 'Refresh Pilots',
          ),
        ),
        
        // Test button
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            heroTag: 'test_firestore',
            onPressed: _testFirestore,
            child: Icon(Icons.cloud),
            tooltip: 'Test Firestore',
          ),
        ),
      ],
    );
  }

  // Map created callback
  void _onMapCreated(mapbox.MapboxMap controller) {
    if (_isDisposed) return;
    
    _mapboxMap = controller;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMapOperations();
    });
  }

  Widget _buildPilotBottomSheet(BuildContext context, Map<String, dynamic> pilot) {
    return Material(
      elevation: 12,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with pilot info
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: pilot['photoUrl'] != null && pilot['photoUrl'].toString().isNotEmpty
                      ? NetworkImage(pilot['photoUrl'].toString())
                      : null,
                  child: (pilot['photoUrl'] == null || pilot['photoUrl'].toString().isEmpty)
                      ? const Icon(Icons.person, size: 32)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pilot['name'] ?? 'Pilot',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pilot['email'] ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (pilot['specializations'] != null && (pilot['specializations'] as List).isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            (pilot['specializations'] as List).first.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      if (pilot['rating'] != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${pilot['rating'].toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _selectedPilot = null),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Location and rate info
            Row(
              children: [
                if (pilot['lastLat'] != null && pilot['lastLng'] != null) ...[
                  Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Live Location Available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                const Spacer(),
                if (pilot['hourlyRate'] != null) ...[
                  Icon(Icons.attach_money, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '₹${pilot['hourlyRate'].toStringAsFixed(0)}/hr',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showBookingSheet(pilot),
                    icon: const Icon(Icons.flight_takeoff, size: 18),
                    label: const Text('Book Pilot'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close bottom sheet
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) => PilotProfilePage(pilot: pilot),
                      );
                    },
                    icon: const Icon(Icons.person, size: 18),
                    label: const Text('View Profile'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<List<ProductModel>> _fetchProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    return snapshot.docs.map((doc) => ProductModel.fromMap(doc.id, doc.data())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SkyShop')),
      body: FutureBuilder<List<ProductModel>>(
        future: _fetchProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data!;
          if (products.isEmpty) {
            return const Center(child: Text('No products available'));
          }
          return FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () => Get.to(() => ProductDetailPage(product: product)),
                    child: Card(
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: product.imageUrl.isNotEmpty
                                ? Image.network(product.imageUrl, fit: BoxFit.cover)
                                : const Icon(Icons.image, size: 64),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('₹${product.price.toStringAsFixed(2)}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(product.imageUrl, height: 200)
                      : const Icon(Icons.image, size: 120),
                ),
                const SizedBox(height: 24),
                Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('₹${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 16),
                Text(product.description),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {}, // TODO: Add to cart/checkout logic
                  child: const Text('Add to Cart'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final UserModel userModel;
  const EditProfilePage({super.key, required this.userModel});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late String _accountType;
  bool _loading = false;
  String? _error;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userModel.name);
    _accountType = widget.userModel.accountType;
    _photoUrl = widget.userModel.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Image functionality removed for simplicity

  Future<void> _save() async {
    setState(() { _loading = true; _error = null; });
    try {
      final user = AuthController.to.firebaseUser.value;
      if (user == null) throw Exception('Not logged in');
      
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'accountType': _accountType,
      });
      Navigator.of(context).pop(true); // Indicate success
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 6,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: (_photoUrl != null && _photoUrl!.isNotEmpty)
                        ? NetworkImage(_photoUrl!) as ImageProvider
                        : null,
                    child: (_photoUrl == null || _photoUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 48)
                        : null,
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _accountType,
                    decoration: const InputDecoration(
                      labelText: 'Account Type',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'pilot', child: Text('Pilot')),
                      DropdownMenuItem(value: 'client', child: Text('Client')),
                    ],
                    onChanged: (value) {
                      setState(() { _accountType = value ?? 'pilot'; });
                    },
                  ),
                  const SizedBox(height: 28),
                  // Theme Toggle Section
                  const ThemeToggleCard(),
                  const SizedBox(height: 28),
                  if (_error != null) ...[
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BookingForm extends StatefulWidget {
  final Map<String, dynamic> pilot;
  const BookingForm({super.key, required this.pilot});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _notesController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _bookPilot() async {
    setState(() { _loading = true; _error = null; });
    try {
      final user = AuthController.to.firebaseUser.value;
      if (user == null) throw Exception('Not logged in');
      if (_selectedDate == null || _selectedTime == null) throw Exception('Please select date and time');
      final bookingDateTime = DateTime(
        _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
        _selectedTime!.hour, _selectedTime!.minute,
      );
      await FirebaseFirestore.instance.collection('bookings').add({
        'pilotId': widget.pilot['uid'],
        'pilotName': widget.pilot['name'],
        'pilotEmail': widget.pilot['email'],
        'userId': user.uid,
        'userEmail': user.email,
        'userName': user.displayName ?? '',
        'dateTime': bookingDateTime,
        'notes': _notesController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking requested!')),
      );
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Book ${widget.pilot['name'] ?? 'Pilot'}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_selectedDate == null
                      ? 'Select Date'
                      : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'),
                  onPressed: _pickDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: Text(_selectedTime == null
                      ? 'Select Time'
                      : _selectedTime!.format(context)),
                  onPressed: _pickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(),
            ),
            minLines: 1,
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _bookPilot,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirm Booking'),
            ),
          ),
        ],
      ),
    );
  }
}

class PilotProfilePage extends StatelessWidget {
  final Map<String, dynamic> pilot;
  const PilotProfilePage({super.key, required this.pilot});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.primaryColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: pilot['photoUrl'] != null && pilot['photoUrl'].toString().isNotEmpty
                      ? NetworkImage(pilot['photoUrl'].toString())
                      : null,
                  child: (pilot['photoUrl'] == null || pilot['photoUrl'].toString().isEmpty)
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  pilot['name'] ?? 'Pilot',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pilot['email'] ?? '',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Professional Pilot',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Pilot Details
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                // Location Info
                if (pilot['lastLat'] != null && pilot['lastLng'] != null)
                  Row(
                    children: [
                      Icon(Icons.location_on, color: theme.primaryColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Location',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Live location available',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                
                if (pilot['lastLat'] != null && pilot['lastLng'] != null)
                  const SizedBox(height: 16),
                
                // Experience Info
                Row(
                  children: [
                    Icon(Icons.flight_takeoff, color: theme.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Experience',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            pilot['experience'] ?? 'Professional pilot with extensive experience',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Rating Info
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rating',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                pilot['rating']?.toString() ?? '4.8',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '/ 5.0',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Show booking form
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) => BookingForm(pilot: pilot),
                    );
                  },
                  icon: const Icon(Icons.flight_takeoff, size: 18),
                  label: const Text('Book This Pilot'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  Map<String, String> _lastStatuses = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _listenForStatusChanges();
  }

  void _listenForStatusChanges() {
    final user = AuthController.to.firebaseUser.value;
    if (user == null) return;
    FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            for (final doc in snapshot.docs) {
              final bookingId = doc.id;
              final status = doc.data()['status'] ?? '';
              if (_lastStatuses.containsKey(bookingId) && _lastStatuses[bookingId] != status) {
                // Status changed
                final msg = 'Booking ${status == 'cancelled' ? 'cancelled' : status}';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg)),
                );
              }
              _lastStatuses[bookingId] = status;
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            debugPrint('Firestore bookings stream error: $error\n$stackTrace');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to listen for booking updates.')),
              );
            }
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthController.to.firebaseUser.value;
    if (user == null) {
      return const Center(child: Text('Please log in to view bookings.'));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: user.uid) // SAFE QUERY: only show bookings for this user
            .orderBy('dateTime', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          try {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              debugPrint('Bookings page error: ${snapshot.error}');
              return Center(child: Text('Failed to load bookings. Please try again later.'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No bookings found.'));
            }
            final bookings = snapshot.data!.docs
                .map((doc) => BookingModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
                .toList();
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      booking.pilotId == user.uid ? Icons.person : Icons.event_note,
                      color: booking.pilotId == user.uid ? Theme.of(context).colorScheme.primary : null,
                    ),
                    title: Text(booking.pilotId == user.uid
                        ? 'You (Pilot) - ${booking.userName}'
                        : 'Pilot: ${booking.pilotName}'),
                    subtitle: Text('${booking.dateTime} | Status: ${booking.status}'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) => BookingDetailsPage(booking: booking, currentUserId: user.uid),
                      );
                    },
                  ),
                );
              },
            );
          } catch (e, st) {
            debugPrint('Bookings page exception: $e\n$st');
            return Center(child: Text('An error occurred. Please try again.'));
          }
        },
      ),
    );
  }
}

class BookingDetailsPage extends StatelessWidget {
  final BookingModel booking;
  final String currentUserId;
  const BookingDetailsPage({super.key, required this.booking, required this.currentUserId});

  Future<void> _updateStatus(BuildContext context, String status) async {
    await FirebaseFirestore.instance.collection('bookings').doc(booking.id).update({'status': status});
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking ${status == 'cancelled' ? 'cancelled' : status}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPilot = booking.pilotId == currentUserId;
    final isUser = booking.userId == currentUserId;
    final isPending = booking.status == 'pending';
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking Details', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          Text('Pilot: ${booking.pilotName}'),
          Text('Pilot Email: ${booking.pilotEmail}'),
          const SizedBox(height: 8),
          Text('User: ${booking.userName}'),
          Text('User Email: ${booking.userEmail}'),
          const SizedBox(height: 8),
          Text('Date & Time: ${booking.dateTime}'),
          const SizedBox(height: 8),
          Text('Status: ${booking.status}'),
          const SizedBox(height: 8),
          if (booking.notes.isNotEmpty) ...[
            Text('Notes: ${booking.notes}'),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 24),
          if (isPilot && isPending) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(context, 'accepted'),
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(context, 'rejected'),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (isUser && isPending) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _updateStatus(context, 'cancelled'),
                child: const Text('Cancel Booking'),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedGradientLoader extends StatefulWidget {
  const AnimatedGradientLoader({super.key});

  @override
  State<AnimatedGradientLoader> createState() => _AnimatedGradientLoaderState();
}

class _AnimatedGradientLoaderState extends State<AnimatedGradientLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: SizedBox(
        width: 54,
        height: 54,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _GradientRingPainter(_controller.value),
            );
          },
        ),
      ),
    );
  }
}

class _GradientRingPainter extends CustomPainter {
  final double progress;
  _GradientRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sweep = 2 * 3.141592653589793 * 0.8;
    final start = 2 * 3.141592653589793 * progress;
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF1976D2),
          const Color(0xFF00B8D9),
          const Color(0xFF1976D2),
        ],
        stops: const [0.0, 0.7, 1.0],
        startAngle: 0.0,
        endAngle: 2 * 3.141592653589793,
        transform: GradientRotation(start),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2 - 3),
      start,
      sweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_GradientRingPainter oldDelegate) => oldDelegate.progress != progress;
}
