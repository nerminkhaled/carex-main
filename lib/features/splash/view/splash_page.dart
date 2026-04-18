import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/splash_bloc.dart';

class SplashPage extends StatelessWidget {
  //splash
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashBloc()..add(const SplashStarted()),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashFinished) {
          if (state.isLoggedIn) {
            context.go('/home');
          } else {
            context.go(state.showOnboarding ? '/onboarding' : '/login');
          }
        }
      },
      child: const Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(0xFFF0FAFA),
        body: _SplashBody(),
      ),
    );
  }
}

class _SplashBody extends StatefulWidget {
  const _SplashBody();

  @override
  State<_SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<_SplashBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Cross
  late final Animation<double> _crossFade;
  late final Animation<double> _crossScale;

  // Logo
  late final Animation<double> _logoFade;
  late final Animation<Offset> _logoSlide;

  // Wave
  late final Animation<Offset> _waveSlide;

  // Illustration
  late final Animation<double> _illustrationFade;
  late final Animation<double> _illustrationScale;

  // Dots
  late final Animation<double> _dotsFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _crossFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
    );

    _crossScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
    );

    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
          ),
        );

    _waveSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
          ),
        );

    _illustrationFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
    );

    _illustrationScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
      ),
    );

    _dotsFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        // ── Top: cross + logo ──────────────────────────────────────
        Expanded(
          flex: 55,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 3D cross fades + scales in
              Positioned.fill(
                child: FadeTransition(
                  opacity: _crossFade,
                  child: ScaleTransition(
                    scale: _crossScale,
                    child: Image.asset(
                      'assets/images/splash screen/3D Asset Clay Extra 3 1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // CareX logo slides up + fades in
              Positioned(
                bottom: size.height * 0.07,
                child: FadeTransition(
                  opacity: _logoFade,
                  child: SlideTransition(
                    position: _logoSlide,
                    child: Image.asset(
                      'assets/images/splash screen/Frame 1.png',
                      width: size.width * 0.8,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Bottom: wave + illustration + dots ────────────────────
        Expanded(
          flex: 45,
          child: SlideTransition(
            position: _waveSlide,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Teal wave
                Positioned.fill(
                  child: ClipPath(
                    clipper: _WaveClipper(),
                    child: const ColoredBox(color: Color(0xFF1ABFB0)),
                  ),
                ),

                // Illustration fades + scales in
                Positioned(
                  top: -size.height * 0.04,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _illustrationFade,
                    child: ScaleTransition(
                      scale: _illustrationScale,
                      child: Image.asset(
                        'assets/images/splash screen/Image.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Page indicator dots
                Positioned(
                  bottom: 32,
                  child: FadeTransition(
                    opacity: _dotsFade,
                    child: Image.asset(
                      'assets/images/splash screen/Frame 16.png',
                      width: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 50);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, 36);
    path.quadraticBezierTo(size.width * 0.75, 72, size.width, 24);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => false;
}
