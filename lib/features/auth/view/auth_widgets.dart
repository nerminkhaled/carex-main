import 'package:flutter/material.dart';

/// Rounded white input field used across login and signup screens.
class AuthInputField extends StatelessWidget {
  const AuthInputField({
    //constructor optimization
    super.key,
    required this.controller, // Text Editing Controller
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType, // Optional keyboard type (e.g., email, password)
    this.obscureText = false, // Whether to obscure text (for password fields)
    this.suffixIcon, // Optional suffix icon (e.g., visibility toggle)
    this.textInputAction, // Optional text input action (e.g., next, done)
  });

  final TextEditingController
  controller; // final unchanged after initialization
  final String hintText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget?
  suffixIcon; // Optional widget for suffix icon (e.g., visibility toggle)
  final TextInputAction?
  textInputAction; // Optional text input action (e.g., next, done)

  @override // Override the build method to create the UI for the input field from the parent StatelessWidget class
  Widget build(BuildContext context) {
    return Container(
      // Build method to create the input field UI
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        // TextField widget for user input
        controller:
            controller, // Connect the TextField to the provided controller
        keyboardType: keyboardType,
        obscureText: obscureText,
        textInputAction: textInputAction,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          // Decoration for the TextField
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          prefixIcon: Icon(prefixIcon, color: Colors.black38, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

/// Rounded white button for social sign-in providers.
class AuthSocialButton extends StatelessWidget {
  //constructor optimization
  const AuthSocialButton({
    // StatelessWidget for a reusable social sign-in button
    super.key,
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap; // Callback function to handle button tap events
  final Widget
  child; // The child widget (e.g., an icon or text) to display inside the button

  @override
  Widget build(BuildContext context) {
    // Build method to create the UI for the social sign-in button
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
