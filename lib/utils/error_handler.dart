import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Simple error handler for displaying errors to users
class ErrorHandler {
  /// Show an error message to the user via SnackBar
  static void showError(BuildContext? context, String message, {Object? error}) {
    if (context == null) {
      // If no context, just log it
      debugPrint('Error: $message');
      if (error != null) {
        debugPrint('Error details: $error');
      }
      return;
    }

    // Show user-friendly error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );

    // Also log for debugging
    debugPrint('Error: $message');
    if (error != null) {
      debugPrint('Error details: $error');
    }
  }

  /// Show a success message to the user
  static void showSuccess(BuildContext? context, String message) {
    if (context == null) {
      debugPrint('Success: $message');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Get a user-friendly error message from an exception
  static String getUserFriendlyMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('database') || errorString.contains('sql')) {
      return 'Database error. Please try again.';
    }
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Connection error. Please check your internet connection.';
    }
    if (errorString.contains('permission') || errorString.contains('denied')) {
      return 'Permission denied. Please check app permissions.';
    }
    if (errorString.contains('not found')) {
      return 'Item not found.';
    }
    if (errorString.contains('already exists') || errorString.contains('duplicate')) {
      return 'This item already exists.';
    }

    // Default message
    return 'An error occurred. Please try again.';
  }
}

