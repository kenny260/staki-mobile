import 'package:flutter/material.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_models.dart';
import 'package:staki_mobile/presentation/features/documents/widgets/status_chip.dart';

class DocumentCard extends StatelessWidget {
  const DocumentCard({
    required this.item,
    required this.onUpload,
    required this.onRemove,
    super.key,
  });

  final DocumentItem item;
  final VoidCallback onUpload;
  final VoidCallback onRemove;

  String get _requirementLabel => switch (item.requirement) {
        DocumentRequirement.mandatory => 'REQUIRED',
        DocumentRequirement.recommended => 'RECOMMENDED',
        DocumentRequirement.optional => 'OPTIONAL',
      };

  Color get _badgeColor => switch (item.status) {
        DocumentStatus.verified => AppColors.success,
        DocumentStatus.needsAttention => AppColors.warning,
        DocumentStatus.notUploaded => AppColors.primary,
        DocumentStatus.uploading => AppColors.primary,
        DocumentStatus.underReview => AppColors.primary,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.status == DocumentStatus.needsAttention
            ? AppColors.surface
            : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _badgeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(AppIcons.fileText, size: 20, color: _badgeColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _requirementLabel,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              StatusChip(status: item.status),
              const Spacer(),
              if (item.canRemove)
                TextButton(
                  onPressed: onRemove,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.danger,
                  ),
                  child: const Text('Remove'),
                ),
              if (item.canUpload)
                TextButton(
                  onPressed: onUpload,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Upload'),
                ),
            ],
          ),
          if (item.note != null) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.note!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.danger,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
