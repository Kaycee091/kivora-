import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/screens/welcome_screen.dart';
import '../../features/authentication/screens/sign_in_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/home/screens/member_home_screen.dart';
import '../../features/attendance/screens/check_in_screen.dart';
import '../../features/attendance/screens/verification_result_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/welcome',
  routes: [
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/auth/sign-in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/member/home',
      builder: (context, state) => const MemberHomeScreen(),
    ),
    GoRoute(
      path: '/member/attendance/check-in',
      builder: (context, state) => const CheckInScreen(),
    ),
    GoRoute(
      path: '/member/attendance/result',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return VerificationResultScreen(
          isSuccess: extra['isSuccess'] ?? true,
          status: extra['status'] ?? 'PASSED',
        );
      },
    ),
  ],
);
