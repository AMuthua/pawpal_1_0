// lib/theme/app_themes.dart
import 'package:flutter/material.dart';

class AppThemes {
  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.teal, // Your app's primary color
    // accentColor: Colors.deepOrangeAccent, // Deprecated in newer Flutter versions, use colorScheme.secondary
    colorScheme: ColorScheme.light(
      primary: Colors.teal,
      secondary: Colors.deepOrangeAccent, // Accent color
      onPrimary: Colors.white, // Text/icon color on primary
      onSecondary: Colors.white, // Text/icon color on secondary
      surface: Colors.white, // Card, dialog backgrounds
      onSurface: Colors.black87, // Text/icon color on surface
      background: Colors.white, // Scaffold background
      onBackground: Colors.black87, // Text/icon color on background
      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      color: Colors.teal, // AppBar background color
      foregroundColor: Colors.white, // AppBar title/icon color
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    cardColor: Colors.white,
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.teal,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, // Text/icon color
        backgroundColor: Colors.teal, // Button background color
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Colors.teal),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.teal, // Text color
        side: const BorderSide(color: Colors.teal), // Border color
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87), // Default text color
      bodyMedium: TextStyle(color: Colors.black54),
      titleLarge: TextStyle(color: Colors.black87),
      // ... define other text styles as needed
    ),
    // Add more customizations for light theme
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.teal[800], // Darker primary color
    colorScheme: ColorScheme.dark(
      primary: Colors.teal[800]!,
      secondary: Colors.orange[700]!, // Accent color for dark mode
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      surface: Colors.grey[850]!, // Darker card, dialog backgrounds
      onSurface: Colors.white70,
      background: Colors.grey[900]!, // Dark scaffold background
      onBackground: Colors.white70,
      error: Colors.redAccent,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      color: Colors.grey[850], // Darker AppBar background color
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    cardColor: Colors.grey[850],
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.teal[800],
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal[800],
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Colors.teal[400]),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.teal[400],
        side: BorderSide(color: Colors.teal[400]!),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.teal[800],
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white70), // Default text color for dark mode
      bodyMedium: TextStyle(color: Colors.white54),
      titleLarge: TextStyle(color: Colors.white),
      // ... define other text styles as needed
    ),
    // Add more customizations for dark theme
  );
}