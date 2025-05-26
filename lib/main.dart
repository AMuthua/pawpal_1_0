// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// Some of the first new code. 
import 'package:flutter/material.dart';
import 'package:pawpal/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:pawpal/features/auth/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,

  );
  runApp(const MyApp());
}

  // This widget is the root of your application.
  class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PawPal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
  

