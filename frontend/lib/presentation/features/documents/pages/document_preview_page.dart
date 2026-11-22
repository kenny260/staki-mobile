import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_models.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_providers.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

class DocumentPreviewPage extends ConsumerWidget {
  const DocumentPreviewPage({super.key});

  bool _isImage(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png');
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.documents);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingUploadProvider);

    if (pending == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              ScreenHeader(title: 'Preview', onBack: () => _back(context)),
              const Expanded(
                child: Center(child: Text('No document selected.')),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: 'Preview', onBack: () => _back(context)),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pending.item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PreviewCard(
                      file: pending.file,
                      isImage: _isImage(pending.file.path),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pending.file.name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _QualityCheck(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(pendingUploadProvider.notifier).state = null;
                        context.pop();
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: const StadiumBorder(),
                        side: const BorderSide(color: AppColors.border),
                        foregroundColor: AppColors.primary,
                      ),
                      child: const Text(
                        'Retake',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Upload',
                      onPressed: () {
                        final notifier = ref.read(
                          documentsControllerProvider.notifier,
                        );
                        // Runs in the background; the list shows "Uploading".
                        unawaited(
                          notifier.upload(pending.item.id, pending.file),
                        );
                        ref.read(pendingUploadProvider.notifier).state = null;
                        context.go(AppRoutes.documents);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.file, required this.isImage});

  final PickedDocument file;
  final bool isImage;

  Widget _fallback() {
    return const Center(
      child: Icon(
        AppIcons.file,
        size: 56,
        color: AppColors.textMuted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: isImage
            ? Image.file(
                File(file.path),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }
}

/// Placeholder checks. Real quality checks would come from the backend.
class _QualityCheck extends StatelessWidget {
  const _QualityCheck();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quality check',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 10),
          _CheckRow('Edges detected'),
          _CheckRow('Good lighting'),
          _CheckRow('Text is readable'),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Icon(AppIcons.check, size: 16, color: AppColors.success),
        ],
      ),
    );
  }
}
