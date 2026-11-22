import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_models.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_providers.dart';
import 'package:staki_mobile/presentation/features/marketplace/widgets/market_widgets.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

Future<void> showFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _FilterSheet(),
  );
}

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late final ValueNotifier<OpportunityFilter> _draft;

  @override
  void initState() {
    super.initState();
    _draft = ValueNotifier<OpportunityFilter>(
      ref.read(opportunityFilterProvider),
    );
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  void _apply() {
    ref.read(opportunityFilterProvider.notifier).state = _draft.value;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ValueListenableBuilder<OpportunityFilter>(
          valueListenable: _draft,
          builder: (context, filter, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: MarketHeading('Filter Opportunities', size: 17),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(AppIcons.x, color: AppColors.primary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _GroupTitle('Amount Requested'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final v in AmountFilter.values)
                    FilterPill(
                      label: v.label,
                      selected: filter.amount == v,
                      onTap: () => _draft.value = filter.toggleAmount(v),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const _GroupTitle('Term Length'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final v in TermFilter.values)
                    FilterPill(
                      label: v.label,
                      selected: filter.term == v,
                      onTap: () => _draft.value = filter.toggleTerm(v),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const _GroupTitle('Risk / Score Range'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final v in RiskFilter.values)
                    FilterPill(
                      label: v.label,
                      selected: filter.risk == v,
                      onTap: () => _draft.value = filter.toggleRisk(v),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              AppButton(label: 'Apply Filters', onPressed: _apply),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
