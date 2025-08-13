# SkyKraft - The Ultimate Drone Pilot Aggregator Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.7.2-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.7.2-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🚁 About SkyKraft

SkyKraft is a comprehensive Flutter-based mobile application that serves as the ultimate drone pilot aggregator platform. It connects drone pilots with customers, providing a seamless booking experience, real-time location tracking, and comprehensive pilot discovery features.

## ✨ Features

- **🔐 Authentication System**: Secure login and signup with Firebase
- **🗺️ Interactive Maps**: Mapbox integration for real-time pilot location tracking
- **👨‍✈️ Pilot Discovery**: Find and connect with drone pilots in your area
- **📱 Modern UI/UX**: Beautiful, responsive design with dark/light theme support
- **🌍 Location Services**: GPS integration for accurate pilot positioning
- **🛒 Shop Integration**: Built-in marketplace for drone-related products
- **📊 Real-time Updates**: Live data synchronization with Firebase
- **🎨 Theme Customization**: Dynamic theme switching capabilities

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.7.2
- **Backend**: Firebase (Authentication, Firestore)
- **Maps**: Mapbox Maps Flutter
- **State Management**: GetX
- **Location**: Flutter Location Plugin
- **UI Components**: Material Design 3, Google Fonts

## 📱 Screenshots

*Screenshots will be added here*

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.7.2 or higher
- Dart SDK 3.7.2 or higher
- Android Studio / VS Code
- iOS Simulator (for iOS development)
- Android Emulator (for Android development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/SkyKraft.git
   cd SkyKraft
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a new Firebase project
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Update `firebase_options.dart` with your configuration

4. **Configure Mapbox**
   - Get your Mapbox access token
   - Update the token in your configuration files

5. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── auth/                 # Authentication screens and controllers
├── constants/            # App constants and configurations
├── core/                 # Core app theme and controllers
├── features/             # Feature-specific modules
│   ├── auth/            # Authentication features
│   ├── booking/         # Booking system
│   ├── map/             # Map functionality
│   ├── pilot_discovery/ # Pilot discovery features
│   ├── pilot_profile/   # Pilot profile management
│   ├── profile/         # User profile management
│   └── shop/            # Shop/marketplace features
├── shared/               # Shared models, services, and widgets
├── services/             # Core services
└── main.dart            # App entry point
```

## 🔧 Configuration

### Firebase Setup
1. Create a Firebase project
2. Enable Authentication and Firestore
3. Download configuration files
4. Update `firebase_options.dart`

### Mapbox Setup
1. Create a Mapbox account
2. Generate an access token
3. Configure the token in your app

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- ✅ Web
- ✅ macOS
- ✅ Linux
- ✅ Windows

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Mapbox for mapping solutions
- All contributors and supporters

## 📞 Support

If you have any questions or need support, please:

- Open an issue on GitHub
- Contact the development team
- Check our documentation

---

**Made with ❤️ by the SkyKraft Team**

*Fly high, connect pilots, build the future of drone services.*
