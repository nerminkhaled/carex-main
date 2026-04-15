import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../repository/auth_repository.dart';
import 'auth_widgets.dart';

class ResetPasswordPage extends StatelessWidget {
  // StatelessWidget since it only provides the Bloc and doesn't manage any state itself
  const ResetPasswordPage({super.key});

  @override // Override the build method to create the UI for the reset password page from the parent StatelessWidget class
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(
        repository: SupabaseAuthRepository(),
      ), // Provide the AuthBloc to the widget tree, creating an instance with the SupabaseAuthRepository
      child:
          const _ResetPasswordView(), // The actual UI for the reset password page is built in the _ResetPasswordView widget, which is a StatefulWidget that manages the form and interactions
    );
  }
}

class _ResetPasswordView extends StatefulWidget {
  const _ResetPasswordView();

  @override
  State<_ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<_ResetPasswordView> {
  // State class for managing the state of the reset password form and interactions
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  static const _teal = Color(0xFF1ABFB0);
  static const _tealDark = Color(0xFF0EA89B);

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Password updated! Please sign in.'),
              backgroundColor: _teal,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          context.go(
            '/login',
          ); // Navigate to the login page after a successful password update
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        // for the main structure of the page, providing app bar, body, etc.
        resizeToAvoidBottomInset:
            false, // Prevents the layout from resizing when the keyboard appears, allowing for a more consistent design
        backgroundColor: const Color(0xFF1ABFB0),
        body: SafeArea(
          // Ensures that the content is displayed within the safe area of the device, avoiding notches and system UI elements
          child: Column(
            children: [
              _buildHeroSection(context),
              Expanded(child: _buildFormCard(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height *
          0.42, // responsive height for the hero section, taking 42% of the screen height
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0C9D91), Color(0xFF1ABFB0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        // Using a Stack to layer the background image and text elements for a visually appealing hero section
        clipBehavior: Clip
            .none, // Allowing overflow for the background image to create a dynamic design
        children: [
          Positioned(
            right: -8,
            top: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/login and signup/3D Asset Clay Extra 3 2.png',
              height: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: 20,
            top: 24,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                'assets/images/login and signup/Vector.png',
                height: 32,
                color: Colors.white,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),
          Positioned(
            left: 28,
            bottom: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment
                  .start, // Aligning text to the start of the column for a clean layout
              mainAxisSize: MainAxisSize
                  .min, // Minimizing the vertical space taken by the column to fit the text content
              children: [
                const Text(
                  'Set new password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Must be at least 8 characters',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      width: double
          .infinity, //responsive width to fill the available horizontal space
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create new password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your new password must be different from previously used passwords.',
              style: TextStyle(fontSize: 13, color: Colors.black45),
            ),
            const SizedBox(height: 24),
            AuthInputField(
              //reusable custom widget for input fields in the authentication flow, providing consistent styling and behavior across the app
              controller: _passwordController,
              hintText: 'New password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.black38,
                  size: 20,
                ),
                onPressed: () => setState(
                  () => _obscurePassword = !_obscurePassword,
                ), // Toggle the obscureText state to show/hide the password when the suffix icon is pressed
              ),
            ),
            const SizedBox(height: 14),
            AuthInputField(
              controller: _confirmController,
              hintText: 'Confirm password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.black38,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            const SizedBox(height: 28),
            _buildUpdateButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      // BlocBuilder to rebuild the update button based on the current state of the AuthBloc, allowing for dynamic UI changes such as showing a loading indicator when the password update is in progress
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return GestureDetector(
          // GestureDetector to handle tap events on the update button, allowing for custom behavior when the button is pressed
          onTap:
              isLoading // if the state is loading, disable the button by setting onTap to null, otherwise execute the password update logic when the button is pressed
              ? null
              : () {
                  // else
                  final password = _passwordController.text;
                  final confirm = _confirmController.text;
                  if (password.length < 8) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Password must be at least 8 characters.',
                        ),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    return;
                  }
                  if (password != confirm) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Passwords do not match.'),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    return;
                  }
                  context.read<AuthBloc>().add(
                    // Dispatch the ResetPasswordSubmitted event to the AuthBloc with the new password, triggering the password update process in the bloc
                    ResetPasswordSubmitted(newPassword: password),
                  );
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 54,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: isLoading
                  ? null
                  : const LinearGradient(
                      colors: [_tealDark, _teal],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              color: isLoading ? Colors.black12 : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: _teal.withValues(alpha: 0.38),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: _teal,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Update Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
