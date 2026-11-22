import 'package:flutter/material.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_models.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, super.key});

  final DocumentStatus status;

  String get _label => switch (status) {
        DocumentStatus.notUploaded => 'Not uploaded',
        DocumentStatus.uploading => 'Uploading',
        DocumentStatus.underReview => 'Under review',
        DocumentStatus.verified => 'Verified',
        DocumentStatus.needsAttention => 'Needs attention',
      };

  Color get _color => switch (status) {
        DocumentStatus.notUploaded => AppColors.textSecondary,
        DocumentStatus.uploading => AppColors.info,
        DocumentStatus.underReview => AppColors.info,
        DocumentStatus.verified => AppColors.success,
        DocumentStatus.needsAttention => AppColors.warning,
      };

  Widget _leading() {
    switch (status) {
      case DocumentStatus.uploading:
        return SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(strokeWidth: 1.5, color: _color),
        );
      case DocumentStatus.verified:
        return Icon(AppIcons.checkCircle, size: 12, color: _color);
      case DocumentStatus.notUploaded:
        return const SizedBox.shrink();
      case DocumentStatus.underReview:
      case DocumentStatus.needsAttention:
        return Icon(AppIcons.circle, size: 7, color: _color);
    }
  }

  @override
  Widget build(BuildContext context) {
    final background = status == DocumentStatus.notUploaded
        ? AppColors.surfaceAlt
        : _color.withValues(alpha: 0.12);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _leading(),
          if (status != DocumentStatus.notUploaded) const SizedBox(width: 6),
          Text(
            _label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
