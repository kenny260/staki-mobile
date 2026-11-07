import 'package:flutter/material.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// Developer gallery: open any of the 34 edge-case states, to compare them
/// with the Figma Edge Case Library. Route: /dev/edge-cases
class EdgeCaseGalleryPage extends StatelessWidget {
  const EdgeCaseGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edge Case Library (E01–E34)')),
      body: ListView.separated(
        itemCount: EdgeCaseType.values.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final type = EdgeCaseType.values[i];
          final c = type.content;
          return ListTile(
            leading: Icon(c.icon, color: AppColors.primary),
            title: Text('${c.code}  ${c.title}', style: AppTextStyles.label),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => StateScreen(type: type)),
            ),
          );
        },
      ),
    );
  }
}
