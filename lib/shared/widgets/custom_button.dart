import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
  success,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? elevation;
  final Duration? animationDuration;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.elevation,
    this.animationDuration,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? AppConstants.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: _getWidth(),
          height: _getHeight(),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: _getBorderRadius(),
            border: _getBorder(),
            boxShadow: _getBoxShadow(),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: _getBorderRadius(),
              child: Container(
                padding: _getPadding(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading) ...[
                      SizedBox(
                        width: _getIconSize(),
                        height: _getIconSize(),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
                        ),
                      ),
                      SizedBox(width: AppSizes.spacingS),
                    ] else if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: _getIconSize(),
                        color: _getTextColor(),
                      ),
                      SizedBox(width: AppSizes.spacingS),
                    ],
                    Flexible(
                      child: Text(
                        widget.text,
                        style: _getTextStyle(),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getWidth() {
    if (widget.width != null) return widget.width!;
    if (widget.isFullWidth) return double.infinity;
    
    switch (widget.size) {
      case ButtonSize.small:
        return 80;
      case ButtonSize.medium:
        return 120;
      case ButtonSize.large:
        return 160;
    }
  }

  double _getHeight() {
    if (widget.height != null) return widget.height!;
    
    switch (widget.size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return AppSizes.buttonHeight;
      case ButtonSize.large:
        return 56;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  EdgeInsets _getPadding() {
    if (widget.padding != null) return widget.padding!;
    
    switch (widget.size) {
      case ButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: AppSizes.spacingM,
          vertical: AppSizes.spacingS,
        );
      case ButtonSize.medium:
        return EdgeInsets.symmetric(
          horizontal: AppSizes.spacingL,
          vertical: AppSizes.spacingM,
        );
      case ButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: AppSizes.spacingXL,
          vertical: AppSizes.spacingL,
        );
    }
  }

  BorderRadius _getBorderRadius() {
    if (widget.borderRadius != null) return widget.borderRadius!;
    
    switch (widget.size) {
      case ButtonSize.small:
        return BorderRadius.circular(AppSizes.buttonRadius / 2);
      case ButtonSize.medium:
        return BorderRadius.circular(AppSizes.buttonRadius);
      case ButtonSize.large:
        return BorderRadius.circular(AppSizes.buttonRadius * 1.5);
    }
  }

  Color _getBackgroundColor() {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    if (widget.onPressed == null) return AppColors.textLight;
    
    switch (widget.type) {
      case ButtonType.primary:
        return AppColors.primary;
      case ButtonType.secondary:
        return AppColors.secondary;
      case ButtonType.outline:
      case ButtonType.text:
        return Colors.transparent;
      case ButtonType.danger:
        return AppColors.error;
      case ButtonType.success:
        return AppColors.success;
    }
  }

  Color _getTextColor() {
    if (widget.textColor != null) return widget.textColor!;
    if (widget.onPressed == null) return AppColors.textSecondary;
    
    switch (widget.type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.danger:
      case ButtonType.success:
        return Colors.white;
      case ButtonType.outline:
        return AppColors.primary;
      case ButtonType.text:
        return AppColors.primary;
    }
  }

  Border? _getBorder() {
    if (widget.type != ButtonType.outline) return null;
    
    return Border.all(
      color: widget.borderColor ?? AppColors.primary,
      width: 1.5,
    );
  }

  List<BoxShadow>? _getBoxShadow() {
    if (widget.type == ButtonType.text) return null;
    
    final elevation = widget.elevation ?? AppSizes.buttonRadius;
    return [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: elevation,
        offset: Offset(0, elevation / 2),
      ),
    ];
  }

  TextStyle _getTextStyle() {
    final baseStyle = widget.textStyle ?? TextStyle(
      color: _getTextColor(),
      fontWeight: FontWeight.w600,
      fontSize: _getFontSize(),
    );
    
    return baseStyle.copyWith(
      color: _getTextColor(),
    );
  }

  double _getFontSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppConstants.smallFontSize;
      case ButtonSize.medium:
        return AppConstants.bodyFontSize;
      case ButtonSize.large:
        return AppConstants.subtitleFontSize;
    }
  }
} 