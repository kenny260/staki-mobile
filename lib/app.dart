import 'package:flutter/material.dart';
import 'package:staki_mobile/core/constants/app_config.dart';
import 'package:staki_mobile/core/router/app_router.dart';
import 'package:staki_mobile/core/theme/app_theme.dart';

/// The root widget. Shared by all three flavours.
class StakiApp extends StatelessWidget {
  const StakiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.instance.appName,
      debugShowCheckedModeBanner: !AppConfig.instance.isProd,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
