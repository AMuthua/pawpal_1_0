// app_routes.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

// Feature imports (kept for context, but not changed)
import 'package:pawpal/features/auth/login_screen.dart';
import 'package:pawpal/features/auth/signup_screen.dart';
import 'package:pawpal/features/home/home_screen.dart';
import 'package:pawpal/features/auth/session_checker.dart';
import 'package:pawpal/features/pets/add_pet_screen.dart';
import 'package:pawpal/features/pets/pet_list_screen.dart';
import 'package:pawpal/features/bookings/book_service_screen.dart';
import 'package:pawpal/features/bookings/select_pet_for_booking_screen.dart';
import 'package:pawpal/features/bookings/schedule_details_screen.dart';
import 'package:pawpal/features/bookings/booking_confirmation_screen.dart';
import 'package:pawpal/features/bookings/my_bookings_screen.dart';
import 'package:pawpal/features/support/customer_support_screen.dart';
import 'package:pawpal/features/support/client_chat_screen.dart';

// Admin feature imports
import 'package:pawpal/features/admin/admin_dashboard_screen.dart';
import 'package:pawpal/features/admin/admin_bookings_screen.dart';
import 'package:pawpal/features/admin/admin_user_management_screen.dart';
import 'package:pawpal/features/admin/manage_services_screen.dart';
import 'package:pawpal/features/admin/admin_support_chat_screen.dart';
import 'package:pawpal/features/admin/admin_chat_detail_screen.dart';

// Provider imports
import 'package:pawpal/providers/profile_provider.dart';
import 'package:pawpal/providers/admin_stats_provider.dart'; // <--- Make sure this is imported!


final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  // Global redirect for authentication and role-based access
  redirect: (BuildContext context, GoRouterState state) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    // List of routes accessible to unauthenticated users
    final bool isLoggingIn = state.uri.path == '/login';
    final bool isSigningUp = state.uri.path == '/signup';
    final bool isCheckingSession = state.uri.path == '/';

    // If user is not logged in
    if (user == null) {
      // Allow access to login, signup, and session checker
      return (isLoggingIn || isSigningUp || isCheckingSession) ? null : '/login';
    }

    // If user is logged in, fetch their profile to determine role
    try {
      // Use .maybeSingle() to handle cases where profile might not exist yet
      final Map<String, dynamic>? response = await supabase
          .from('profiles') // Assuming your user roles are in a 'profiles' table
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      // If profile is not found, default to 'user' role
      final String role = response?['role'] as String? ?? 'user';

      // If the user is authenticated and trying to access login/signup, redirect to home/dashboard
      if (isLoggingIn || isSigningUp) {
        return role == 'admin' ? '/admin_dashboard' : '/home';
      }

      // If user is admin, allow access to admin routes or redirect to dashboard
      if (role == 'admin') {
        // Allow access to any path starting with /admin_dashboard
        if (state.uri.path.startsWith('/admin_dashboard')) {
          return null;
        }
        return '/admin_dashboard';
      }
      // If user is a regular user, allow access to user routes or redirect to home
      else {
        // Define allowed user paths
        final allowedUserPaths = [
          '/home', '/pets', '/book', '/my_bookings', '/support'
        ];
        // Check if the current path starts with any allowed user path
        if (allowedUserPaths.any((path) => state.uri.path.startsWith(path))) {
          return null;
        }
        return '/home';
      }
    } catch (e) {
      // If there's an error fetching profile, log out and redirect to login
      debugPrint('Error fetching user role in redirect: $e'); // Use debugPrint for Flutter
      await supabase.auth.signOut();
      return '/login';
    }
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SessionChecker()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),

    // User-specific routes
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/pets', builder: (context, state) => const PetListScreen()),
    GoRoute(path: '/pets/add', builder: (context, state) => const AddPetScreen()),

    // Client Support Chat routes
    GoRoute(
      path: '/support', // This route leads to the client's list of chats
      builder: (context, state) => const CustomerSupportScreen(),
      routes: [
        GoRoute(
          path: 'chat/:chatId', // This path leads to a specific chat for the client
          builder: (context, state) {
            final chatId = state.pathParameters['chatId']!;
            return ClientChatScreen(chatId: chatId);
          },
        ),
      ],
    ),

    // Booking flow routes
    GoRoute(
      path: '/book',
      builder: (context, state) => const BookServiceScreen(),
      routes: [
        GoRoute(
          path: 'select-pet/:serviceType',
          builder: (context, state) {
            final serviceType = state.pathParameters['serviceType']!;
            return SelectPetForBookingScreen(serviceType: serviceType);
          },
          routes: [
            GoRoute(
              path: 'schedule',
              builder: (context, state) {
                final serviceType = state.pathParameters['serviceType']!;
                final bookingData = state.extra as Map<String, dynamic>;
                final selectedPetId = bookingData['selectedPetId'] as String;

                return ScheduleDetailsScreen(
                  serviceType: serviceType,
                  selectedPetId: selectedPetId,
                );
              },
              routes: [
                GoRoute(
                  path: 'confirm',
                  builder: (context, state) {
                    final bookingDetails = state.extra as Map<String, dynamic>;
                    return BookingConfirmationScreen(bookingDetails: bookingDetails);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/my_bookings',
      builder: (context, state) => const MyBookingsScreen(),
    ),

    // Admin Dashboard and nested routes
    GoRoute(
      path: '/admin_dashboard',
      // The crucial change is here: Wrap AdminDashboardScreen with ChangeNotifierProvider
      builder: (context, state) => ChangeNotifierProvider<AdminStatsProvider>(
        create: (context) => AdminStatsProvider(),
        child: const AdminDashboardScreen(), // AdminDashboardScreen is now a child of ChangeNotifierProvider
      ),
      routes: [
        GoRoute(
          path: 'services', // Route for managing services
          builder: (context, state) => const ManageServicesScreen(),
        ),
        GoRoute(
          path: 'bookings', // Route for managing bookings
          builder: (context, state) => const AdminBookingsScreen(),
        ),
        GoRoute(
          path: 'users', // Route for managing users
          builder: (context, state) => const AdminUserManagementScreen(),
        ),
        // Admin Support Chats routes
        GoRoute(
          path: 'support_chats', // Admin's list of all support chats
          builder: (context, state) => const AdminSupportChatScreen(),
          routes: [
            GoRoute(
              path: ':chatId', // Admin's individual chat view
              builder: (context, state) {
                final chatId = state.pathParameters['chatId']!;
                return AdminChatDetailScreen(chatId: chatId);
              },
            ),
          ],
        ),
        // You can add more admin routes here (e.g., 'reports', 'settings')
      ],
    ),
  ],
);