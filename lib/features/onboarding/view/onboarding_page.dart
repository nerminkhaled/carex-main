import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/onboarding_bloc.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  late final PageController _pageController;

  static const _pages = [
    _OnboardingData(
      image: 'assets/images/onbording screeen/Frame 18.png',
      highlightedWord: 'Stay ',
      title: 'on track',
      subtitle:
          'Easily set up reminders for your doses, and refills on your device.',
    ),
    _OnboardingData(
      image: 'assets/images/onbording screeen/Frame 19.png',
      highlightedWord: 'All ',
      title: 'on your phone',
      subtitle:
          'Stay consistent and organized. Monitor your doses, doctors\' appointments and keep your health on track.',
    ),
    _OnboardingData(
      image: 'assets/images/onbording screeen/Frame 20.png',
      highlightedWord: 'Meet ',
      title: 'your AI health assistant',
      subtitle:
          'Ask questions, get guidance, and manage your care through our intelligent chatbot, anytime.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _markSeenAndGo(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (context.mounted) context.go('/login');
  }

  void _next(BuildContext context, int currentPage) {
    if (currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _markSeenAndGo(context);
    }
  }

  void _back(int currentPage) {
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        final page = state.currentPage;
        final isLast = page == _pages.length - 1;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color(0xFFCAF9FF),
          body: SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back arrow
                      if (page > 0)
                        GestureDetector(
                          onTap: () => _back(page),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: Color(0xFFcaf9ff),
                          ),
                        )
                      else
                        const SizedBox(width: 20),

                      // Skip
                      if (!isLast)
                        GestureDetector(
                          onTap: () => _markSeenAndGo(context),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Illustration ─────────────────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => context
                        .read<OnboardingBloc>()
                        .add(OnboardingPageChanged(i)),
                    itemCount: _pages.length,
                    itemBuilder: (context, i) {
                      return Image.asset(
                        _pages[i].image,
                        fit: BoxFit.scaleDown,
                      );
                    },
                  ),
                ),

                // ── Bottom card ──────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 36),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (i) => _Dot(active: i == page),
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Title
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _pages[page].highlightedWord,
                              style: const TextStyle(
                                color: Color(0xFF1ABFB0),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: _pages[page].title,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        _pages[page].subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13.5,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Next / Get started button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => _next(context, page),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1ABFB0),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isLast ? 'Get started' : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF1ABFB0) : const Color(0xFFCCECEA),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.image,
    required this.highlightedWord,
    required this.title,
    required this.subtitle,
  });

  final String image;
  final String highlightedWord;
  final String title;
  final String subtitle;
}
