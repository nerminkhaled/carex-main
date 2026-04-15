import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionPage extends StatelessWidget {
  // StatelessWidget for the role selection page where users choose between patient and doctor roles during signup
  const RoleSelectionPage({super.key});

  static const _teal = Color(0xFF1ABFB0);
  static const _tealDark = Color(0xFF0C9D91);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold widget to provide the basic material design visual layout structure
      resizeToAvoidBottomInset: false,
      backgroundColor: _teal,
      body: SafeArea(
        // SafeArea widget to avoid system UI intrusions (e.g., notches, status bar)
        child: Column(
          children: [
            _buildHeroSection(context),
            Expanded(
              child: _buildContentCard(context),
            ), // Expanded widget to make the content card take up the remaining space below the hero section
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_tealDark, _teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -8,
            top: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/login and signup/3D Asset Clay Extra 3 2.png',
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: 20,
            top: 16,
            child: GestureDetector(
              onTap: () => context.go('/login'),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 17,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 28,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Who are you\njoining as?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Choose your role to get started',
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

  Widget _buildContentCard(BuildContext context) {
    // Build method to create the UI for the content card that contains role selection options
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
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _RoleCard(
                    icon: Icons.person_outline_rounded,
                    label: 'Patient',
                    description: 'Track your health,\nmedications & reminders',
                    onTap: () => context.go('/signup/patient'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RoleCard(
                    icon: Icons.medical_services_outlined,
                    label: 'Doctor',
                    description: 'Manage patients\n& appointments',
                    comingSoon: true,
                    onTap: () => context.go('/signup/doctor'),
                  ),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.go('/login'),
              child: RichText(
                text: const TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                  children: [
                    TextSpan(
                      text: 'Login',
                      style: TextStyle(
                        color: _teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  // Private widget for role selection cards for reusable UI components
  const _RoleCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    this.comingSoon = false,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback
  onTap; // Callback function to handle tap events on the role card
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    // Build method to create the UI for each role card
    return GestureDetector(
      onTap: comingSoon ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: comingSoon
              ? Colors.white.withValues(alpha: 0.5)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: comingSoon
                ? Colors.transparent
                : const Color(0xFF1ABFB0).withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: comingSoon
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon circle
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: comingSoon
                    ? const Color(0xFFE0E0E0)
                    : const Color(0xFFE0FAF8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 26,
                color: comingSoon ? Colors.black26 : const Color(0xFF1ABFB0),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: comingSoon ? Colors.black26 : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: comingSoon ? Colors.black26 : Colors.black45,
                height: 1.5,
              ),
            ),
            if (comingSoon) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Coming soon',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
