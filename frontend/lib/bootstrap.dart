import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staki_mobile/core/constants/app_config.dart';
import 'package:staki_mobile/data/datasources/messaging_datasource.dart';
import 'package:staki_mobile/firebase_options.dart';
import 'package:staki_mobile/presentation/shared_providers/preferences_providers.dart';
import 'package:staki_mobile/presentation/staki_app.dart';

/// Shared startup for every flavour. Set the flavour, init Firebase,
/// then run the app inside a Riverpod ProviderScope.
Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.set(flavor);

  // All flavours share the staki-bc71f project for now. Generate the options
  // locally with `flutterfire configure` (the file is gitignored).
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const StakiApp(),
    ),
  );
}
