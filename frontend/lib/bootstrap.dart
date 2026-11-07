import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staki_mobile/core/constants/app_config.dart';
import 'package:staki_mobile/presentation/shared_providers/preferences_providers.dart';
import 'package:staki_mobile/presentation/staki_app.dart';

/// Shared startup for every flavour. Set the flavour, init Firebase here later,
/// then run the app inside a Riverpod ProviderScope.
Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.set(flavor);

  // TODO(Tolu): initialise Firebase once flavour firebase_options exist.
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const StakiApp(),
    ),
  );
}
