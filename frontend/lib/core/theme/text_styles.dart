import 'package:flutter/material.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';

/// Typography. Font is Inter (per Figma). Sizes come from the Figma
/// "Font size" variables: 11, 12, 14, 15, 16, 18, 20, 24, 28, 32.
///
/// Add the Inter font files under assets/fonts and register them in
/// pubspec.yaml; until then Flutter falls back to the system font.
abstract final class AppTextStyles {
  static const String fontFamily = 'Inter';

  /// Hero headline (Inter ExtraBold 28).
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 1.2,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  /// Screen heading in the P-frames (Inter ExtraBold 22, -0.5 tracking).
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 1.2,
    letterSpacing: -0.5,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  /// Section heading (text/2xl).
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Card title (text/md).
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Supporting copy (text/base).
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Field, chip and tab labels (Inter SemiBold 13).
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Screen sub-heading under h1 (Inter Regular 13).
  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Text typed into a field (Inter Regular 14).
  static const TextStyle fieldText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// OTP digit (Inter Bold 22).
  static const TextStyle otpDigit = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Bottom-nav label (Inter 10).
  static const TextStyle navLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );

  /// Helper and meta text (text/sm).
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  /// Button label (text/md, SemiBold). Colour comes from the button theme.
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
}
