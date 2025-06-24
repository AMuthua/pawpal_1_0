// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pawpal/features/pets/add_pet_screen.dart';
import 'package:pawpal/features/pets/pet_list_screen.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/home/home_screen.dart';
import '../widgets/placeholder_screen.dart';
import '../features/auth/session_checker.dart';
import '../features/bookings/book_service_screen.dart';
import 'package:pawpal/features/bookings/select_pet_for_booking_screen.dart';

import 'package:pawpal/features/bookings/schedule_details_screen.dart';

import 'package:pawpal/features/bookings/booking_confirmation_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SessionChecker()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    // GoRoute(path: '/book', builder: (context, state) => const BookServiceScreen()),

    GoRoute(path: '/pets', builder: (context, state) => const PetListScreen()),
    GoRoute(path: '/pets/add', builder: (context, state) => const AddPetScreen()),

    // GoRoute(path: '/pets', builder: (context, state) => const PlaceholderScreen(title: 'Pet Profiles')),
    // GoRoute(path: '/pets/add', builder: (context, state) => const PlaceholderScreen(title: 'Adding Pets')),
    GoRoute(path: '/support', builder: (context, state) => const PlaceholderScreen(title: 'Support')),


    GoRoute(
      path: '/book',
      builder: (context, state) => const BookServiceScreen(),
      routes: [
        GoRoute(
          path: 'select-pet/:serviceType', // <--- New sub-route with serviceType parameter
          builder: (context, state) {
            final serviceType = state.pathParameters['serviceType']!;
            return SelectPetForBookingScreen(serviceType: serviceType);
          },

      routes: [ // <--- Nested route for schedule details
            GoRoute(
              path: 'schedule', // e.g., /book/select-pet/Boarding/schedule
              builder: (context, state) {
                // We're getting serviceType from the parent route's path,
                // and selectedPetId from 'extra' as it's not in the path parameters.
                final serviceType = state.pathParameters['serviceType']!;
                final bookingData = state.extra as Map<String, dynamic>;
                final selectedPetId = bookingData['selectedPetId'] as String;
                
                return ScheduleDetailsScreen(
                  serviceType: serviceType,
                  selectedPetId: selectedPetId,
                );
              },
      routes: [ // <--- Nested route for booking confirmation
              GoRoute(
                path: 'confirm', // e.g., /book/select-pet/Boarding/schedule/confirm
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
  ],
);
