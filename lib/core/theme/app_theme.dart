import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      colorScheme: const ColorScheme.light().copyWith(
        primary: Color(0xFF00A651),
        secondary: Color(0xFF00A651),
      ),
      useMaterial3: true,
    );
  }
}
