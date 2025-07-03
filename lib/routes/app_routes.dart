// // ignore: unused_import
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:pawpal/features/pets/add_pet_screen.dart';
// import 'package:pawpal/features/pets/pet_list_screen.dart';

// import '../features/auth/login_screen.dart';
// import '../features/auth/signup_screen.dart';
// import '../features/home/home_screen.dart';
// import '../widgets/placeholder_screen.dart';
// import '../features/auth/session_checker.dart';
// import '../features/bookings/book_service_screen.dart';
// import 'package:pawpal/features/bookings/select_pet_for_booking_screen.dart';

// import 'package:pawpal/features/bookings/schedule_details_screen.dart';

// import 'package:pawpal/features/bookings/booking_confirmation_screen.dart';

// import 'package:pawpal/features/bookings/my_bookings_screen.dart';

// final GoRouter appRouter = GoRouter(
//   initialLocation: '/',
//   routes: [
//     GoRoute(path: '/', builder: (context, state) => const SessionChecker()),
//     GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
//     GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
//     GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
//     // GoRoute(path: '/book', builder: (context, state) => const BookServiceScreen()),

//     GoRoute(path: '/pets', builder: (context, state) => const PetListScreen()),
//     GoRoute(path: '/pets/add', builder: (context, state) => const AddPetScreen()),

//     // GoRoute(path: '/pets', builder: (context, state) => const PlaceholderScreen(title: 'Pet Profiles')),
//     // GoRoute(path: '/pets/add', builder: (context, state) => const PlaceholderScreen(title: 'Adding Pets')),
//     GoRoute(path: '/support', builder: (context, state) => const PlaceholderScreen(title: 'Support')),


//     GoRoute(
//       path: '/book',
//       builder: (context, state) => const BookServiceScreen(),
//       routes: [
//         GoRoute(
//           path: 'select-pet/:serviceType', // <--- New sub-route with serviceType parameter
//           builder: (context, state) {
//             final serviceType = state.pathParameters['serviceType']!;
//             return SelectPetForBookingScreen(serviceType: serviceType);
//           },

//       routes: [ // <--- Nested route for schedule details
//             GoRoute(
//               path: 'schedule', // e.g., /book/select-pet/Boarding/schedule
//               builder: (context, state) {
//                 // We're getting serviceType from the parent route's path,
//                 // and selectedPetId from 'extra' as it's not in the path parameters.
//                 final serviceType = state.pathParameters['serviceType']!;
//                 final bookingData = state.extra as Map<String, dynamic>;
//                 final selectedPetId = bookingData['selectedPetId'] as String;
                
//                 return ScheduleDetailsScreen(
//                   serviceType: serviceType,
//                   selectedPetId: selectedPetId,
//                 );
//               },
//       routes: [ // <--- Nested route for booking confirmation
//               GoRoute(
//                 path: 'confirm', // e.g., /book/select-pet/Boarding/schedule/confirm
//                 builder: (context, state) {
//                   final bookingDetails = state.extra as Map<String, dynamic>;
//                   return BookingConfirmationScreen(bookingDetails: bookingDetails);
//                 },                 
//           ),
//         ],
//         ),
//       ],
//     ),
//   ],
//   ),
//   GoRoute(
//       path: '/my_bookings',
//       builder: (context, state) => const MyBookingsScreen(),
//     ),

//   GoRoute(
//         path: '/booking_confirmation',
//         builder: (context, state) {
//           final bookingDetails = state.extra as Map<String, dynamic>;
//           return BookingConfirmationScreen(bookingDetails: bookingDetails);
//         },
//       ),
//   ],
// );




import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pawpal/features/pets/add_pet_screen.dart';
import 'package:pawpal/features/pets/pet_list_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:provider/provider.dart'; // Import Provider
import 'package:pawpal/providers/profile_provider.dart'; // NEW: Import ProfileProvider

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
import 'package:pawpal/features/admin/admin_dashboard_screen.dart'; // NEW: Import AdminDashboardScreen

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  // NEW: Global redirect for authentication and role-based access
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
    // We use a FutureBuilder or similar in SessionChecker to wait for this in a real app
    // For GoRouter redirect, we need to fetch it synchronously or handle loading
    // For simplicity here, we'll try to fetch it. In a more complex app,
    // you might store the role in a provider after initial login.
    try {
      // Fetch the user's profile to get their role
      final response = await supabase
          .from('profiles') // Assuming your user roles are in a 'profiles' table
          .select('role')
          .eq('id', user.id)
          .single();
      
      final String role = response['role'] as String? ?? 'user'; // Default to 'user' if role is null

      // If the user is authenticated and trying to access login/signup, redirect to home/dashboard
      if (isLoggingIn || isSigningUp) {
        return role == 'admin' ? '/admin_dashboard' : '/home';
      }

      // If user is admin, redirect to admin dashboard unless already there
      if (role == 'admin') {
        return state.uri.path.startsWith('/admin_dashboard') ? null : '/admin_dashboard';
      } 
      // If user is a regular user, redirect to home unless already there
      else {
        return state.uri.path.startsWith('/home') || state.uri.path.startsWith('/pets') || state.uri.path.startsWith('/book') || state.uri.path.startsWith('/my_bookings') || state.uri.path.startsWith('/support') ? null : '/home';
      }

    } catch (e) {
      // If there's an error fetching profile (e.g., profile not found), log out and redirect to login
      print('Error fetching user role: $e');
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

    // NEW: Admin Dashboard Route
    GoRoute(
      path: '/admin_dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
      // You can add nested routes here for specific admin reports/management screens
      // Example:
      // routes: [
      //   GoRoute(
      //     path: 'reports',
      //     builder: (context, state) => const AdminReportsScreen(),
      //   ),
      //   GoRoute(
      //     path: 'users',
      //     builder: (context, state) => const AdminUserManagementScreen(),
      //   ),
      // ],
    ),
    // Removed the redundant top-level /booking_confirmation route
  ],
);





