import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand Colors - Premium Care Design System
  static const Color primary = Color(0xFF1A5D7A); // Petrol Blue (195 65% 29%)
  static const Color secondary = Color(0xFF8CAF8C); // Sage Green (95 25% 60%)
  static const Color accent = Color(0xFF318282); // Warm Petrol (180 45% 35%)

  // Neutral Colors
  static const Color background =
      Color(0xFFFAF9F5); // Creamy White (45 20% 98%)
  static const Color surface = Colors.white; // White
  static const Color textPrimary =
      Color(0xFF1C2530); // Dark Blue/Grey (210 25% 15%)
  static const Color textSecondary = Color(0xFF6B7280); // Muted Text
  static const Color border = Color(0xFFE5E7EB); // Light Grey

  // Vitta Custom Tokens
  static const Color vittaSage = Color(0xFF8CAF8C);
  static const Color vittaSageLight = Color(0xFFECF3EC); // (95 30% 92%)
  static const Color vittaPetrol = Color(0xFF1A5D7A);
  static const Color vittaPetrolLight = Color(0xFF3F7791); // (195 50% 45%)
  static const Color vittaCream = Color(0xFFF7F5F0); // (45 30% 96%)
  static const Color vittaWarm = Color(0xFFF5F2ED); // (35 40% 95%)

  // Status Colors
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
}
