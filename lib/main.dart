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

  final supabaseClient = Supabase.instance.client;

  // Create an instance of SupportChatService
  final supportChatService = SupportChatService(supabaseClient); // Create instance here

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeService>(create: (context) => themeService),
        Provider<PetProvider>(create: (context) => petProvider),
        ChangeNotifierProvider<BookingProvider>(create: (context) => bookingProvider),
        Provider<AdminStatsProvider>(create: (context) => adminStatsProvider),
        Provider<ProfileProvider>(create: (context) => ProfileProvider()),
        // ADD THIS LINE: Provide SupportChatService
        Provider<SupportChatService>(create: (context) => supportChatService), 
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