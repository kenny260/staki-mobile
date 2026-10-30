/// Build flavours: dev, staging, prod.
///
/// Each entry point (main_dev.dart, main_staging.dart, main_prod.dart) sets
/// the flavour, so the app knows which Firebase project and config to use.
enum Flavor { dev, staging, prod }

class AppConfig {
  AppConfig._({required this.flavor, required this.appName});

  final Flavor flavor;
  final String appName;

  static late AppConfig _instance;
  static AppConfig get instance => _instance;

  static void set(Flavor flavor) {
    _instance = AppConfig._(
      flavor: flavor,
      appName: switch (flavor) {
        Flavor.dev => 'Staki Fund (Dev)',
        Flavor.staging => 'Staki Fund (Staging)',
        Flavor.prod => 'Staki Fund',
      },
    );
  }

  bool get isProd => flavor == Flavor.prod;
}
