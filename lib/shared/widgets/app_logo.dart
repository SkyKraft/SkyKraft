import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

enum LogoType {
  primary,
  white,
  dark,
  small,
  large,
}

class AppLogo extends StatelessWidget {
  final LogoType type;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  const AppLogo({
    Key? key,
    this.type = LogoType.primary,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return _buildLogo(context, isDark);
  }

  Widget _buildLogo(BuildContext context, bool isDark) {
    final logoSize = _getLogoSize();
    final logoColor = _getLogoColor(context, isDark);
    
    // Try to load the appropriate logo file
    String? logoPath = _getLogoPath(isDark);
    
    if (logoPath != null) {
      // If logo file exists, use it
      return Image.asset(
        logoPath,
        width: width ?? logoSize,
        height: height ?? logoSize,
        color: logoColor,
        fit: fit,
      );
    } else {
      // Fallback to text logo
      return _buildTextLogo(context, logoColor, logoSize);
    }
  }

  Widget _buildTextLogo(BuildContext context, Color? color, double size) {
    final textColor = color ?? Theme.of(context).primaryColor;
    final fontSize = size * 0.4; // Adjust font size relative to logo size
    
    return Container(
      width: width ?? size,
      height: height ?? size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [textColor, textColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.1),
      ),
      child: Center(
        child: Text(
          'SKYKRAFT',
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  String? _getLogoPath(bool isDark) {
    switch (type) {
      case LogoType.primary:
        return isDark ? 'assets/skykraft_logo_white.png' : 'assets/skykraft_logo_dark.png';
      case LogoType.white:
        return 'assets/skykraft_logo_white.png';
      case LogoType.dark:
        return 'assets/skykraft_logo_dark.png';
      case LogoType.small:
        return isDark ? 'assets/skykraft_logo_white.png' : 'assets/skykraft_logo_dark.png';
      case LogoType.large:
        return isDark ? 'assets/skykraft_logo_white.png' : 'assets/skykraft_logo_dark.png';
    }
  }

  double _getLogoSize() {
    switch (type) {
      case LogoType.primary:
        return AppConstants.logoSize;
      case LogoType.white:
      case LogoType.dark:
        return AppConstants.logoSize;
      case LogoType.small:
        return AppConstants.logoSize * 0.6;
      case LogoType.large:
        return AppConstants.logoSize * 1.5;
    }
  }

  Color? _getLogoColor(BuildContext context, bool isDark) {
    if (color != null) return color;
    
    switch (type) {
      case LogoType.primary:
        return null; // Use original logo colors
      case LogoType.white:
        return Colors.white;
      case LogoType.dark:
        return Colors.black;
      case LogoType.small:
        return null; // Use original logo colors
      case LogoType.large:
        return null; // Use original logo colors
    }
  }
}

// Specialized logo widgets for common use cases
class SkykraftLogo extends StatelessWidget {
  final double? size;
  final bool isDark;

  const SkykraftLogo({
    Key? key,
    this.size,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = isDark || Theme.of(context).brightness == Brightness.dark;
    return AppLogo(
      type: isDarkMode ? LogoType.white : LogoType.dark,
      width: size,
      height: size,
    );
  }
}

class SkykraftSmallLogo extends StatelessWidget {
  final double? size;
  final bool isDark;

  const SkykraftSmallLogo({
    Key? key,
    this.size,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = isDark || Theme.of(context).brightness == Brightness.dark;
    return AppLogo(
      type: LogoType.small,
      width: size,
      height: size,
    );
  }
} 