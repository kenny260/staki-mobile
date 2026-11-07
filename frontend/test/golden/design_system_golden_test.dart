import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/core/theme/app_theme.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// Golden test for the design-system widgets.
///
/// First run (creates the image):  flutter test --update-goldens test/golden
/// Later runs compare against it:  flutter test
///
/// Until the golden image exists this test is skipped, so CI stays green.
/// Generate the image on the SAME OS as CI (Linux), or font rendering
/// differs and the comparison fails.
const _goldenPath = 'goldens/design_system_widgets.png';
const _goldenOnDisk = 'test/golden/$_goldenPath';

void main() {
  final shouldSkip =
      !autoUpdateGoldenFiles && !File(_goldenOnDisk).existsSync();

  testWidgets(
    'design system widgets match the golden',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StepIndicator(step: 2, totalSteps: 4),
                  const SizedBox(height: 16),
                  const AppButton(label: 'Continue', onPressed: null),
                  const SizedBox(height: 8),
                  AppButton(label: 'Continue', onPressed: () {}),
                  const SizedBox(height: 16),
                  const AppTextField(
                    label: 'Employer name',
                    hint: 'e.g. Bank of Kigali',
                  ),
                  const SizedBox(height: 16),
                  OptionChips(
                    label: 'Employment type',
                    options: const ['Full-time permanent', 'Part-time'],
                    selected: 'Part-time',
                    onSelected: (_) {},
                  ),
                  const SizedBox(height: 16),
                  AppCheckboxTile(
                    label: 'I consent',
                    value: true,
                    onChanged: (_) {},
                  ),
                  AppSwitchTile(
                    title: 'Email notifications',
                    value: true,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 8),
                  SegmentControl(
                    labels: const ['Borrower', 'Lender'],
                    selectedIndex: 0,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 16),
                  const InfoBanner(
                    message: 'Revenue figures are never shown to lenders.',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(_goldenPath),
      );
    },
    skip: shouldSkip,
  );
}
