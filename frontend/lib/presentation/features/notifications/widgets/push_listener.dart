import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/domain/entities/push_message.dart';
import 'package:staki_mobile/presentation/features/notifications/providers/push_providers.dart';

/// Wrap the app with this so a push that arrives while the app is open is
/// shown as a snack bar (Android does not show those on its own).
class PushListener extends ConsumerWidget {
  const PushListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<PushMessage>>(foregroundPushProvider, (_, next) {
      final message = next.valueOrNull;
      if (message == null) return;
      final text = [message.title, message.body].whereType<String>().join(': ');
      if (text.isEmpty) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text)),
      );
    });
    return child;
  }
}
