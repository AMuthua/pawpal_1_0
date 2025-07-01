// // // import 'package:flutter/material.dart';

// // // void main() {
// // //   runApp(const MyApp());
// // // }

// // // Some of the first new code. 
// // import 'package:flutter/material.dart';
// // import 'package:pawpal/routes/app_routes.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';

// // // import 'package:pawpal/features/auth/login_screen.dart';
// // import 'package:flutter_dotenv/flutter_dotenv.dart';


// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await dotenv.load(fileName: ".env");

// //   await Supabase.initialize(
// //     url: dotenv.env['SUPABASE_URL']!,
// //     anonKey: dotenv.env['SUPABASE_ANON_KEY']!,

// //   );
// //   runApp(const MyApp());
// // }

// //   // This widget is the root of your application.
// //   class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp.router(
// //       debugShowCheckedModeBanner: false,
// //       title: 'PawPal',
// //       theme: ThemeData(
// //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
// //         useMaterial3: true,
// //       ),
// //       routerConfig: appRouter,
// //     );
// //   }
// // }
  



// import 'package:flutter/material.dart';
// import 'package:pawpal/routes/app_routes.dart'; // Your GoRouter configuration
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:provider/provider.dart'; // Import the provider package

// // Import your theme files
// import 'package:pawpal/theme/app_themes.dart'; // Adjust path if necessary
// import 'package:pawpal/theme/theme_service.dart'; // Adjust path if necessary


// void main() async {
//   // Ensure Flutter widgets are initialized
//   WidgetsFlutterBinding.ensureInitialized();

//   // Load environment variables from .env file
//   await dotenv.load(fileName: ".env");

//   // Initialize Supabase
//   await Supabase.initialize(
//     url: dotenv.env['SUPABASE_URL']!,
//     anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
//   );

//   // Initialize ThemeService and load the saved theme preference
//   final themeService = ThemeService();
//   await themeService.loadThemeMode(); // Ensure theme preference is loaded before running the app

//   // Run the app, providing ThemeService to the widget tree
//   runApp(
//     ChangeNotifierProvider<ThemeService>(
//       create: (context) => themeService,
//       child: const MyApp(),
//     ),
//   );
// }

// // This widget is the root of your application.
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Access ThemeService to get the current theme mode
//     final themeService = Provider.of<ThemeService>(context);

//     return MaterialApp.router(
//       debugShowCheckedModeBanner: false,
//       title: 'PawPal',
      
//       // Assign your light and dark themes
//       theme: AppThemes.lightTheme, 
//       darkTheme: AppThemes.darkTheme,
      
//       // Use the theme mode from ThemeService
//       themeMode: themeService.themeMode, 

//       // Your existing GoRouter configuration
//       routerConfig: appRouter,
//     );
//   }
// }


// lib/main.dart
import 'package:flutter/material.dart';
import 'package:pawpal/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart'; // Import the provider package

// Import your theme files
import 'package:pawpal/theme/app_themes.dart';
import 'package:pawpal/theme/theme_service.dart';

// Import your new data providers
import 'package:pawpal/providers/pet_provider.dart';
import 'package:pawpal/providers/booking_provider.dart';


void main() async {
  // Ensure Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize ThemeService and load the saved theme preference
  final themeService = ThemeService();
  await themeService.loadThemeMode(); // Ensure theme preference is loaded before running the app
  
  // Create initial instances of data providers
  final petProvider = PetProvider();
  final bookingProvider = BookingProvider();

  // Run the app, providing all services/providers to the widget tree
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeService>(create: (context) => themeService),
        ChangeNotifierProvider<PetProvider>(create: (context) => petProvider),
        ChangeNotifierProvider<BookingProvider>(create: (context) => bookingProvider),
      ],
      child: const MyApp(),
    ),
  );
}

// This widget is the root of your application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access ThemeService to get the current theme mode
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PawPal',
      
      // Assign your light and dark themes
      theme: AppThemes.lightTheme, 
      darkTheme: AppThemes.darkTheme,
      
      // Use the theme mode from ThemeService
      themeMode: themeService.themeMode, 

      // Your existing GoRouter configuration
      routerConfig: appRouter,
    );
  }
}
