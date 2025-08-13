# 🚁 SKYKRAFT Deployment Guide

This guide covers deploying SKYKRAFT to both web and iOS platforms.

## 📋 Prerequisites

### **General Requirements**
- Flutter SDK 3.7.2+
- Git repository access
- Firebase project setup
- Mapbox API key

### **Web Deployment**
- Node.js and npm
- Firebase CLI (optional)
- Web hosting service

### **iOS Deployment**
- macOS operating system
- Xcode 16.4+
- Apple Developer Account
- CocoaPods

## 🌐 Web Deployment

### **Option 1: Automated Deployment (Recommended)**

```bash
# Run the automated deployment script
./scripts/deploy_web.sh
```

This script will:
1. Clean previous builds
2. Install dependencies
3. Build the web app
4. Deploy to Firebase (if configured)
5. Generate deployment information

### **Option 2: Manual Deployment**

#### **Step 1: Build the Web App**
```bash
# Clean and get dependencies
flutter clean
flutter pub get

# Build for production
flutter build web --release
```

#### **Step 2: Deploy to Firebase Hosting**

1. **Install Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**
   ```bash
   firebase login
   ```

3. **Initialize Firebase Hosting**
   ```bash
   firebase init hosting
   ```
   
   - Select your Firebase project
   - Set public directory to `build/web`
   - Configure as single-page app: `Yes`
   - Don't overwrite `index.html`

4. **Deploy**
   ```bash
   firebase deploy --only hosting
   ```

#### **Step 3: Alternative Hosting Options**

**GitHub Pages**
```bash
# Build for GitHub Pages
flutter build web --release --base-href "/skykraft/"

# Push to GitHub and enable Pages in repository settings
```

**Netlify**
1. Drag and drop `build/web` folder to Netlify
2. Configure build settings if needed

**Vercel**
1. Connect your GitHub repository
2. Set build command: `flutter build web --release`
3. Set output directory: `build/web`

## 📱 iOS Deployment

### **Option 1: Automated Deployment**

```bash
# Run the automated deployment script
./scripts/deploy_ios.sh
```

This script will:
1. Check system requirements
2. Install dependencies
3. Build the iOS app
4. Open Xcode for deployment
5. Provide step-by-step guidance

### **Option 2: Manual Deployment**

#### **Step 1: Prepare iOS Build**
```bash
# Clean and get dependencies
flutter clean
flutter pub get

# Install iOS dependencies
cd ios
pod install
cd ..

# Build iOS app
flutter build ios --release
```

#### **Step 2: Open in Xcode**
```bash
open ios/Runner.xcworkspace
```

#### **Step 3: Configure App Settings**

1. **Select Target Device**
   - Choose "Any iOS Device (arm64)"

2. **Update Bundle Identifier**
   - Make it unique (e.g., `com.skykraft.app`)

3. **Update Version**
   - Set version number (e.g., 7.0.0)
   - Set build number (e.g., 1)

4. **Configure Signing**
   - Select your team
   - Choose provisioning profile
   - Ensure certificate is valid

#### **Step 4: Archive and Upload**

1. **Archive the App**
   - Product → Archive
   - Wait for archiving to complete

2. **Upload to App Store Connect**
   - Use Xcode Organizer
   - Select your archive
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Follow the upload process

## 🔧 Configuration Files

### **Firebase Configuration**

Ensure these files are properly configured:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `firebase.json`

### **Mapbox Configuration**

Update the access token in `lib/main.dart`:
```dart
mapbox.MapboxOptions.setAccessToken('YOUR_MAPBOX_TOKEN');
```

### **App Configuration**

Update `lib/constants/app_constants.dart` with your settings:
- Company information
- API endpoints
- Feature flags

## 📊 Deployment Checklist

### **Web Deployment**
- [ ] Flutter web build successful
- [ ] All assets included
- [ ] Firebase configuration correct
- [ ] Mapbox token valid
- [ ] App loads without errors
- [ ] All features functional
- [ ] Responsive design working
- [ ] Performance optimized

### **iOS Deployment**
- [ ] iOS build successful
- [ ] Bundle identifier unique
- [ ] Version numbers updated
- [ ] Signing configured
- [ ] Provisioning profile valid
- [ ] App icons set
- [ ] Launch screen configured
- [ ] Permissions declared
- [ ] Privacy descriptions added

## 🚨 Common Issues & Solutions

### **Web Deployment Issues**

**Build Fails**
```bash
# Check Flutter version
flutter --version

# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release
```

**Firebase Deployment Fails**
```bash
# Check Firebase CLI
firebase --version

# Re-login to Firebase
firebase logout
firebase login

# Check project configuration
firebase projects:list
```

**App Not Loading**
- Check browser console for errors
- Verify all assets are included
- Check Firebase configuration
- Verify Mapbox token

### **iOS Deployment Issues**

**Build Fails**
```bash
# Check Xcode version
xcodebuild -version

# Clean and rebuild
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release
```

**Signing Issues**
- Verify certificate is valid
- Check provisioning profile
- Ensure team selection is correct
- Check bundle identifier uniqueness

**Archive Fails**
- Select correct target device
- Check signing configuration
- Verify all required files are present
- Check for build warnings

## 📈 Post-Deployment

### **Testing Checklist**
- [ ] App loads correctly
- [ ] All features functional
- [ ] Performance acceptable
- [ ] No console errors
- [ ] Responsive design working
- [ ] Cross-browser compatibility (web)
- [ ] Device compatibility (iOS)

### **Monitoring**
- Set up Firebase Analytics
- Monitor app performance
- Track user engagement
- Monitor error reports

### **Updates**
- Plan regular updates
- Test updates thoroughly
- Use staged rollouts
- Monitor update success rates

## 🔄 Continuous Deployment

### **Automated Pipeline Setup**

1. **GitHub Actions** (Web)
   ```yaml
   name: Deploy Web
   on:
     push:
       branches: [main]
   jobs:
     deploy:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v2
         - uses: subosito/flutter-action@v2
         - run: flutter build web --release
         - run: firebase deploy --only hosting
   ```

2. **Fastlane** (iOS)
   ```bash
   # Install Fastlane
   sudo gem install fastlane

   # Initialize
   cd ios
   fastlane init

   # Configure Fastfile for automated deployment
   ```

## 📞 Support & Resources

### **Documentation**
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Firebase Hosting](https://firebase.google.com/docs/hosting)
- [Apple Developer](https://developer.apple.com/)

### **Community**
- Flutter Discord
- Stack Overflow
- GitHub Issues
- Flutter Community

### **Contact**
- **Email**: support@skykraft.com
- **Documentation**: [Wiki](https://github.com/your-username/skykraft/wiki)
- **Issues**: [GitHub Issues](https://github.com/your-username/skykraft/issues)

---

**🚁 SKYKRAFT - Taking drone services to new heights!**

*Last updated: $(date)*
