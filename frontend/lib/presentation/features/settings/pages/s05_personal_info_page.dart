import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/core/utils/validators.dart';
import 'package:staki_mobile/presentation/features/profile/providers/account_providers.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// S05_PersonalInfo: view and edit name and phone. Email and account type
/// are shown but cannot be changed here.
class S05PersonalInfoPage extends ConsumerWidget {
  const S05PersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Personal information',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: account.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(
                  child: Text('We could not load your details. Try again.'),
                ),
                data: (a) => a == null
                    ? const SizedBox.shrink()
                    : _PersonalInfoForm(key: ValueKey(a.uid), account: a),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonalInfoForm extends ConsumerStatefulWidget {
  const _PersonalInfoForm({required this.account, super.key});

  final AccountProfile account;

  @override
  ConsumerState<_PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends ConsumerState<_PersonalInfoForm> {
  late String _name = widget.account.displayName ?? '';
  late String _phone = widget.account.phone ?? '';
  String? _nameError;
  String? _phoneError;
  bool _saving = false;

  bool get _changed =>
      _name.trim() != (widget.account.displayName ?? '').trim() ||
      Validators.normalizeRwandaPhone(_phone) !=
          Validators.normalizeRwandaPhone(widget.account.phone ?? '');

  Future<void> _save() async {
    setState(() {
      _nameError = _name.trim().length < 2 ? 'Enter your full name' : null;
      _phoneError = Validators.isValidRwandaPhone(_phone)
          ? null
          : 'Enter a valid Rwandan number, e.g. 078 800 0111';
    });
    if (_nameError != null || _phoneError != null) return;

    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(saveAccountDetailsProvider)(
        displayName: _name,
        phone: _phone,
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Your details were saved.')),
      );
      if (mounted) Navigator.of(context).maybePop();
    } on Object {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('We could not save your details. Try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.account;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              AppTextField(
                label: 'Full name',
                initialValue: _name,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                errorText: _nameError,
                onChanged: (v) => setState(() {
                  _name = v;
                  _nameError = null;
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Phone number',
                initialValue: _phone.isEmpty
                    ? ''
                    : '0${Validators.normalizeRwandaPhone(_phone)}',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 10,
                autofillHints: const [AutofillHints.telephoneNumber],
                errorText: _phoneError,
                onChanged: (v) => setState(() {
                  _phone = v;
                  _phoneError = null;
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ReadOnlyRow(label: 'Email', value: a.email ?? '-'),
              _ReadOnlyRow(
                label: 'Account type',
                value: a.isLender ? 'Lender' : 'Borrower',
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your email is your login, and your account type is fixed '
                'once chosen.',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.sm,
            AppSpacing.screenPadding,
            AppSpacing.md,
          ),
          child: AppButton(
            label: 'Save changes',
            isLoading: _saving,
            onPressed: _changed && !_saving ? _save : null,
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
          ),
          Text(
            value,
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
