import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class DoctorSignupPage extends StatefulWidget {
  const DoctorSignupPage({super.key});

  @override
  State<DoctorSignupPage> createState() => _DoctorSignupPageState();
}

class _DoctorSignupPageState extends State<DoctorSignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _licenseController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFCAF9FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Connect with and monitor your patients',
                      style: TextStyle(color: Colors.black45, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    _LabeledField(
                      label: 'Full Name',
                      child: _TextField(
                        controller: _nameController,
                        hint: 'Full name',
                        action: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: 'Email Address',
                      child: _TextField(
                        controller: _emailController,
                        hint: 'Email address',
                        keyboard: TextInputType.emailAddress,
                        action: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: 'Password',
                      child: _TextField(
                        controller: _passwordController,
                        hint: 'Password',
                        obscure: _obscurePassword,
                        action: TextInputAction.next,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.black38,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: 'Phone Number',
                      child: _TextField(
                        controller: _phoneController,
                        hint: 'Phone number',
                        keyboard: TextInputType.phone,
                        action: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: 'Specialty',
                      child: _TextField(
                        controller: _specialtyController,
                        hint: 'e.g. Cardiology, General Practice',
                        action: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: 'License Number',
                      child: _TextField(
                        controller: _licenseController,
                        hint: 'Medical license number',
                        action: TextInputAction.done,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your license will be verified before account activation',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFE8556D),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSubmitButton(context),
                    const SizedBox(height: 16),
                    _buildLoginLink(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.go('/signup'),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 17, color: Colors.black54),
            ),
          ),
          Image.asset(
            'assets/images/login and signup/Vector.png',
            height: 36,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Doctor registration is coming soon. Stay tuned!'),
              backgroundColor: Color(0xFF1ABFB0),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1ABFB0),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: const Text(
          'Create Account',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.go('/login'),
        child: RichText(
          text: const TextSpan(
            text: 'Already have an account? ',
            style: TextStyle(color: Colors.black45, fontSize: 13),
            children: [
              TextSpan(
                text: 'Login here',
                style: TextStyle(
                  color: Color(0xFF1ABFB0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Local widgets ───────────────────────────────────────────────────────────

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    this.keyboard,
    this.action,
    this.obscure = false,
    this.suffix,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboard;
  final TextInputAction? action;
  final bool obscure;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        textInputAction: action,
        obscureText: obscure,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
