
// // // lib/main.dart
// // import 'package:flutter/material.dart';
// // import 'package:pawpal/routes/app_routes.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'package:flutter_dotenv/flutter_dotenv.dart';
// // import 'package:provider/provider.dart'; // Import the provider package

// // // Import your theme files
// // import 'package:pawpal/theme/app_themes.dart';
// // import 'package:pawpal/theme/theme_service.dart';

// // // Import your new data providers
// // import 'package:pawpal/providers/pet_provider.dart';
// // import 'package:pawpal/providers/booking_provider.dart';
// // import 'package:pawpal/providers/admin_stats_provider.dart'; // NEW: Import AdminStatsProvider


// // void main() async {
// //   // Ensure Flutter widgets are initialized
// //   WidgetsFlutterBinding.ensureInitialized();

// //   // Load environment variables from .env file
// //   await dotenv.load(fileName: ".env");

// //   // Initialize Supabase
// //   await Supabase.initialize(
// //     url: dotenv.env['SUPABASE_URL']!,
// //     anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
// //   );

// //   // Initialize ThemeService and load the saved theme preference
// //   final themeService = ThemeService();
// //   await themeService.loadThemeMode(); // Ensure theme preference is loaded before running the app
  
// //   // Create initial instances of data providers
// //   final petProvider = PetProvider();
// //   final bookingProvider = BookingProvider();
// //   final adminStatsProvider = AdminStatsProvider(); // NEW: Create instance of AdminStatsProvider

// //   // Run the app, providing all services/providers to the widget tree
// //   runApp(
// //     MultiProvider(
// //       providers: [
// //         ChangeNotifierProvider<ThemeService>(create: (context) => themeService),
// //         ChangeNotifierProvider<PetProvider>(create: (context) => petProvider),
// //         ChangeNotifierProvider<BookingProvider>(create: (context) => bookingProvider),
// //         ChangeNotifierProvider<AdminStatsProvider>(create: (context) => adminStatsProvider),
// //         ChangeNotifierProvider(create: (_) => PetProvider()), // NEW: Add AdminStatsProvider
// //       ],
// //       child: const MyApp(),
// //     ),
// //   );
// // }

// // // This widget is the root of your application.
// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     // Access ThemeService to get the current theme mode
// //     final themeService = Provider.of<ThemeService>(context);

// //     return MaterialApp.router(
// //       debugShowCheckedModeBanner: false,
// //       title: 'PawPal',
      
// //       // Assign your light and dark themes
// //       theme: AppThemes.lightTheme, 
// //       darkTheme: AppThemes.darkTheme,
      
// //       // Use the theme mode from ThemeService
// //       themeMode: themeService.themeMode, 

// //       // Your existing GoRouter configuration
// //       routerConfig: appRouter,
// //     );
// //   }
// // }






// // lib/main.dart
// import 'package:flutter/material.dart';
// import 'package:pawpal/routes/app_routes.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:provider/provider.dart'; // Import the provider package
// import 'package:flutter/foundation.dart' show kIsWeb; // NEW: Import kIsWeb
// import 'package:flutter_web_plugins/flutter_web_plugins.dart'; // NEW: Import for setUrlStrategy

// // Import your theme files
// import 'package:pawpal/theme/app_themes.dart';
// import 'package:pawpal/theme/theme_service.dart';

// // Import your new data providers
// import 'package:pawpal/providers/pet_provider.dart';
// import 'package:pawpal/providers/booking_provider.dart';
// import 'package:pawpal/providers/admin_stats_provider.dart'; // NEW: Import AdminStatsProvider
// import 'package:pawpal/providers/profile_provider.dart'; // NEW: Import ProfileProvider
// import 'package:pawpal/services/support_chat_service.dart';


// void main() async {
//   // Ensure Flutter widgets are initialized
//   WidgetsFlutterBinding.ensureInitialized();

//   // NEW: Set URL strategy only once and only for web
//   if (kIsWeb) {
//     setUrlStrategy(PathUrlStrategy());
//   }

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
  
//   // Create initial instances of data providers
//   final petProvider = PetProvider();
//   final bookingProvider = BookingProvider();
//   final adminStatsProvider = AdminStatsProvider(); // NEW: Create instance of AdminStatsProvider

//   // Run the app, providing all services/providers to the widget tree
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider<ThemeService>(create: (context) => themeService),
//         ChangeNotifierProvider<PetProvider>(create: (context) => petProvider),
//         ChangeNotifierProvider<BookingProvider>(create: (context) => bookingProvider),
//         ChangeNotifierProvider<AdminStatsProvider>(create: (context) => adminStatsProvider), // NEW: Add AdminStatsProvider
//         ChangeNotifierProvider<ProfileProvider>(create: (context) => ProfileProvider()), // Ensure ProfileProvider is here
        


//       ],
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
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// Import your theme files
import 'package:pawpal/theme/app_themes.dart';
import 'package:pawpal/theme/theme_service.dart';

// Import your new data providers
import 'package:pawpal/providers/pet_provider.dart';
import 'package:pawpal/providers/booking_provider.dart';
import 'package:pawpal/providers/admin_stats_provider.dart';
import 'package:pawpal/providers/profile_provider.dart';
import 'package:pawpal/services/support_chat_service.dart'; // Make sure this is imported!


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy());
  }

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final themeService = ThemeService();
  await themeService.loadThemeMode();
  
  final petProvider = PetProvider();
  final bookingProvider = BookingProvider();
  final adminStatsProvider = AdminStatsProvider();

  // Create an instance of SupportChatService
  final supportChatService = SupportChatService(); // Create instance here

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeService>(create: (context) => themeService),
        ChangeNotifierProvider<PetProvider>(create: (context) => petProvider),
        ChangeNotifierProvider<BookingProvider>(create: (context) => bookingProvider),
        ChangeNotifierProvider<AdminStatsProvider>(create: (context) => adminStatsProvider),
        ChangeNotifierProvider<ProfileProvider>(create: (context) => ProfileProvider()),
        // ADD THIS LINE: Provide SupportChatService
        ChangeNotifierProvider<SupportChatService>(create: (context) => supportChatService), 
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PawPal',
      theme: AppThemes.lightTheme, 
      darkTheme: AppThemes.darkTheme,
      themeMode: themeService.themeMode, 
      routerConfig: appRouter,
    );
  }
}