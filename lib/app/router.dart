import 'package:go_router/go_router.dart';

import '../features/auth/view/doctor_signup_page.dart';
import '../features/auth/view/forgot_password_page.dart';
import '../features/auth/view/login_page.dart';
import '../features/auth/view/reset_password_page.dart';
import '../features/auth/view/role_selection_page.dart';
import '../features/auth/view/signup_page.dart';
import '../features/onboarding/view/onboarding_page.dart';
import '../features/patient/home/view/patient_home_page.dart';
import '../features/splash/view/splash_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const RoleSelectionPage(),
    ),
    GoRoute(
      path: '/signup/patient',
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: '/signup/doctor',
      builder: (context, state) => const DoctorSignupPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const PatientHomePage(),
    ),
  ],
);
