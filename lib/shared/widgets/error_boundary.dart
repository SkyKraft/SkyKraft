import 'package:flutter/material.dart';
import '../services/error_service.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final VoidCallback? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // Set up error handling for this widget tree
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleError(details.exception, details.stack);
    };
  }

  void _handleError(Object error, StackTrace? stackTrace) {
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });

    // Log the error
    ErrorService().handleError(
      error,
      context: 'Widget Tree Error',
    );

    // Call custom error handler if provided
    widget.onError?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      // Show error UI
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _stackTrace);
      }

      // Default error UI
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'An error occurred while rendering this screen',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _stackTrace = null;
                    });
                  },
                  child: const Text('Try Again'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Error Details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _error.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}

// Convenience widget for wrapping specific sections
class ErrorCatcher extends StatelessWidget {
  final Widget child;
  final String? context;

  const ErrorCatcher({
    super.key,
    required this.child,
    this.context,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      onError: () {
        ErrorService().showWarning(
          'An error occurred in ${this.context ?? 'this section'}. Please try again.',
        );
      },
      child: child,
    );
  }
}
