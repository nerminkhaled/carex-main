import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../repository/auth_repository.dart';
import 'auth_widgets.dart';

class ForgotPasswordPage extends StatelessWidget {
  // StatelessWidget since it doesn't manage any state directly, all state is handled by the Bloc
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(
        repository: SupabaseAuthRepository(),
      ), // Provide the AuthBloc to the widget tree, using the SupabaseAuthRepository for authentication operations
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  // StatefulWidget to manage the state of the email input and handle user interactions
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _emailController = TextEditingController();

  static const _teal = Color(0xFF1ABFB0);
  static const _tealDark = Color(0xFF0EA89B);

  @override
  void dispose() {
    //prevent memory leaks by disposing of the controller when the widget is removed from the widget tree
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      // Listen to changes in the AuthBloc state to show feedback to the user based on authentication events (e.g., success or failure of password reset)
      listener: (context, state) {
        if (state is AuthPasswordResetSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Reset link sent! Check your inbox.'),
              backgroundColor: _teal,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          context.go('/login');
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
        resizeToAvoidBottomInset:
            false, // Prevents the layout from resizing when the keyboard appears, maintaining the design integrity of the page
        backgroundColor: const Color(0xFF1ABFB0),
        body: SafeArea(
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
      height: MediaQuery.of(context).size.height * 0.42,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0C9D91), Color(0xFF1ABFB0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip
            .none, // Allow overflow for decorative elements like the 3D asset and sparkle
        children: [
          // 3D clay asset — right, prominent
          Positioned(
            right: -8,
            top: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/login and signup/3D Asset Clay Extra 3 2.png',
              height: double
                  .infinity, // Make the asset fill the vertical space of the hero section
              fit: BoxFit.contain,
            ),
          ),
          // Sparkle
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
          // Back button
          Positioned(
            left: 16,
            top: 60,
            child: GestureDetector(
              onTap: () => context.go('/login'),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          // Title
          Positioned(
            left: 28,
            bottom: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Forgot password?',
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
                  "No worries, we'll send you a reset link",
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
      width: double.infinity,
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
              'Enter your email',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "We'll email you a link to reset your password.",
              style: TextStyle(fontSize: 13, color: Colors.black45),
            ),
            const SizedBox(height: 24),
            AuthInputField(
              controller: _emailController,
              hintText: 'Email address',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 28),
            _buildSendButton(context),
            const SizedBox(height: 24),
            _buildBackToLoginLink(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return GestureDetector(
          onTap: isLoading
              ? null
              : () {
                  context.read<AuthBloc>().add(
                    // When the button is tapped, if it's not currently loading, dispatch an AuthForgotPasswordSubmitted event to the AuthBloc with the email from the input field
                    ForgotPasswordSubmitted(
                      email: _emailController.text.trim(),
                    ),
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
                      'Send Reset Link',
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

  Widget _buildBackToLoginLink(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.go('/login'),
        child: RichText(
          text: const TextSpan(
            text: 'Remember your password? ',
            style: TextStyle(color: Colors.black45, fontSize: 13.5),
            children: [
              TextSpan(
                text: 'Sign in',
                style: TextStyle(color: _teal, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
