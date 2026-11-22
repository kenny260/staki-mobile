import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/lender/lender_routes.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_models.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_providers.dart';
import 'package:staki_mobile/presentation/features/lender/widgets/lender_widgets.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

class LenderKycPage extends ConsumerWidget {
  const LenderKycPage({super.key});

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    KycFile which,
    ImageSource source,
  ) async {
    try {
      final photo = await ref.read(kycPickerProvider)(which, source);
      if (photo == null || !context.mounted) return;
      ref.read(lenderControllerProvider.notifier).attach(which, photo);
    } on Exception {
      if (!context.mounted) return;
      showLenderMessage(
        context,
        "We couldn't open that. Please check app permissions and try again.",
      );
    }
  }

  Future<void> _pickId(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(AppIcons.camera),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(AppIcons.image),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;
    await _pick(context, ref, KycFile.governmentId, source);
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    KycFile which,
  ) async {
    final ok = await ref.read(lenderControllerProvider.notifier).removeFile(
          which,
        );
    if (!context.mounted) return;
    showLenderMessage(
      context,
      ok ? 'File removed.' : "We couldn't remove it. Please try again.",
    );
  }

  Future<void> _continue(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(lenderControllerProvider.notifier).saveDraft();
    if (!context.mounted) return;
    if (!ok) {
      showLenderMessage(
        context,
        "We couldn't save your documents. Please try again.",
      );
      return;
    }
    unawaited(context.push(LenderRoutes.risk));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(lenderControllerProvider.select((s) => s.draft));

    return LenderScaffold(
      title: 'Identity Verification',
      bottom: AppButton(
        label: 'Continue',
        // Disabled until both files are added.
        onPressed: draft.hasIdentityDocuments
            ? () => unawaited(_continue(context, ref))
            : null,
      ),
      children: [
        const AmberBadge(icon: AppIcons.shieldCheck, color: AppColors.primary),
        const SizedBox(height: 20),
        const LenderHeading('Verify your identity'),
        const SizedBox(height: 6),
        const LenderBody(
          'To comply with financial regulations, we need to verify your '
          'identity.',
        ),
        const SizedBox(height: 20),
        UploadTile(
          icon: AppIcons.bank,
          title: 'Upload Government ID',
          subtitle: 'National ID or Passport',
          fileName: draft.idFileName,
          onTap: () => unawaited(_pickId(context, ref)),
          onRemove: () =>
              unawaited(_remove(context, ref, KycFile.governmentId)),
        ),
        const SizedBox(height: 14),
        UploadTile(
          icon: AppIcons.user,
          title: 'Take a selfie',
          subtitle: 'To match with your ID',
          fileName: draft.selfieFileName,
          onTap: () => unawaited(
            _pick(context, ref, KycFile.selfie, ImageSource.camera),
          ),
          onRemove: () => unawaited(_remove(context, ref, KycFile.selfie)),
        ),
      ],
    );
  }
}
