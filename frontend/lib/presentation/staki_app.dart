import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/core/constants/app_config.dart';
import 'package:staki_mobile/core/router/app_router.dart';
import 'package:staki_mobile/core/theme/app_theme.dart';
import 'package:staki_mobile/presentation/shared_providers/preferences_providers.dart';

/// The root widget, shared by all three flavours.
class StakiApp extends ConsumerWidget {
  const StakiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppConfig.instance.appName,
      debugShowCheckedModeBanner: !AppConfig.instance.isProd,
      theme: AppTheme.light,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
