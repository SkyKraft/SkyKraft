import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_constants.dart';

enum InputType {
  text,
  email,
  password,
  number,
  phone,
  multiline,
  date,
  time,
}

class CustomInputField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final InputType type;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;
  final EdgeInsets? contentPadding;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final Color? fillColor;
  final double? borderWidth;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final TextStyle? errorStyle;

  const CustomInputField({
    Key? key,
    required this.label,
    this.hint,
    this.initialValue,
    this.type = InputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLines,
    this.maxLength,
    this.textInputAction,
    this.keyboardType,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.contentPadding,
    this.borderRadius,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.fillColor,
    this.borderWidth,
    this.labelStyle,
    this.hintStyle,
    this.textStyle,
    this.errorStyle,
  }) : super(key: key);

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isObscure = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _isObscure = widget.obscureText;
    
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: AppSizes.spacingS),
            child: Text(
              widget.label,
              style: _getLabelStyle(),
            ),
          ),
        
        // Input Field
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          obscureText: _isObscure,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: _getMaxLines(),
          maxLength: widget.maxLength,
          textInputAction: _getTextInputAction(),
          keyboardType: _getKeyboardType(),
          inputFormatters: _getInputFormatters(),
          autofocus: widget.autofocus,
          validator: _validate,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          style: _getTextStyle(),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: _getHintStyle(),
            prefixIcon: _getPrefixIcon(),
            suffixIcon: _getSuffixIcon(),
            contentPadding: _getContentPadding(),
            filled: true,
            fillColor: _getFillColor(),
            border: _getBorder(),
            enabledBorder: _getBorder(),
            focusedBorder: _getFocusedBorder(),
            errorBorder: _getErrorBorder(),
            focusedErrorBorder: _getErrorBorder(),
            errorStyle: _getErrorStyle(),
            counterText: '', // Hide character counter
          ),
        ),
        
        // Error Text
        if (_errorText != null)
          Padding(
            padding: EdgeInsets.only(top: AppSizes.spacingS),
            child: Text(
              _errorText!,
              style: _getErrorStyle(),
            ),
          ),
      ],
    );
  }

  int? _getMaxLines() {
    if (widget.maxLines != null) return widget.maxLines;
    
    switch (widget.type) {
      case InputType.multiline:
        return 4;
      default:
        return 1;
    }
  }

  TextInputAction? _getTextInputAction() {
    if (widget.textInputAction != null) return widget.textInputAction;
    
    switch (widget.type) {
      case InputType.multiline:
        return TextInputAction.newline;
      default:
        return TextInputAction.next;
    }
  }

  TextInputType? _getKeyboardType() {
    if (widget.keyboardType != null) return widget.keyboardType;
    
    switch (widget.type) {
      case InputType.email:
        return TextInputType.emailAddress;
      case InputType.password:
        return TextInputType.visiblePassword;
      case InputType.number:
        return TextInputType.number;
      case InputType.phone:
        return TextInputType.phone;
      case InputType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    if (widget.inputFormatters != null) return widget.inputFormatters;
    
    switch (widget.type) {
      case InputType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      case InputType.phone:
        return [FilteringTextInputFormatter.digitsOnly];
      default:
        return null;
    }
  }

  Widget? _getPrefixIcon() {
    if (widget.prefixIcon == null) return null;
    
    return Icon(
      widget.prefixIcon,
      color: _getIconColor(),
      size: 20,
    );
  }

  Widget? _getSuffixIcon() {
    if (widget.suffixIcon == null && widget.type != InputType.password) {
      return null;
    }
    
    if (widget.type == InputType.password) {
      return IconButton(
        icon: Icon(
          _isObscure ? Icons.visibility : Icons.visibility_off,
          color: _getIconColor(),
        ),
        onPressed: () {
          setState(() {
            _isObscure = !_isObscure;
          });
        },
      );
    }
    
    return IconButton(
      icon: Icon(
        widget.suffixIcon,
        color: _getIconColor(),
      ),
      onPressed: widget.onSuffixIconTap,
    );
  }

  EdgeInsets _getContentPadding() {
    return widget.contentPadding ?? EdgeInsets.symmetric(
      horizontal: AppSizes.spacingM,
      vertical: AppSizes.spacingM,
    );
  }

  Color _getFillColor() {
    if (!widget.enabled) return AppColors.textLight.withValues(alpha: 0.1);
    return widget.fillColor ?? AppColors.surface;
  }

  Color _getIconColor() {
    if (!widget.enabled) return AppColors.textLight;
    if (_errorText != null) return AppColors.error;
    if (_isFocused) return AppColors.primary;
    return AppColors.textSecondary;
  }

  OutlineInputBorder _getBorder() {
    return OutlineInputBorder(
      borderRadius: _getBorderRadius(),
      borderSide: BorderSide(
        color: _getBorderColor(),
        width: _getBorderWidth(),
      ),
    );
  }

  OutlineInputBorder _getFocusedBorder() {
    return OutlineInputBorder(
      borderRadius: _getBorderRadius(),
      borderSide: BorderSide(
        color: _getFocusedBorderColor(),
        width: _getBorderWidth() + 1,
      ),
    );
  }

  OutlineInputBorder _getErrorBorder() {
    return OutlineInputBorder(
      borderRadius: _getBorderRadius(),
      borderSide: BorderSide(
        color: _getErrorBorderColor(),
        width: _getBorderWidth(),
      ),
    );
  }

  BorderRadius _getBorderRadius() {
    return widget.borderRadius ?? BorderRadius.circular(AppSizes.inputRadius);
  }

  Color _getBorderColor() {
    if (!widget.enabled) return AppColors.textLight;
    return widget.borderColor ?? AppColors.textLight;
  }

  Color _getFocusedBorderColor() {
    return widget.focusedBorderColor ?? AppColors.primary;
  }

  Color _getErrorBorderColor() {
    return widget.errorBorderColor ?? AppColors.error;
  }

  double _getBorderWidth() {
    return widget.borderWidth ?? 1.0;
  }

  TextStyle _getLabelStyle() {
    return widget.labelStyle ?? TextStyle(
      color: AppColors.textPrimary,
      fontSize: AppConstants.bodyFontSize,
      fontWeight: FontWeight.w500,
    );
  }

  TextStyle _getHintStyle() {
    return widget.hintStyle ?? TextStyle(
      color: AppColors.textSecondary,
      fontSize: AppConstants.bodyFontSize,
    );
  }

  TextStyle _getTextStyle() {
    return widget.textStyle ?? TextStyle(
      color: AppColors.textPrimary,
      fontSize: AppConstants.bodyFontSize,
    );
  }

  TextStyle _getErrorStyle() {
    return widget.errorStyle ?? TextStyle(
      color: AppColors.error,
      fontSize: AppConstants.smallFontSize,
    );
  }

  String? _validate(String? value) {
    if (widget.validator != null) {
      final error = widget.validator!(value);
      setState(() {
        _errorText = error;
      });
      return error;
    }
    
    // Default validation
    if (value == null || value.isEmpty) {
      final error = '${widget.label} is required';
      setState(() {
        _errorText = error;
      });
      return error;
    }
    
    // Type-specific validation
    switch (widget.type) {
      case InputType.email:
        if (!_isValidEmail(value)) {
          final error = 'Please enter a valid email address';
          setState(() {
            _errorText = error;
          });
          return error;
        }
        break;
      case InputType.phone:
        if (!_isValidPhone(value)) {
          final error = 'Please enter a valid phone number';
          setState(() {
            _errorText = error;
          });
          return error;
        }
        break;
      default:
        break;
    }
    
    setState(() {
      _errorText = null;
    });
    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(phone);
  }
} 