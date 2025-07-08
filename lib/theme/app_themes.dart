// lib/theme/app_themes.dart
import 'package:flutter/material.dart';

class AppThemes {
  // Define our new calming primary color for Light Theme
  // This is a custom muted blue-green/seafoam color
  static const Color _lightPrimaryColor = Color(0xFF80CBC4); // A soft, calming teal/mint
  static const Color _lightPrimaryColorDarker = Color(0xFF4DB6AC); // A slightly darker shade for primary in light theme

  // Define our new primary color for Dark Theme
  static const Color _darkPrimaryColor = Color(0xFF00796B); // A deep, rich teal for dark mode

  // Define our new calming secondary/accent color for Light Theme
  static const Color _lightSecondaryColor = Color(0xFFFFCC80); // A soft, muted amber/peach
  // Define our new secondary/accent color for Dark Theme
  static const Color _darkSecondaryColor = Color(0xFFFFF176); // A slightly brighter amber for dark mode

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    // Use Material 3 theming for modern components
    useMaterial3: true,
    
    // Define the primary color directly for widgets that might still use it
    primaryColor: _lightPrimaryColorDarker,

    // Define the main ColorScheme for light mode
    colorScheme: ColorScheme.light(
      primary: _lightPrimaryColorDarker, // Main accent color for key elements
      onPrimary: Colors.white, // Text/icons on primary color
      secondary: _lightSecondaryColor, // Complementary accent color
      onSecondary: Colors.black87, // Text/icons on secondary color
      surface: Colors.white, // Background for cards, sheets, dialogs
      onSurface: Colors.black87, // Text/icons on background
      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.grey[50], // Very light grey background
    
    appBarTheme: AppBarTheme(
      color: _lightPrimaryColorDarker, // AppBar background color
      foregroundColor: Colors.white, // AppBar title/icon color
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    
    cardColor: Colors.white, // White card backgrounds
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, // Text/icon color on button
        backgroundColor: _lightPrimaryColorDarker, // Button background color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), // Softer corners
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0), // Comfortable padding
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightPrimaryColorDarker, // Text color for TextButtons
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightPrimaryColorDarker, // Text color for OutlinedButtons
        side: BorderSide(color: _lightPrimaryColorDarker), // Border color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightSecondaryColor, // FAB background
      foregroundColor: Colors.black87, // FAB icon color (contrasts with light accent)
    ),
    
    // Define text theme colors for light mode (dark text on light backgrounds)
    textTheme: TextTheme(
      displayLarge: TextStyle(color: Colors.grey[900]),
      displayMedium: TextStyle(color: Colors.grey[900]),
      displaySmall: TextStyle(color: Colors.grey[900]), // For summary card numbers
      headlineLarge: TextStyle(color: Colors.grey[900]),
      headlineMedium: TextStyle(color: Colors.grey[800]), // For "Hello $name"
      headlineSmall: TextStyle(color: Colors.grey[800]),
      titleLarge: TextStyle(color: Colors.grey[800]),   // For "Your Pet Overview" / "Booking Details"
      titleMedium: TextStyle(color: Colors.grey[700]),
      titleSmall: TextStyle(color: Colors.grey[700]),
      bodyLarge: TextStyle(color: Colors.grey[700]),    // Default text color for general content
      bodyMedium: TextStyle(color: Colors.grey[600]),
      bodySmall: TextStyle(color: Colors.grey[600]),
      labelLarge: TextStyle(color: Colors.grey[800]),
      labelMedium: TextStyle(color: Colors.grey[700]),
      labelSmall: TextStyle(color: Colors.grey[600]),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    
    // Define the primary color directly for widgets that might still use it
    primaryColor: _darkPrimaryColor,

    // Define the main ColorScheme for dark mode
    colorScheme: ColorScheme.dark(
      primary: _darkPrimaryColor, // Main accent color for key elements
      onPrimary: Colors.white,
      secondary: _darkSecondaryColor, // Complementary accent color
      onSecondary: Colors.black87, // Text/icons on secondary color
      surface: Colors.grey[850]!, // Darker surface for cards, dialogs
      onSurface: Colors.white70, // Lighter text/icons on dark backgrounds
      error: Colors.redAccent,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.grey[900], // Deep dark grey background
    
    appBarTheme: AppBarTheme(
      color: Colors.grey[850], // AppBar background color (darker than primary for separation)
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    
    cardColor: Colors.grey[850], // Darker card backgrounds
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: _darkPrimaryColor, // Darker green for buttons
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkPrimaryColor,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkPrimaryColor,
        side: BorderSide(color: _darkPrimaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color.fromARGB(255, 80, 182, 50), // FAB background
      foregroundColor: Colors.black87, // FAB icon color
    ),
    
    // Define text theme colors for dark mode (light text on dark backgrounds)
    textTheme: TextTheme(
      displayLarge: TextStyle(color: Colors.white),
      displayMedium: TextStyle(color: Colors.white),
      displaySmall: TextStyle(color: Colors.white70), // For summary card numbers
      headlineLarge: TextStyle(color: Colors.white),
      headlineMedium: TextStyle(color: Colors.white70),
      headlineSmall: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white70),
      titleMedium: TextStyle(color: Colors.white60),
      titleSmall: TextStyle(color: Colors.white60),
      bodyLarge: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white60),
      bodySmall: TextStyle(color: Colors.white60),
      labelLarge: TextStyle(color: Colors.white70),
      labelMedium: TextStyle(color: Colors.white60),
      labelSmall: TextStyle(color: Colors.white60),
    ),
  );
}