import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/presentation/features/consent/providers/consent_models.dart';
import 'package:staki_mobile/presentation/features/consent/providers/consent_providers.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/consent_app_bar.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/consent_layout.dart';
import 'package:staki_mobile/presentation/features/consent/widgets/momo_logo.dart';

class MomoConnectingPage extends ConsumerStatefulWidget {
  const MomoConnectingPage({super.key});

  @override
  ConsumerState<MomoConnectingPage> createState() => _MomoConnectingPageState();
}

class _MomoConnectingPageState extends ConsumerState<MomoConnectingPage> {
  @override
  void initState() {
    super.initState();
    final controller = ref.read(consentControllerProvider.notifier);
    unawaited(Future<void>.microtask(controller.connect));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(consentControllerProvider.select((s) => s.status), (_, next) {
      if (!mounted) return;
      switch (next) {
        case ConnectionStatus.connected:
          context.pushReplacement('/consent/momo/connected');
        case ConnectionStatus.failed:
          context.pushReplacement('/consent/momo/error');
        case ConnectionStatus.idle:
        case ConnectionStatus.connecting:
          break;
      }
    });

    return const Scaffold(
      backgroundColor: AppColors.surface,
      appBar: ConsentAppBar(title: 'MTN MoMo'),
      body: ConsentLayout(
        centered: true,
        children: [
          _ConnectingLogo(),
          SizedBox(height: 28),
          ConsentHeading('Connecting securely', center: true),
          SizedBox(height: 10),
          ConsentBody(
            'Establishing a read-only connection with MTN Mobile '
            'Money...',
            center: true,
          ),
        ],
      ),
    );
  }
}

class _ConnectingLogo extends StatelessWidget {
  const _ConnectingLogo();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          MomoLogo(size: 80),
          Positioned(
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(5),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
