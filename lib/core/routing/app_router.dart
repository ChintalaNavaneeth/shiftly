import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/landing_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const LandingPage(),
    ),
    // Dummy routes for role-based redirection
    GoRoute(
      path: '/admin',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Admin Home'))),
    ),
    GoRoute(
      path: '/worker',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Worker Home'))),
    ),
    GoRoute(
      path: '/provider',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Provider Home'))),
    ),
    GoRoute(
      path: '/verifier',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Verifier Home'))),
    ),
    GoRoute(
      path: '/customer-service',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Customer Service Home'))),
    ),
    GoRoute(
      path: '/data-analytics',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Data Analytics Home'))),
    ),
  ],
);
