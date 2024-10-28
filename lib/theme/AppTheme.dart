import 'package:flutter/material.dart';

class AppTheme {
  static const double _smallTextSize = 12;
  static const double _mediumTextSize = 16;
  static const double _largeTextSize = 24;

  static const double _buttonRadius = 8;
  static const double _cardRadius = 12;

  static const EdgeInsets _defaultPadding = EdgeInsets.all(16);

  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorSchemeSeed: Colors.blue,
      scaffoldBackgroundColor: Colors.white,

      // Tipografía
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontSize: _largeTextSize,
            fontWeight: FontWeight.bold,
            color: Colors.black),
        headlineMedium: TextStyle(
            fontSize: _mediumTextSize,
            fontWeight: FontWeight.w600,
            color: Colors.black87),
        bodyMedium: TextStyle(fontSize: _mediumTextSize, color: Colors.black87),
        bodySmall: TextStyle(fontSize: _smallTextSize, color: Colors.black54),
      ),

      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_buttonRadius),
              ))),

      // Tarjetas
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),

      // Appbar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: _mediumTextSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.blueGrey[800],
      scaffoldBackgroundColor: Colors.blueGrey[900],

      // Tipografía
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontSize: _largeTextSize,
            fontWeight: FontWeight.bold,
            color: Colors.white),
        headlineMedium: TextStyle(
            fontSize: _mediumTextSize,
            fontWeight: FontWeight.w600,
            color: Colors.white70),
        bodyMedium: TextStyle(fontSize: _mediumTextSize, color: Colors.white70),
        bodySmall: TextStyle(fontSize: _smallTextSize, color: Colors.white70),
      ),

      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
        ),
      ),

      // Tarjetas
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
        filled: true,
        fillColor: Colors.blueGrey[800],
      ),

      // Appbar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: _mediumTextSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Métodos de utilidad para espaciado consistente.
  static EdgeInsets get defaultPadding => _defaultPadding;
  static EdgeInsets get smallPadding => _defaultPadding / 2;
  static EdgeInsets get largePadding => _defaultPadding * 1.5;
}
