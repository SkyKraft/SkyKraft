#!/bin/bash

# SKYKRAFT Web Deployment Script
# This script automates the web deployment process

set -e  # Exit on any error

echo "🚁 SKYKRAFT Web Deployment Starting..."
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

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean

# Get dependencies
print_status "Getting dependencies..."
flutter pub get

# Check for any issues
print_status "Checking for issues..."
flutter analyze

# Build web app
print_status "Building web app for production..."
flutter build web --release

# Check if build was successful
if [ ! -d "build/web" ]; then
    print_error "Web build failed. build/web directory not found."
    exit 1
fi

print_success "Web build completed successfully!"

# Check if Firebase CLI is installed
if command -v firebase &> /dev/null; then
    print_status "Firebase CLI found. Proceeding with Firebase deployment..."
    
    # Check if user is logged in to Firebase
    if firebase projects:list &> /dev/null; then
        print_status "User is logged in to Firebase"
        
        # Check if firebase.json exists
        if [ -f "firebase.json" ]; then
            print_status "firebase.json found. Deploying to Firebase..."
            firebase deploy --only hosting
            
            if [ $? -eq 0 ]; then
                print_success "Firebase deployment completed successfully!"
                print_status "Your app should be available at the Firebase hosting URL"
            else
                print_error "Firebase deployment failed"
                exit 1
            fi
        else
            print_warning "firebase.json not found. Initializing Firebase hosting..."
            firebase init hosting
            
            if [ $? -eq 0 ]; then
                print_status "Firebase hosting initialized. Deploying..."
                firebase deploy --only hosting
                
                if [ $? -eq 0 ]; then
                    print_success "Firebase deployment completed successfully!"
                else
                    print_error "Firebase deployment failed"
                    exit 1
                fi
            else
                print_error "Firebase hosting initialization failed"
                exit 1
            fi
        fi
    else
        print_warning "User not logged in to Firebase. Please run 'firebase login' first."
        print_status "You can still deploy manually by copying build/web to your web server."
    fi
else
    print_warning "Firebase CLI not found. You can install it with: npm install -g firebase-tools"
    print_status "Web build is ready in build/web directory"
    print_status "You can deploy manually to any web server or hosting platform"
fi

# Create deployment info file
DEPLOYMENT_INFO="deployment_info_web_$(date +%Y%m%d_%H%M%S).txt"
cat > "$DEPLOYMENT_INFO" << EOF
SKYKRAFT Web Deployment Information
==================================
Deployment Date: $(date)
Flutter Version: $FLUTTER_VERSION
Build Directory: build/web
Build Type: Release

Files to Deploy:
- build/web/index.html
- build/web/main.dart.js
- build/web/assets/
- build/web/icons/
- build/web/manifest.json

Deployment Options:
1. Firebase Hosting (recommended)
2. GitHub Pages
3. Netlify
4. Vercel
5. Custom web server

Instructions:
1. Copy all contents of build/web to your web server
2. Ensure index.html is accessible at the root
3. Configure your server to serve Flutter web apps correctly
4. Test all functionality after deployment

For Firebase deployment:
1. Install Firebase CLI: npm install -g firebase-tools
2. Login: firebase login
3. Initialize: firebase init hosting
4. Deploy: firebase deploy --only hosting
EOF

print_success "Deployment information saved to $DEPLOYMENT_INFO"
print_success "Web deployment process completed!"
print_status "Your web app is ready in the build/web directory"
