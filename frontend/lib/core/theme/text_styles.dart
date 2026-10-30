import 'package:flutter/material.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';

/// Typography tokens. TODO(Binthia): match sizes/weights to Figma Dev Mode.
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily =
      'Inter'; // TODO(Binthia): confirm from Figma.

  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onPrimary,
  );
}
