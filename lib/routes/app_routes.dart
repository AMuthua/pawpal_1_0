import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pawpal/features/pets/add_pet_screen.dart';
import 'package:pawpal/features/pets/pet_list_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pawpal/providers/profile_provider.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/home/home_screen.dart';
import '../widgets/placeholder_screen.dart';
import '../features/auth/session_checker.dart';
import '../features/bookings/book_service_screen.dart';
import 'package:pawpal/features/bookings/select_pet_for_booking_screen.dart';
import 'package:pawpal/features/bookings/schedule_details_screen.dart';
import 'package:pawpal/features/bookings/booking_confirmation_screen.dart';
import 'package:pawpal/features/bookings/my_bookings_screen.dart';
import 'package:pawpal/features/admin/admin_dashboard_screen.dart';
import 'package:pawpal/features/admin/manage_services_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (BuildContext context, GoRouterState state) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    final bool isLoggingIn = state.uri.path == '/login';
    final bool isSigningUp = state.uri.path == '/signup';
    final bool isCheckingSession = state.uri.path == '/'; // Initial session check route

    debugPrint('Redirect triggered for path: ${state.uri.path}');
    debugPrint('Current user: ${user?.id ?? 'null'}');

    // If user is not logged in
    if (user == null) {
      debugPrint('User is null. Is logging in/signing up/checking session? $isLoggingIn || $isSigningUp || $isCheckingSession');
      // Allow access to login, signup, and session checker
      return (isLoggingIn || isSigningUp || isCheckingSession) ? null : '/login';
    }

    // If user is logged in, fetch their profile to determine role
    try {
      debugPrint('User is logged in. Fetching profile for role...');
      final response = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();
      
      final String role = response['role'] as String? ?? 'user'; // Default to 'user' if role is null

      debugPrint('Fetched user role: $role');

      // If the user is authenticated and trying to access login/signup, redirect to home/dashboard
      if (isLoggingIn || isSigningUp) {
        debugPrint('User is authenticated and trying to access login/signup. Redirecting based on role.');
        return role == 'admin' ? '/admin_dashboard' : '/home';
      }

      // If user is admin, redirect to admin dashboard unless already there
      if (role == 'admin') {
        debugPrint('User is admin. Current path: ${state.uri.path}. Is it an admin path? ${state.uri.path.startsWith('/admin_dashboard')}');
        return state.uri.path.startsWith('/admin_dashboard') ? null : '/admin_dashboard';
      } 
      // If user is a regular user, redirect to home unless already there or on allowed user paths
      else {
        debugPrint('User is regular. Current path: ${state.uri.path}. Is it an admin path? ${state.uri.path.startsWith('/admin_dashboard')}');
        // If regular user tries to access admin route, redirect to home
        if (state.uri.path.startsWith('/admin_dashboard')) {
          debugPrint('Regular user trying to access admin path. Redirecting to /home.');
          return '/home';
        }
        // Otherwise, allow access to user-specific paths or redirect to home if on root
        return state.uri.path.startsWith('/home') || 
               state.uri.path.startsWith('/pets') || 
               state.uri.path.startsWith('/book') || 
               state.uri.path.startsWith('/my_bookings') || 
               state.uri.path.startsWith('/support') ? null : '/home';
      }

    } catch (e) {
      debugPrint('Error fetching user role during redirect: $e'); // Changed print to debugPrint
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
    GoRoute(path: '/support', builder: (context, state) => const PlaceholderScreen(title: 'Support')),
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

    // Admin-specific routes
    GoRoute(
      path: '/admin_dashboard', // Main admin dashboard route
      builder: (context, state) => const AdminDashboardScreen(),
      routes: [
        // Nested route for managing services
        GoRoute(
          path: 'services', // Full path will be /admin_dashboard/services
          builder: (context, state) => const ManageServicesScreen(),
        ),
        // Add other admin sub-routes here as they are developed
      ],
    ),
  ],
);
