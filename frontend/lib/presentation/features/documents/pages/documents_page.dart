import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_models.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_providers.dart';
import 'package:staki_mobile/presentation/features/documents/widgets/document_card.dart';
import 'package:staki_mobile/presentation/features/documents/widgets/upload_sheet.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

class DocumentsPage extends ConsumerWidget {
  const DocumentsPage({super.key});

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.splash);
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _startUpload(
    BuildContext context,
    WidgetRef ref,
    DocumentItem item,
  ) async {
    final source = await showUploadSheet(context);
    if (source == null || !context.mounted) return;
    try {
      final file = await ref.read(documentPickerProvider)(source);
      if (file == null || !context.mounted) return;
      ref.read(pendingUploadProvider.notifier).state = PendingUpload(
        item: item,
        file: file,
      );
      unawaited(context.push('${AppRoutes.documents}/preview'));
    } on Exception {
      if (!context.mounted) return;
      _showMessage(
        context,
        "We couldn't open that. Please check app permissions and try again.",
      );
    }
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    DocumentItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove document?'),
        content: Text(
          '${item.title} will be removed. You can upload it again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(documentsControllerProvider.notifier).remove(item.id);
      if (!context.mounted) return;
      _showMessage(context, 'Document removed.');
    } on Exception {
      if (!context.mounted) return;
      _showMessage(context, "We couldn't remove it. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documents = ref.watch(documentsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'My Documents',
              onBack: () => _back(context),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: documents.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(
                  child: Text('Could not load your documents. Please retry.'),
                ),
                data: (items) => ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Text(
                      'Please provide the following documents to complete '
                      'your Credit Passport profile. Clear, readable photos '
                      'speed up the verification process.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (final item in items)
                      DocumentCard(
                        item: item,
                        onUpload: () =>
                            unawaited(_startUpload(context, ref, item)),
                        onRemove: () =>
                            unawaited(_confirmRemove(context, ref, item)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
