import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/domain/entities/borrower_type.dart';
import 'package:staki_mobile/presentation/features/profile/profile_options.dart';
import 'package:staki_mobile/presentation/features/profile/providers/profile_setup_provider.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// P05_Review (shared by the business and startup flows).
class P05ReviewPage extends ConsumerWidget {
  const P05ReviewPage({super.key});

  List<ReviewItem> _items(ProfileSetupState s) {
    String v(String k) => s.value(k);
    return switch (s.type) {
      BorrowerType.startup => [
          ReviewItem('Startup / company name', v(ProfileFields.startupName)),
          ReviewItem('Stage', v(ProfileFields.startupStage)),
          ReviewItem('Activity', v(ProfileFields.startupActivity)),
          ReviewItem('Operating', v(ProfileFields.operatingHistory)),
          ReviewItem('Monthly revenue', v(ProfileFields.startupRevenue)),
        ],
      BorrowerType.student => [
          ReviewItem('Institution', v(ProfileFields.institution)),
          ReviewItem('Study level', v(ProfileFields.studyLevel)),
          ReviewItem('Enrollment', v(ProfileFields.enrollment)),
          ReviewItem('Support', v(ProfileFields.incomeSource)),
          ReviewItem('Monthly income', v(ProfileFields.studentIncome)),
        ],
      BorrowerType.salaried => [
          ReviewItem('Employment type', v(ProfileFields.employmentType)),
          ReviewItem('Employer', v(ProfileFields.employerName)),
          ReviewItem('Monthly income', v(ProfileFields.salaryRange)),
          ReviewItem('Time with employer', v(ProfileFields.tenure)),
        ],
      BorrowerType.other => [
          ReviewItem('Occupation', v(ProfileFields.occupation)),
          ReviewItem('Monthly income', v(ProfileFields.otherIncome)),
        ],
      _ => [
          ReviewItem('Business name', v(ProfileFields.businessName)),
          ReviewItem('Business type', v(ProfileFields.businessType)),
          ReviewItem('Years operating', v(ProfileFields.yearsOperating)),
          ReviewItem('Monthly revenue', v(ProfileFields.monthlyRevenue)),
          ReviewItem('Location', v(ProfileFields.location)),
        ],
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(profileSetupProvider);
    final total = ProfileOptions.totalSteps(s.type);

    return StepScaffold(
      step: total,
      totalSteps: total,
      heading: 'Review your profile',
      subheading: 'Check everything looks right before continuing.',
      ctaLabel: 'Confirm & continue',
      onCta: () {
        // TODO(Uche): persist via ProfileRepository (Firestore) here.
        context.go(AppRoutes.consent);
      },
      children: [
        ReviewCard(
          roleLabel: s.type == null ? '-' : ProfileOptions.title(s.type!),
          items: _items(s),
        ),
      ],
    );
  }
}
