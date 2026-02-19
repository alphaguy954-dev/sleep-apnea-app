import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primary     = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color accent      = Color(0xFF42A5F5);
  static const Color background  = Color(0xFFF5F7FA);
  static const Color surface     = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecond  = Color(0xFF6B7280);

  // Risk colors
  static const Color riskLow      = Color(0xFF2E7D32);
  static const Color riskModerate = Color(0xFFF57C00);
  static const Color riskHigh     = Color(0xFFD32F2F);
  static const Color riskSevere   = Color(0xFF7B1FA2);

  // Chart colors
  static const Color chartNormal = Color(0xFF42A5F5);
  static const Color chartApnea  = Color(0xFFEF5350);
  static const Color chartSpo2   = Color(0xFF66BB6A);

  static Color getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':      return riskLow;
      case 'moderate': return riskModerate;
      case 'high':     return riskHigh;
      case 'severe':   return riskSevere;
      default:         return riskLow;
    }
  }

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      color: surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
    ),
  );
}
