// This seems to be the beginning of the code. 
  // Skeleton of the program, let's say.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PawPal',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      routerConfig: GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        ],
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Login Page")),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Home Page")),
    );
  }
}
