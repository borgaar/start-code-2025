import 'package:flutter/material.dart';

final themeData = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Colors.blueAccent,
    secondary: Color(0xFF6B7280), // Gray for secondary elements
    surface: Color(0xFF1F1F1F), // Very dark background
    error: Color(0xFFEF4444), // Red for errors
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: Color(0xFF121212),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF1F1F1F),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: Color(0xFF1F1F1F),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  listTileTheme: ListTileThemeData(
    tileColor: Color(0xFF1F1F1F),
    textColor: Colors.white,
    iconColor: Colors.white70,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.blueAccent,
    foregroundColor: Colors.white,
    elevation: 4,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: Color(0xFF1F1F1F),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: TextStyle(color: Colors.white70, fontSize: 16),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF2A2A2A),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    hintStyle: TextStyle(color: Colors.white38),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    bodySmall: TextStyle(color: Colors.white70),
    titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(color: Colors.white70),
  ),
  iconTheme: IconThemeData(color: Colors.white70),
  dividerTheme: DividerThemeData(color: Color(0xFF2A2A2A), thickness: 1),
);
