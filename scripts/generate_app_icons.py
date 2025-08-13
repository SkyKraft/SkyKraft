#!/usr/bin/env python3
"""
App Icon Generator for Skykraft
Generates app icons for different platforms with light and dark theme support
"""

import os
import sys
from PIL import Image, ImageDraw, ImageFilter
import argparse

def create_icon_with_background(logo_path, size, background_color, output_path):
    """Create an app icon with the specified background color"""
    try:
        # Open the logo
        logo = Image.open(logo_path).convert('RGBA')
        
        # Create a new image with the background color
        icon = Image.new('RGBA', (size, size), background_color)
        
        # Calculate logo size (80% of icon size)
        logo_size = int(size * 0.8)
        
        # Resize logo maintaining aspect ratio
        logo.thumbnail((logo_size, logo_size), Image.Resampling.LANCZOS)
        
        # Calculate position to center the logo
        x = (size - logo.width) // 2
        y = (size - logo.height) // 2
        
        # Paste the logo onto the background
        icon.paste(logo, (x, y), logo)
        
        # Save the icon
        icon.save(output_path, 'PNG')
        print(f"Generated: {output_path}")
        
    except Exception as e:
        print(f"Error generating {output_path}: {e}")

def generate_android_icons(dark_logo_path, white_logo_path, output_dir):
    """Generate Android app icons"""
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192
    }
    
    # Light theme icons (white background with dark logo)
    for folder, size in android_sizes.items():
        folder_path = os.path.join(output_dir, 'android', 'app', 'src', 'main', 'res', folder)
        os.makedirs(folder_path, exist_ok=True)
        
        output_path = os.path.join(folder_path, 'ic_launcher.png')
        create_icon_with_background(dark_logo_path, size, '#FFFFFF', output_path)
    
    # Dark theme icons (black background with white logo)
    for folder, size in android_sizes.items():
        folder_path = os.path.join(output_dir, 'android', 'app', 'src', 'main', 'res', folder)
        os.makedirs(folder_path, exist_ok=True)
        
        output_path = os.path.join(folder_path, 'ic_launcher_round.png')
        create_icon_with_background(white_logo_path, size, '#000000', output_path)

def generate_ios_icons(dark_logo_path, white_logo_path, output_dir):
    """Generate iOS app icons"""
    ios_sizes = {
        'Icon-App-20x20@1x.png': 20,
        'Icon-App-20x20@2x.png': 40,
        'Icon-App-20x20@3x.png': 60,
        'Icon-App-29x29@1x.png': 29,
        'Icon-App-29x29@2x.png': 58,
        'Icon-App-29x29@3x.png': 87,
        'Icon-App-40x40@1x.png': 40,
        'Icon-App-40x40@2x.png': 80,
        'Icon-App-40x40@3x.png': 120,
        'Icon-App-60x60@2x.png': 120,
        'Icon-App-60x60@3x.png': 180,
        'Icon-App-76x76@1x.png': 76,
        'Icon-App-76x76@2x.png': 152,
        'Icon-App-83.5x83.5@2x.png': 167,
        'Icon-App-1024x1024@1x.png': 1024
    }
    
    # Light theme icons (white background with dark logo)
    for filename, size in ios_sizes.items():
        folder_path = os.path.join(output_dir, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
        os.makedirs(folder_path, exist_ok=True)
        
        output_path = os.path.join(folder_path, filename)
        create_icon_with_background(dark_logo_path, size, '#FFFFFF', output_path)
    
    # Dark theme icons (black background with white logo)
    for filename, size in ios_sizes.items():
        folder_path = os.path.join(output_dir, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
        os.makedirs(folder_path, exist_ok=True)
        
        # Create dark theme version with _dark suffix
        base_name = os.path.splitext(filename)[0]
        dark_filename = f"{base_name}_dark.png"
        output_path = os.path.join(folder_path, dark_filename)
        create_icon_with_background(white_logo_path, size, '#000000', output_path)

def generate_macos_icons(dark_logo_path, white_logo_path, output_dir):
    """Generate macOS app icons"""
    macos_sizes = {
        'app_icon_16.png': 16,
        'app_icon_32.png': 32,
        'app_icon_64.png': 64,
        'app_icon_128.png': 128,
        'app_icon_256.png': 256,
        'app_icon_512.png': 512,
        'app_icon_1024.png': 1024
    }
    
    # Light theme icons (white background with dark logo)
    for filename, size in macos_sizes.items():
        folder_path = os.path.join(output_dir, 'macos', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
        os.makedirs(folder_path, exist_ok=True)
        
        output_path = os.path.join(folder_path, filename)
        create_icon_with_background(dark_logo_path, size, '#FFFFFF', output_path)
    
    # Dark theme icons (black background with white logo)
    for filename, size in macos_sizes.items():
        folder_path = os.path.join(output_dir, 'macos', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
        os.makedirs(folder_path, exist_ok=True)
        
        # Create dark theme version with _dark suffix
        base_name = os.path.splitext(filename)[0]
        dark_filename = f"{base_name}_dark.png"
        output_path = os.path.join(folder_path, dark_filename)
        create_icon_with_background(white_logo_path, size, '#000000', output_path)

def main():
    parser = argparse.ArgumentParser(description='Generate app icons for Skykraft')
    parser.add_argument('--dark-logo', default='assets/skykraft_logo_dark.png', help='Path to the dark logo file')
    parser.add_argument('--white-logo', default='assets/skykraft white logo.PNG', help='Path to the white logo file')
    parser.add_argument('--output', default='.', help='Output directory')
    
    args = parser.parse_args()
    
    if not os.path.exists(args.dark_logo):
        print(f"Error: Dark logo file not found: {args.dark_logo}")
        sys.exit(1)
    
    if not os.path.exists(args.white_logo):
        print(f"Error: White logo file not found: {args.white_logo}")
        sys.exit(1)
    
    print("Generating app icons for Skykraft...")
    print(f"Dark logo: {args.dark_logo}")
    print(f"White logo: {args.white_logo}")
    print(f"Output: {args.output}")
    
    # Generate icons for all platforms
    generate_android_icons(args.dark_logo, args.white_logo, args.output)
    generate_ios_icons(args.dark_logo, args.white_logo, args.output)
    generate_macos_icons(args.dark_logo, args.white_logo, args.output)
    
    print("\nApp icon generation completed!")
    print("\nNext steps:")
    print("1. For Android: The icons will automatically adapt to light/dark themes")
    print("2. For iOS: You'll need to configure the asset catalog for dark mode support")
    print("3. For macOS: You'll need to configure the asset catalog for dark mode support")

if __name__ == '__main__':
    main()
