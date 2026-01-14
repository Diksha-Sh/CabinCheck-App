import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color background = Color(0xFFF5F5F7);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFB00020);

  // Status Colors
  static const Color statusAvailable = Color(0xFF4CAF50);
  static const Color statusBusy = Color(0xFFFFC107);
  static const Color statusUnavailable = Color(0xFFF44336);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
