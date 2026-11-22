import 'package:flutter/widgets.dart';

/// Icons from the Figma design (Phosphor, Bold for strokes, Fill for
/// objects). The Phosphor fonts are bundled in assets/fonts.
///
/// Use these instead of Material `Icons.*` so every screen matches Figma.
abstract final class AppIcons {
  static const _b = 'PhosphorBold';
  static const _f = 'PhosphorFill';

  static const IconData arrowCounterClockwise =
      IconData(0xe038, fontFamily: _b);
  static const IconData arrowDownLeft = IconData(0xe040, fontFamily: _b);
  static const IconData arrowRight = IconData(0xe06c, fontFamily: _b);
  static const IconData arrowUpRight = IconData(0xe092, fontFamily: _b);
  static const IconData arrowsClockwise = IconData(0xe094, fontFamily: _b);
  static const IconData backspace = IconData(0xe0ae, fontFamily: _b);
  static const IconData bank = IconData(0xe0b4, fontFamily: _f);
  static const IconData bell = IconData(0xe0ce, fontFamily: _f);
  static const IconData bellRinging = IconData(0xe5e8, fontFamily: _f);
  static const IconData briefcase = IconData(0xe0ee, fontFamily: _f);
  static const IconData buildings = IconData(0xe102, fontFamily: _f);
  static const IconData calendarX = IconData(0xe10c, fontFamily: _f);
  static const IconData camera = IconData(0xe10e, fontFamily: _f);
  static const IconData caretLeft = IconData(0xe138, fontFamily: _b);
  static const IconData caretRight = IconData(0xe13a, fontFamily: _b);
  static const IconData cellSignalLow = IconData(0xe146, fontFamily: _f);
  static const IconData chartBar = IconData(0xe150, fontFamily: _f);
  static const IconData chartLineUp = IconData(0xe156, fontFamily: _b);
  static const IconData check = IconData(0xe182, fontFamily: _b);
  static const IconData checkCircle = IconData(0xe184, fontFamily: _f);
  static const IconData circle = IconData(0xe18a, fontFamily: _f);
  static const IconData clock = IconData(0xe19a, fontFamily: _f);
  static const IconData clockCounterClockwise =
      IconData(0xe1a0, fontFamily: _b);
  static const IconData cloudArrowUp = IconData(0xe1ae, fontFamily: _f);
  static const IconData cloudSlash = IconData(0xe1b6, fontFamily: _f);
  static const IconData deviceMobile = IconData(0xe1e0, fontFamily: _f);
  static const IconData dotsNine = IconData(0xe1fc, fontFamily: _b);
  static const IconData downloadSimple = IconData(0xe20c, fontFamily: _b);
  static const IconData eye = IconData(0xe220, fontFamily: _f);
  static const IconData file = IconData(0xe230, fontFamily: _f);
  static const IconData fileDashed = IconData(0xe704, fontFamily: _f);
  static const IconData fileText = IconData(0xe23a, fontFamily: _f);
  static const IconData fingerprint = IconData(0xe23e, fontFamily: _b);
  static const IconData folderOpen = IconData(0xe256, fontFamily: _f);
  static const IconData funnel = IconData(0xe266, fontFamily: _f);
  static const IconData gauge = IconData(0xe628, fontFamily: _f);
  static const IconData globe = IconData(0xe288, fontFamily: _f);
  static const IconData graduationCap = IconData(0xe62c, fontFamily: _f);
  static const IconData hourglass = IconData(0xe2b2, fontFamily: _f);
  static const IconData identificationCard = IconData(0xe2c8, fontFamily: _f);
  static const IconData image = IconData(0xe2ca, fontFamily: _f);
  static const IconData info = IconData(0xe2ce, fontFamily: _f);
  static const IconData lightning = IconData(0xe2de, fontFamily: _f);
  static const IconData linkBreak = IconData(0xe2e4, fontFamily: _b);
  static const IconData lockKey = IconData(0xe2fe, fontFamily: _f);
  static const IconData magnifyingGlass = IconData(0xe30c, fontFamily: _b);
  static const IconData mapPin = IconData(0xe316, fontFamily: _f);
  static const IconData minusCircle = IconData(0xe32c, fontFamily: _f);
  static const IconData money = IconData(0xe588, fontFamily: _f);
  static const IconData notePencil = IconData(0xe34c, fontFamily: _f);
  static const IconData password = IconData(0xe752, fontFamily: _f);
  static const IconData pencilSimple = IconData(0xe3b4, fontFamily: _f);
  static const IconData phoneSlash = IconData(0xe3c2, fontFamily: _f);
  static const IconData prohibit = IconData(0xe3de, fontFamily: _f);
  static const IconData pulse = IconData(0xe000, fontFamily: _b);
  static const IconData question = IconData(0xe3e8, fontFamily: _f);
  static const IconData rocket = IconData(0xe3fc, fontFamily: _f);
  static const IconData rows = IconData(0xe5a2, fontFamily: _f);
  static const IconData scan = IconData(0xebb6, fontFamily: _b);
  static const IconData shield = IconData(0xe40a, fontFamily: _f);
  static const IconData shieldCheck = IconData(0xe40c, fontFamily: _f);
  static const IconData shieldWarning = IconData(0xe412, fontFamily: _f);
  static const IconData storefront = IconData(0xe470, fontFamily: _f);
  static const IconData timer = IconData(0xe492, fontFamily: _f);
  static const IconData tray = IconData(0xe4aa, fontFamily: _f);
  static const IconData trendDown = IconData(0xe4ac, fontFamily: _b);
  static const IconData trendUp = IconData(0xe4ae, fontFamily: _b);
  static const IconData user = IconData(0xe4c2, fontFamily: _f);
  static const IconData wallet = IconData(0xe68a, fontFamily: _f);
  static const IconData warning = IconData(0xe4e0, fontFamily: _f);
  static const IconData warningCircle = IconData(0xe4e2, fontFamily: _f);
  static const IconData wifiSlash = IconData(0xe4f2, fontFamily: _f);
  static const IconData wrench = IconData(0xe5d4, fontFamily: _f);
  static const IconData x = IconData(0xe4f6, fontFamily: _b);
}
