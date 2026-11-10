import 'package:flutter/material.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_models.dart';

/// D02_UploadSheet. Returns the chosen source, or null if dismissed.
Future<UploadSource?> showUploadSheet(BuildContext context) {
  return showModalBottomSheet<UploadSource>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _UploadSheet(),
  );
}

class _UploadSheet extends StatelessWidget {
  const _UploadSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Upload document',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close, color: AppColors.primary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                _Option(
                  icon: Icons.document_scanner_outlined,
                  label: 'Scan document',
                  source: UploadSource.scan,
                ),
                SizedBox(width: 12),
                _Option(
                  icon: Icons.photo_camera,
                  label: 'Take a photo',
                  source: UploadSource.camera,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                _Option(
                  icon: Icons.folder_open,
                  label: 'Choose from files',
                  source: UploadSource.files,
                ),
                SizedBox(width: 12),
                _Option(
                  icon: Icons.image_outlined,
                  label: 'Choose photo',
                  source: UploadSource.gallery,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.label,
    required this.source,
  });

  final IconData icon;
  final String label;
  final UploadSource source;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).pop(source),
        child: Ink(
          height: 92,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
