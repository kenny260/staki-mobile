/// Spacing and radius, mirroring the Figma variables
/// Spacing (space/1..16) and Radius (radius/xs..full). No magic numbers.
abstract final class AppSpacing {
  static const double xs = 4; // space/1
  static const double sm = 8; // space/2
  static const double s3 = 12; // space/3
  static const double md = 16; // space/4
  static const double s5 = 20; // space/5
  static const double lg = 24; // space/6
  static const double s7 = 28; // space/7
  static const double xl = 32; // space/8
  static const double s10 = 40; // space/10
  static const double s12 = 48; // space/12
  static const double s16 = 64; // space/16

  /// Horizontal screen padding.
  static const double screenPadding = 20; // matches Figma x-margin
}

abstract final class AppRadius {
  static const double xs = 4; // radius/xs
  static const double sm = 8; // radius/sm
  static const double md = 12; // radius/md
  static const double lg = 16; // radius/lg
  static const double xl = 20; // radius/xl
  static const double xxl = 24; // radius/2xl
  static const double pill = 9999; // radius/full
}
