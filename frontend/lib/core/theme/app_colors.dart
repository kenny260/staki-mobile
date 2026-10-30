import 'package:flutter/material.dart';

/// Central colour tokens for Staki Fund.
///
/// OWNER: Binthia. These are the ONLY colours the app uses.
/// Do not hard-code hex anywhere else; always reference AppColors.
///
// TODO(Binthia): replace every placeholder below with the exact hex read
/// from Figma Dev Mode (Staki Fund - Mobile Screens). Keep the token names.
class AppColors {
  AppColors._();

  // Brand / primary
  static const Color primary = Color(0xFF0B6B3A);
  static const Color primaryPressed = Color(0xFF085A30);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Surfaces
  static const Color background = Color(0xFFF7F8F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFEFF2EF);

  // Lines
  static const Color border = Color(0xFFD9DED9);

  // Text
  static const Color textPrimary = Color(0xFF141A14);
  static const Color textSecondary = Color(0xFF4B544B);
  static const Color textMuted = Color(0xFF8A928A);

  // Status
  static const Color success = Color(0xFF1F9D55);
  static const Color warning = Color(0xFFE0A106);
  static const Color danger = Color(0xFFD64545);
  static const Color info = Color(0xFF2B6CB0);

  // Credit Passport score bands (300-1000)
  static const Color scorePoor = Color(0xFFD64545); // 300-579   TODO
  static const Color scoreFair = Color(0xFFE0A106); // 580-669   TODO
  static const Color scoreGood = Color(0xFF3DA35D); // 670-739   TODO
  static const Color scoreVeryGood = Color(0xFF1F9D55); // 740-799 TODO
  static const Color scoreExceptional = Color(0xFF0B6B3A); // 800-1000 TODO
}
