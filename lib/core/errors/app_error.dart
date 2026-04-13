import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Converts any caught exception into a short, human-readable message.
String toUserMessage(Object error) {
  if (error is AuthException) return _authMessage(error.message);
  if (error is PostgrestException) return _postgrestMessage(error);
  if (error is SocketException) {
    return 'No internet connection. Please check your network and try again.';
  }

  final msg = error.toString().replaceFirst('Exception: ', '');

  if (msg.contains('SocketException') ||
      msg.contains('Failed host lookup') ||
      msg.contains('network')) {
    return 'No internet connection. Please check your network and try again.';
  }
  if (msg.contains('Session expired')) {
    return 'Your session has expired. Please sign in again.';
  }

  // Return the stripped message — already human-readable for our own exceptions.
  return msg.isNotEmpty ? msg : 'Something went wrong. Please try again.';
}

String _authMessage(String raw) {
  final lower = raw.toLowerCase();
  if (lower.contains('invalid login credentials') ||
      lower.contains('invalid credentials')) {
    return 'Incorrect email or password. Please try again.';
  }
  if (lower.contains('already registered') ||
      lower.contains('user already exists')) {
    return 'An account with this email already exists. Try signing in.';
  }
  if (lower.contains('email not confirmed')) {
    return 'Please confirm your email address before signing in.';
  }
  if (lower.contains('password should be at least') ||
      lower.contains('password is too short')) {
    return 'Password must be at least 6 characters.';
  }
  if (lower.contains('rate limit') || lower.contains('too many requests')) {
    return 'Too many attempts. Please wait a moment and try again.';
  }
  if (lower.contains('user not found')) {
    return 'No account found with that email.';
  }
  return raw;
}

String _postgrestMessage(PostgrestException e) {
  return switch (e.code) {
    '23505' => 'This record already exists.',
    '23503' => 'A related record could not be found.',
    '42501' => 'You don\'t have permission to perform this action.',
    '54001' => 'The request timed out. Please try again.',
    _ => 'Something went wrong. Please try again.',
  };
}
