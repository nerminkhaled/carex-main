import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../repository/auth_repository.dart';
import 'auth_widgets.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(repository: SupabaseAuthRepository()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  static const _teal = Color(0xFF1ABFB0);
  static const _tealDark = Color(0xFF0EA89B);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go('/home');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
        clipBehavior: Clip.none,
        children: [
          // 3D clay asset — right, prominent
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
          // Title
          Positioned(
            left: 28,
            bottom: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Welcome back',
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
                  'Sign in to continue your health journey',
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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
             
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          AuthInputField(
            controller: _emailController,
            hintText: 'Email address',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          AuthInputField(
            controller: _passwordController,
            hintText: 'Password',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.black38,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 10),
          _buildRememberForgotRow(),
          const SizedBox(height: 20),
          _buildLoginButton(context),
          const SizedBox(height: 18),
          _buildDivider(),
          const SizedBox(height: 14),
          _buildSocialRow(),
          const SizedBox(height: 18),
          _buildSignupLink(context),
        ],
      ),
    ),
  );
}
  Widget _buildRememberForgotRow() {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: _rememberMe,
            onChanged: (v) => setState(() => _rememberMe = v ?? false),
            activeColor: _teal,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: Colors.black26),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Remember me',
          style: TextStyle(color: Colors.black54, fontSize: 12.5),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => context.go('/forgot-password'),
          child: const Text(
            'Forgot password?',
            style: TextStyle(
              color: _teal,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Colors.black12)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'Or continue with',
            style: TextStyle(color: Colors.black45, fontSize: 12.5),
          ),
        ),
        Expanded(child: Divider(color: Colors.black12)),
      ],
    );
  }

  Widget _buildSocialRow() {
    return Row(
      children: [
        Expanded(
          child: _SocialTile(
            label: 'Google',
            letter: 'G',
            letterColor: const Color(0xFFDB4437),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SocialTile(
            label: 'Facebook',
            letter: 'f',
            letterColor: const Color(0xFF1877F2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SocialTile(
            label: 'Apple',
            icon: Icons.apple,
            letterColor: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return GestureDetector(
          onTap: isLoading
              ? null
              : () {
                  context.read<AuthBloc>().add(
                        LoginSubmitted(
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
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
                          color: _teal, strokeWidth: 2.5),
                    )
                  : const Text(
                      'Login',
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

  Widget _buildSignupLink(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.go('/signup'),
        child: RichText(
          text: const TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(color: Colors.black45, fontSize: 13.5),
            children: [
              TextSpan(
                text: 'Sign up',
                style: TextStyle(
                  color: _teal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Labeled social sign-in tile with icon/letter + provider name.
class _SocialTile extends StatelessWidget {
  const _SocialTile({
    required this.label,
    required this.letterColor,
    this.letter,
    this.icon,
  }) : assert(letter != null || icon != null);

  final String label;
  final String? letter;
  final IconData? icon;
  final Color letterColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(icon, color: letterColor, size: 20)
            else
              Text(
                letter!,
                style: TextStyle(
                  color: letterColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
  }
}
