import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../constants/app_constants.dart';

enum ErrorType {
  network,
  authentication,
  permission,
  validation,
  server,
  flutter,
  platform,
  unknown,
}

class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();

  // Error handling methods
  void handleError(dynamic error, {ErrorType? type, String? context}) {
    final errorType = type ?? _determineErrorType(error);
    final message = _getUserFriendlyMessage(error, errorType);
    
    // Log error
    _logError(error, errorType, context);
    
    // Show user-friendly message
    _showErrorMessage(message, errorType);
  }

  // Handle Flutter-specific errors
  void handleFlutterError(FlutterErrorDetails details) {
    final error = details.exception;
    final stackTrace = details.stack;
    
    // Log the error with stack trace
    _logError(error, ErrorType.flutter, 'Flutter Framework', stackTrace: stackTrace);
    
    // Show user-friendly message
    final message = _getUserFriendlyMessage(error, ErrorType.flutter);
    _showErrorMessage(message, ErrorType.flutter);
  }

  // Handle platform channel errors
  void handlePlatformError(PlatformException exception) {
    final errorType = _determinePlatformErrorType(exception);
    final message = _getPlatformErrorMessage(exception);
    
    _logError(exception, errorType, 'Platform Channel');
    _showErrorMessage(message, errorType);
  }

  // Handle Firebase errors with better categorization
  void handleFirebaseError(dynamic error, {String? context}) {
    ErrorType errorType;
    
    if (error.toString().contains('permission-denied')) {
      errorType = ErrorType.permission;
    } else if (error.toString().contains('network') || 
               error.toString().contains('unavailable')) {
      errorType = ErrorType.network;
    } else if (error.toString().contains('auth') || 
               error.toString().contains('user-not-found') ||
               error.toString().contains('wrong-password')) {
      errorType = ErrorType.authentication;
    } else if (error.toString().contains('not-found') ||
               error.toString().contains('already-exists')) {
      errorType = ErrorType.validation;
    } else {
      errorType = ErrorType.server;
    }
    
    handleError(error, type: errorType, context: context);
  }

  void handleValidationError(String field, String message) {
    final errorMessage = '$field: $message';
    handleError(errorMessage, type: ErrorType.validation);
  }

  // Show success message
  void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(AppSizes.spacingM),
      borderRadius: AppSizes.buttonRadius,
    );
  }

  // Show warning message
  void showWarning(String message) {
    Get.snackbar(
      'Warning',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.warning,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(AppSizes.spacingM),
      borderRadius: AppSizes.buttonRadius,
    );
  }

  // Show info message
  void showInfo(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(AppSizes.spacingM),
      borderRadius: AppSizes.buttonRadius,
    );
  }

  // Show confirmation dialog
  Future<bool> showConfirmation({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  // Show loading dialog
  void showLoading({String message = 'Loading...'}) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(AppSizes.spacingL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSizes.spacingM),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: AppConstants.bodyFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Hide loading dialog
  void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  // Private methods
  ErrorType _determineErrorType(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || 
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('unavailable')) {
      return ErrorType.network;
    }
    
    if (errorString.contains('permission') || 
        errorString.contains('denied') ||
        errorString.contains('unauthorized')) {
      return ErrorType.permission;
    }
    
    if (errorString.contains('auth') || 
        errorString.contains('login') ||
        errorString.contains('password')) {
      return ErrorType.authentication;
    }
    
    if (errorString.contains('validation') || 
        errorString.contains('invalid') ||
        errorString.contains('required')) {
      return ErrorType.validation;
    }
    
    if (errorString.contains('server') || 
        errorString.contains('500') ||
        errorString.contains('404')) {
      return ErrorType.server;
    }
    
    if (errorString.contains('flutter') ||
        errorString.contains('widget') ||
        errorString.contains('build')) {
      return ErrorType.flutter;
    }
    
    if (errorString.contains('platform') ||
        errorString.contains('native') ||
        errorString.contains('channel')) {
      return ErrorType.platform;
    }
    
    return ErrorType.unknown;
  }

  ErrorType _determinePlatformErrorType(PlatformException exception) {
    switch (exception.code) {
      case 'PERMISSION_DENIED':
        return ErrorType.permission;
      case 'UNAVAILABLE':
        return ErrorType.network;
      case 'INVALID_ARGUMENT':
        return ErrorType.validation;
      default:
        return ErrorType.platform;
    }
  }

  String _getUserFriendlyMessage(dynamic error, ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return AppConstants.networkErrorMessage;
      case ErrorType.authentication:
        return AppConstants.authErrorMessage;
      case ErrorType.permission:
        return AppConstants.permissionErrorMessage;
      case ErrorType.validation:
        return error.toString();
      case ErrorType.server:
        return 'Server error. Please try again later.';
      case ErrorType.flutter:
        return 'A display error occurred. Please restart the app.';
      case ErrorType.platform:
        return 'A system error occurred. Please try again.';
      case ErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  String _getPlatformErrorMessage(PlatformException exception) {
    switch (exception.code) {
      case 'PERMISSION_DENIED':
        return 'Permission denied. Please check your settings.';
      case 'UNAVAILABLE':
        return 'Service unavailable. Please try again later.';
      case 'INVALID_ARGUMENT':
        return 'Invalid input provided.';
      default:
        return exception.message ?? 'Platform error occurred.';
    }
  }

  void _logError(dynamic error, ErrorType type, String? context, {StackTrace? stackTrace}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '''
[ERROR] $timestamp
Type: $type
Context: ${context ?? 'Unknown'}
Error: $error
Stack Trace: ${stackTrace ?? StackTrace.current}
''';
    
    print(logMessage);
    
    // In a production app, you would send this to a logging service
    // like Firebase Crashlytics, Sentry, or your own logging server
  }

  void _showErrorMessage(String message, ErrorType type) {
    Color backgroundColor;
    IconData icon;
    
    switch (type) {
      case ErrorType.network:
        backgroundColor = AppColors.warning;
        icon = Icons.wifi_off;
        break;
      case ErrorType.authentication:
        backgroundColor = AppColors.error;
        icon = Icons.lock;
        break;
      case ErrorType.permission:
        backgroundColor = AppColors.warning;
        icon = Icons.block;
        break;
      case ErrorType.validation:
        backgroundColor = AppColors.warning;
        icon = Icons.warning;
        break;
      case ErrorType.server:
        backgroundColor = AppColors.error;
        icon = Icons.error;
        break;
      case ErrorType.flutter:
        backgroundColor = AppColors.error;
        icon = Icons.bug_report;
        break;
      case ErrorType.platform:
        backgroundColor = AppColors.error;
        icon = Icons.smartphone;
        break;
      case ErrorType.unknown:
        backgroundColor = AppColors.error;
        icon = Icons.error_outline;
        break;
    }
    
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(AppSizes.spacingM),
      borderRadius: AppSizes.buttonRadius,
      shouldIconPulse: true,
    );
  }

  // Utility methods
  bool isNetworkError(dynamic error) {
    return _determineErrorType(error) == ErrorType.network;
  }

  bool isAuthError(dynamic error) {
    return _determineErrorType(error) == ErrorType.authentication;
  }

  bool isPermissionError(dynamic error) {
    return _determineErrorType(error) == ErrorType.permission;
  }

  bool isFlutterError(dynamic error) {
    return _determineErrorType(error) == ErrorType.flutter;
  }

  // Retry mechanism
  Future<T?> retry<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
    String? context,
  }) async {
    int attempts = 0;
    
    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        
        if (attempts >= maxAttempts) {
          handleError(e, context: context);
          return null;
        }
        
        // Wait before retrying
        await Future.delayed(delay * attempts);
      }
    }
    
    return null;
  }

  // Safe execution wrapper
  Future<T?> safeExecute<T>({
    required Future<T> Function() operation,
    String? context,
    T? defaultValue,
  }) async {
    try {
      return await operation();
    } catch (e) {
      handleError(e, context: context);
      return defaultValue;
    }
  }

  // Safe execution with custom error handling
  Future<T?> safeExecuteWithHandler<T>({
    required Future<T> Function() operation,
    required void Function(dynamic error) onError,
    T? defaultValue,
  }) async {
    try {
      return await operation();
    } catch (e) {
      onError(e);
      return defaultValue;
    }
  }
} 