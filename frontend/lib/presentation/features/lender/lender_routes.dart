import 'package:staki_mobile/core/router/app_routes.dart';

/// Route paths for Section 08 (lender onboarding).
abstract final class LenderRoutes {
  static const welcome = AppRoutes.lenderOnboarding; // LO01
  static const phone = '${AppRoutes.lenderOnboarding}/phone'; // LO02
  static const otp = '${AppRoutes.lenderOnboarding}/otp'; // LO03
  static const pin = '${AppRoutes.lenderOnboarding}/pin'; // LO04
  static const profile = '${AppRoutes.lenderOnboarding}/profile'; // LO05
  static const kyc = '${AppRoutes.lenderOnboarding}/kyc'; // LO06
  static const risk = '${AppRoutes.lenderOnboarding}/risk'; // LO07
  static const structure = '${AppRoutes.lenderOnboarding}/structure'; // LO08
  static const success = '${AppRoutes.lenderOnboarding}/success'; // LO09
}
