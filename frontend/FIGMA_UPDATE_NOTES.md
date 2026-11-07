# Figma fidelity update + P30 / P31 / P40 + new design-system widgets

Source: Figma "Design System Specs" (JksKsdPrH82niGSvQT3U0K) and
"Mobile Prototype" (xggLWgTvOM5EErLe6kJGDt), read via the Figma connector.

## What changed
- Tokens: core/theme/app_colors.dart, text_styles.dart, constants/spacing.dart (screen padding 20)
- Theme: primary button 52 high / radius 16, white text fields, disabled = surface + border
- Updated widgets: StepScaffold ("n of N" + 40x4 pill, white bottom bar), OptionChips
  (radius 10, selected = SemiBold), OtpInput (48x56, filled = primarySoft), RadioCard, InfoBanner, AppTextField
- New widgets: StepIndicator, AppCheckboxTile, AppSwitch(+Tile), AppTabs, SegmentControl,
  AppBottomNav, ScreenHeader, KeyValueRow
- New screens: P30_SalaryEmployment, P31_SalaryIncome, P40_OtherInfo (+ review rows)
- Flow fixes from the Figma links: student is 4 steps and P21 -> P05_Review;
  salaried 4 steps; other 3 steps. P05_Review -> O01_Consent.
- Tests: salaried/other flow, new widgets, golden test (skipped until generated)

## Golden image
    flutter test --update-goldens test/golden
Commit test/golden/goldens/design_system_widgets.png. Generate it on the CI OS (Linux).

## Not done (found in Figma, not yet built)
- A07_CreatePIN, A07b_ConfirmPIN, A08_Biometric, A09_AccountCreated: in Figma, A06_OTP -> A07,
  and the account flow ends at A09 before profile setup. Our app currently goes OTP -> P01.
- ScoreGauge / progress ring: Chris already has one in credit_passport; move it to shared_widgets
  when convenient instead of writing a second one.

## Added in the second pass
- A07_CreatePIN, A07b_ConfirmPIN (4-digit PIN, mismatch error), A08_Biometric, A09_AccountCreated.
  Flow is now A06 OTP -> A07 -> A07b -> A08 -> A09 -> P01 (or lender onboarding).
  PIN storage and biometrics are TODO(Tolu) (flutter_secure_storage, local_auth).
- Edge Case Library: StateScreen + EdgeCaseType (E01-E34). Gallery at /dev/edge-cases.
- Section 10: S01_Settings, S02_DataPermissions, S03_Privacy, S04_Support.
  S01 has one row NOT in Figma: Language (saved in SharedPreferences) for the rubric demo.
  Name/phone and data-permission flags are placeholders until Uche's profile + consent ledger land.
