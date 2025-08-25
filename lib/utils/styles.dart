import 'package:flutter/material.dart';

class Styles {
  static const Color bgDark = Color(0xFF0D0B1E);
  static const Color backgroundDark = Color(0xFF0D0B1E);
  static const Color cardDark = Color(0xFF1E1C2A);

  static ThemeData get appTheme => ThemeData.dark(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: bgDark,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
    ),
  );

  static const TextStyle titleText = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle subTitleText = TextStyle(
    fontSize: 16,
    color: Colors.white70,
  );

  static const TextStyle cardTitleText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle cardSubTextSmall = TextStyle(
    fontSize: 12,
    color: Colors.white70,
  );

  static const TextStyle metricNumber = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static Color get primaryBackground => bgDark;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF0057B8), // Blue
      Color(0xFF2C3D99), // Indigo
      Color(0xFF512DA8), // Purple
      Color(0xFF8E24AA), // Deep Purple-Pink
      Color(0xFFC2185B), // Dark Pink
      Color(0xFFD50087), // Bright Pink
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient glassGradient = LinearGradient(
    colors: [
      const Color.fromRGBO(255, 255, 255, 0.1),
      const Color.fromRGBO(255, 255, 255, 0.05),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ✅ Place this inside the class body — not outside!
  static LinearGradient get backgroundGradientFromImage {
    return const LinearGradient(
      colors: [
        Color(0xFF060415), // dark blue
        Color(0xFF1C1A4A), // indigo
        Color(0xFF40225D), // deep purple
        Color(0xFF611E41), // maroon
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
