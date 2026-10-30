import 'package:staki_mobile/bootstrap.dart';
import 'package:staki_mobile/core/constants/app_config.dart';

/// Default entry point (dev). For a specific flavour use main_dev/staging/prod.
Future<void> main() => bootstrap(Flavor.dev);
