// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/home/home_screen.dart';
import '../widgets/placeholder_screen.dart';
import '../features/auth/session_checker.dart';
import '../features/bookings/book_service_screen.dart';


final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SessionChecker()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/book', builder: (context, state) => const BookServiceScreen()),
    GoRoute(path: '/pets', builder: (context, state) => const PlaceholderScreen(title: 'Pet Profiles')),
    GoRoute(path: '/support', builder: (context, state) => const PlaceholderScreen(title: 'Support')),
  ],
);
