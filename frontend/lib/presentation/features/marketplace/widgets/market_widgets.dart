import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/marketplace/market_routes.dart';
import 'package:staki_mobile/presentation/features/marketplace/providers/market_models.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

void showMarketMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

/// Page frame: header, divider, scrolling body and a pinned bottom area.
class MarketScaffold extends StatelessWidget {
  const MarketScaffold({
    required this.title,
    required this.children,
    super.key,
    this.bottom,
    this.trailing,
    this.backTo = MarketRoutes.base,
  });

  const MarketScaffold.loading({
    required this.title,
    super.key,
    this.backTo = MarketRoutes.base,
  })  : children = const [
          SizedBox(height: 160),
          Center(child: CircularProgressIndicator()),
        ],
        bottom = null,
        trailing = null;

  const MarketScaffold.failure({
    required this.title,
    super.key,
    this.backTo = MarketRoutes.base,
  })  : children = const [Text('We could not load this. Please try again.')],
        bottom = null,
        trailing = null;

  final String title;
  final List<Widget> children;
  final Widget? bottom;
  final Widget? trailing;
  final String backTo;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(backTo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: title,
              onBack: () => _back(context),
              trailing: trailing,
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ),
            if (bottom != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}

class MarketHeading extends StatelessWidget {
  const MarketHeading(this.text, {super.key, this.size = 20});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      );
}

class MarketBody extends StatelessWidget {
  const MarketBody(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          height: 1.4,
          color: AppColors.textSecondary,
        ),
      );
}

class SectorLabel extends StatelessWidget {
  const SectorLabel(this.sector, {super.key});

  final String sector;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(AppIcons.buildings, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            sector.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class ScorePill extends StatelessWidget {
  const ScorePill({required this.score, super.key});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(AppIcons.shield, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class FundingBar extends StatelessWidget {
  const FundingBar({required this.fraction, super.key, this.color});

  final double fraction;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: fraction,
        minHeight: 6,
        backgroundColor: AppColors.surfaceAlt,
        color: color ?? AppColors.primary,
      ),
    );
  }
}

/// Small label above a bold value.
class LabelValue extends StatelessWidget {
  const LabelValue(this.label, this.value, {super.key, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: valueColor ?? AppColors.primary,
          ),
        ),
      ],
    );
  }
}

/// Grey rounded tile with a label and a larger value (LE02).
class StatTile extends StatelessWidget {
  const StatTile({
    required this.label,
    required this.value,
    super.key,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class OpportunityCard extends StatelessWidget {
  const OpportunityCard({
    required this.opportunity,
    required this.onTap,
    super.key,
  });

  final Opportunity opportunity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final o = opportunity;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: SectorLabel(o.sector)),
                  ScorePill(score: o.score),
                ],
              ),
              const SizedBox(height: 8),
              MarketHeading(o.title, size: 17),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child:
                        LabelValue('Amount requested', moneyRwf(o.requested)),
                  ),
                  Expanded(
                    child: LabelValue('Term', '${o.termMonths} months'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: LabelValue(
                      'Indicative return',
                      o.rateLabel,
                      valueColor: AppColors.success,
                    ),
                  ),
                  Expanded(child: _Verification(o.verification)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    '${o.fundedPercent}% funded',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    moneyRwf(o.funded),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              FundingBar(fraction: o.fundedFraction),
            ],
          ),
        ),
      ),
    );
  }
}

class _Verification extends StatelessWidget {
  const _Verification(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verification',
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            const Icon(
              AppIcons.checkCircle,
              size: 12,
              color: AppColors.success,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Filter chip with an primary border when selected (LE01b).
class FilterPill extends StatelessWidget {
  const FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Checkbox-style acknowledgement row (LE05).
class AckRow extends StatelessWidget {
  const AckRow({
    required this.checked,
    required this.text,
    required this.onTap,
    super.key,
  });

  final bool checked;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: checked,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: checked ? AppColors.primary : AppColors.background,
                  border: Border.all(
                    color: checked ? AppColors.primary : AppColors.borderMid,
                    width: 1.5,
                  ),
                ),
                child: checked
                    ? const Icon(
                        AppIcons.check,
                        size: 14,
                        color: AppColors.onPrimary,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Label on the left, bold value on the right.
class DetailRow extends StatelessWidget {
  const DetailRow(this.label, this.value, {super.key, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: bold ? 15 : 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon, title, date and a signed amount (ledger and activity history).
class LedgerRow extends StatelessWidget {
  const LedgerRow({required this.entry, super.key});

  final LedgerEntry entry;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (entry.kind) {
      LedgerKind.repayment => (AppIcons.arrowDownLeft, AppColors.success),
      LedgerKind.deposit => (AppIcons.arrowDownLeft, AppColors.info),
      LedgerKind.allocation => (AppIcons.fileText, AppColors.primary),
      LedgerKind.disbursed => (AppIcons.arrowUpRight, AppColors.info),
    };
    final incoming = entry.amount >= 0;
    final note = entry.note;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  dateLabel(entry.date),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                signedRwf(entry.amount),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: incoming && entry.kind == LedgerKind.repayment
                      ? AppColors.success
                      : AppColors.primary,
                ),
              ),
              if (note != null)
                Text(
                  note,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
