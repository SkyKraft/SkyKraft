#!/bin/bash

# Version Synchronization Script for SkyKraft
# This script ensures iOS and web app versions stay in sync

set -e

echo "🔄 Starting version synchronization..."

# Get current version from pubspec.yaml
CURRENT_VERSION=$(grep 'version:' pubspec.yaml | head -1 | sed 's/version: //' | tr -d ' ')
VERSION_NUMBER=$(echo $CURRENT_VERSION | cut -d'+' -f1)
BUILD_NUMBER=$(echo $CURRENT_VERSION | cut -d'+' -f2)

echo "📱 Current version: $VERSION_NUMBER"
echo "🔢 Build number: $BUILD_NUMBER"

# Update iOS project version
if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
    echo "📱 Updating iOS project version..."
    
    # Update MARKETING_VERSION (CFBundleShortVersionString)
    sed -i '' "s/MARKETING_VERSION = [^;]*;/MARKETING_VERSION = $VERSION_NUMBER;/g" ios/Runner.xcodeproj/project.pbxproj
    
    # Update CURRENT_PROJECT_VERSION (CFBundleVersion)
    sed -i '' "s/CURRENT_PROJECT_VERSION = [^;]*;/CURRENT_PROJECT_VERSION = $BUILD_NUMBER;/g" ios/Runner.xcodeproj/project.pbxproj
    
    echo "✅ iOS version updated to $VERSION_NUMBER ($BUILD_NUMBER)"
else
    echo "⚠️  iOS project file not found, skipping iOS version update"
fi

# Update web app version info
if [ -f "lib/constants/app_constants.dart" ]; then
    echo "🌐 Updating web app version constants..."
    
    # Create version constants if they don't exist
    if ! grep -q "APP_VERSION" lib/constants/app_constants.dart; then
        echo "" >> lib/constants/app_constants.dart
        echo "// App Version Information" >> lib/constants/app_constants.dart
        echo "class AppVersion {" >> lib/constants/app_constants.dart
        echo "  static const String version = '$VERSION_NUMBER';" >> lib/constants/app_constants.dart
        echo "  static const int buildNumber = $BUILD_NUMBER;" >> lib/constants/app_constants.dart
        echo "  static const String fullVersion = '$VERSION_NUMBER+$BUILD_NUMBER';" >> lib/constants/app_constants.dart
        echo "}" >> lib/constants/app_constants.dart
    else
        # Update existing version constants
        sed -i '' "s/static const String version = '[^']*'/static const String version = '$VERSION_NUMBER'/g" lib/constants/app_constants.dart
        sed -i '' "s/static const int buildNumber = [^;]*/static const int buildNumber = $BUILD_NUMBER/g" lib/constants/app_constants.dart
        sed -i '' "s/static const String fullVersion = '[^']*'/static const String fullVersion = '$VERSION_NUMBER+$BUILD_NUMBER'/g" lib/constants/app_constants.dart
    fi
    
    echo "✅ Web app version constants updated"
fi

# Create version.json for web app
echo "📄 Creating version.json for web app..."
cat > build/web/version.json << EOF
{
  "version": "$VERSION_NUMBER",
  "buildNumber": $BUILD_NUMBER,
  "fullVersion": "$VERSION_NUMBER+$BUILD_NUMBER",
  "buildDate": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "commitHash": "$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
}
EOF

echo "✅ Version synchronization completed!"
echo "📱 iOS: $VERSION_NUMBER ($BUILD_NUMBER)"
echo "🌐 Web: $VERSION_NUMBER ($BUILD_NUMBER)"
echo "📅 Build date: $(date)"
