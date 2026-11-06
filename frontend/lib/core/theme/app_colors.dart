import 'package:flutter/material.dart';

/// Staki Fund colour tokens, read from the Figma file
/// "Design System Specs" > Variables > Color (Light mode).
///
/// OWNER: Binthia. The ONLY place raw hex values may appear.
/// Screens use these names only, never `Color(0xFF...)`.
///
/// Figma variable name is in the trailing comment of each token.
abstract final class AppColors {
  // Brand / actions
  static const Color primary = Color(0xFF191970); // brand/primary
  static const Color primaryPressed =
      Color(0xFF12125A); // brand/primary-pressed
  static const Color onPrimary = Color(0xFFFFFFFF); // brand/primary-foreground
  static const Color primarySoft = Color(0xFFF0F0FA); // brand/primary-tint

  // Surfaces
  static const Color background = Color(0xFFFFFFFF); // surface/background
  static const Color surface = Color(0xFFF8FAFC); // surface/surface

  /// NOT in Figma variables. Neutral for chips, disabled buttons and
  /// progress tracks. Replace if the design adds one.
  static const Color surfaceAlt = Color(0xFFF2F4F7);

  static const Color border = Color(0xFFE4E7EC); // border/border
  static const Color borderMid = Color(0xFFD0D5DD); // border/border-mid

  // Text
  static const Color textPrimary = Color(0xFF101828); // text/text
  static const Color textSecondary = Color(0xFF667085); // text/text-sec
  static const Color textMuted = Color(0xFF98A2B3); // text/text-dim

  // Status
  static const Color success = Color(0xFF12B76A); // status/success
  static const Color warning = Color(0xFFF79009); // status/warning
  static const Color danger = Color(0xFFD92D20); // status/error
  static const Color info = Color(0xFF2E5AAC); // status/info

  // Status backgrounds and text (banners, validation, badges)
  static const Color successBg = Color(0xFFECFDF3); // status/success-bg
  static const Color warningBg = Color(0xFFFFFAEB); // status/warning-bg
  static const Color dangerBg = Color(0xFFFEF3F2); // status/error-bg
  static const Color infoBg = Color(0xFFEFF4FF); // status/info-bg
  static const Color successText = Color(0xFF027A48); // status/success-text
  static const Color warningText = Color(0xFFB54708); // status/warning-text
  static const Color dangerText = Color(0xFFB42318); // status/error-text
  static const Color infoText = Color(0xFF1849A9); // status/info-text

  /// Info banner outline. Used in the P31 frame; not a Figma variable.
  static const Color infoBorder = Color(0xFFA4BCFD);

  // Credit Passport bands. Colours from the ScoreGauge frames in Figma
  // (DS1_FlutterSpecs / DS4_Data); they are not Figma variables.
  static const Color scorePoor = Color(0xFFF43535);
  static const Color scoreFair = Color(0xFFF47835);
  static const Color scoreGood = Color(0xFFF4C535);
  static const Color scoreVeryGood = Color(0xFF35C4F4);
  static const Color scoreExceptional = Color(0xFF0ABF7A);

  /// Band colour for a 300-1000 Credit Passport score.
  ///
  /// WARNING: thresholds follow the TEAM PLAN (580/670/740/800). The Figma
  /// gauge labels use 500/650/750/850. Abdull-Kudus and Binthia must agree on
  /// one set, then change it here and in the scoring function only.
  static Color forScore(int score) {
    if (score >= 800) return scoreExceptional;
    if (score >= 740) return scoreVeryGood;
    if (score >= 670) return scoreGood;
    if (score >= 580) return scoreFair;
    return scorePoor;
  }
}
