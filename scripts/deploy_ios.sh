#!/bin/bash

# SKYKRAFT iOS Deployment Script
# This script automates the iOS deployment process

set -e  # Exit on any error

echo "🚁 SKYKRAFT iOS Deployment Starting..."
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | grep -o 'Flutter [0-9.]*' | cut -d' ' -f2)
print_status "Flutter version: $FLUTTER_VERSION"

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. Please run this script from the project root."
    exit 1
fi

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "iOS deployment requires macOS"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    print_error "Xcode is not installed. Please install Xcode from the App Store."
    exit 1
fi

# Check Xcode version
XCODE_VERSION=$(xcodebuild -version | grep -o 'Xcode [0-9.]*' | cut -d' ' -f2)
print_status "Xcode version: $XCODE_VERSION"

# Check if CocoaPods is installed
if ! command -v pod &> /dev/null; then
    print_error "CocoaPods is not installed. Installing..."
    sudo gem install cocoapods
fi

# Check CocoaPods version
POD_VERSION=$(pod --version)
print_status "CocoaPods version: $POD_VERSION"

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean

# Get dependencies
print_status "Getting dependencies..."
flutter pub get

# Check for any issues
print_status "Checking for issues..."
flutter analyze

# Navigate to iOS directory and install pods
print_status "Installing iOS dependencies..."
cd ios
pod install
cd ..

# Check if Runner.xcworkspace exists
if [ ! -d "ios/Runner.xcworkspace" ]; then
    print_error "Runner.xcworkspace not found. iOS setup may be incomplete."
    exit 1
fi

# Build iOS app
print_status "Building iOS app for release..."
flutter build ios --release

# Check if build was successful
if [ ! -d "build/ios/iphoneos" ]; then
    print_error "iOS build failed. build/ios/iphoneos directory not found."
    exit 1
fi

print_success "iOS build completed successfully!"

# Check if we should proceed with App Store deployment
read -p "Do you want to proceed with App Store deployment? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Opening Xcode for App Store deployment..."
    
    # Open Xcode workspace
    open ios/Runner.xcworkspace
    
    print_status "Xcode opened. Please follow these steps:"
    echo
    echo "1. Select 'Any iOS Device (arm64)' as the target device"
    echo "2. Update Bundle Identifier if needed (e.g., com.skykraft.app)"
    echo "3. Update version and build numbers in project settings"
    echo "4. Ensure signing and capabilities are configured"
    echo "5. Go to Product → Archive"
    echo "6. Use Xcode Organizer to upload to App Store Connect"
    echo
    echo "Press Enter when you're ready to continue..."
    read
    
    # Check if we can automate some of the process
    print_status "Checking for automated deployment options..."
    
    # Check if fastlane is available
    if command -v fastlane &> /dev/null; then
        print_status "Fastlane found. You can automate deployment with:"
        echo "  fastlane release"
    else
        print_warning "Fastlane not found. You can install it with:"
        echo "  sudo gem install fastlane"
    fi
    
    # Check if xcrun is available for command line deployment
    if command -v xcrun &> /dev/null; then
        print_status "Command line deployment tools available"
        print_status "You can use xcrun for automated deployment"
    fi
else
    print_status "Skipping App Store deployment. Build is ready for manual deployment."
fi

# Create deployment info file
DEPLOYMENT_INFO="deployment_info_ios_$(date +%Y%m%d_%H%M%S).txt"
cat > "$DEPLOYMENT_INFO" << EOF
SKYKRAFT iOS Deployment Information
==================================
Deployment Date: $(date)
Flutter Version: $FLUTTER_VERSION
Xcode Version: $XCODE_VERSION
CocoaPods Version: $POD_VERSION
Build Directory: build/ios
Build Type: Release

Files Built:
- build/ios/iphoneos/Runner.app
- build/ios/iphoneos/Runner.ipa (if created)

Deployment Steps:
1. Open ios/Runner.xcworkspace in Xcode
2. Select 'Any iOS Device (arm64)' as target
3. Update Bundle Identifier and version
4. Configure signing and capabilities
5. Archive the app (Product → Archive)
6. Upload to App Store Connect via Organizer

Pre-deployment Checklist:
□ Bundle identifier is unique
□ Version and build numbers are updated
□ Signing certificate is valid
□ Provisioning profile is correct
□ App icons are properly set
□ Launch screen is configured
□ Required permissions are declared
□ Privacy descriptions are added

Common Issues:
- Signing identity not found
- Provisioning profile mismatch
- Bundle identifier conflicts
- Missing app icons
- Invalid launch screen

For automated deployment:
1. Install Fastlane: sudo gem install fastlane
2. Initialize: fastlane init
3. Configure Fastfile
4. Run: fastlane release

Support:
- Apple Developer Documentation
- Flutter iOS Deployment Guide
- Xcode Help
EOF

print_success "Deployment information saved to $DEPLOYMENT_INFO"
print_success "iOS deployment process completed!"
print_status "Your iOS app is ready for App Store submission"
print_status "Open Xcode and follow the deployment steps above"
