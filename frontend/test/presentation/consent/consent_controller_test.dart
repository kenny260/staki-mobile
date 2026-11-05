import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/consent/providers/consent_models.dart';
import 'package:staki_mobile/presentation/features/consent/providers/consent_providers.dart';
import 'package:staki_mobile/presentation/features/consent/providers/consent_repository.dart';

ProviderContainer _container(MomoOutcome outcome) {
  final container = ProviderContainer(
    overrides: [
      consentRepositoryProvider.overrideWithValue(
        MockConsentRepository(outcome: outcome, delay: Duration.zero),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('starts with nothing agreed or connected', () {
    final state = _container(MomoOutcome.eligible).read(
      consentControllerProvider,
    );
    expect(state.termsRead, isFalse);
    expect(state.consent, isNull);
    expect(state.status, ConnectionStatus.idle);
  });

  test('markTermsRead enables the agree button state', () {
    final container = _container(MomoOutcome.eligible);
    container.read(consentControllerProvider.notifier).markTermsRead();
    expect(container.read(consentControllerProvider).termsRead, isTrue);
  });

  test('agreeAndGrantConsent creates a granted, timestamped consent', () async {
    final container = _container(MomoOutcome.eligible);
    await container
        .read(consentControllerProvider.notifier)
        .agreeAndGrantConsent();
    final consent = container.read(consentControllerProvider).consent;
    expect(consent, isNotNull);
    expect(consent!.granted, isTrue);
    expect(consent.type, momoConsentType);
  });

  test('loadConsent reads back a saved consent', () async {
    final container = _container(MomoOutcome.eligible);
    final notifier = container.read(consentControllerProvider.notifier);
    await notifier.agreeAndGrantConsent();
    await notifier.loadConsent();
    expect(container.read(consentControllerProvider).consent, isNotNull);
  });

  test('revokeConsent marks it revoked and clears the connection', () async {
    final container = _container(MomoOutcome.eligible);
    final notifier = container.read(consentControllerProvider.notifier);
    await notifier.agreeAndGrantConsent();
    await notifier.connect();
    await notifier.revokeConsent();
    final state = container.read(consentControllerProvider);
    expect(state.consent!.granted, isFalse);
    expect(state.consent!.revokedAt, isNotNull);
    expect(state.status, ConnectionStatus.idle);
  });

  test('connect succeeds and the account is eligible', () async {
    final container = _container(MomoOutcome.eligible);
    await container.read(consentControllerProvider.notifier).connect();
    final state = container.read(consentControllerProvider);
    expect(state.status, ConnectionStatus.connected);
    expect(state.eligible, isTrue);
    expect(state.account!.maskedNumber, '078 ••• ••67');
  });

  test('connect succeeds but the account is not eligible', () async {
    final container = _container(MomoOutcome.notEligible);
    await container.read(consentControllerProvider.notifier).connect();
    final state = container.read(consentControllerProvider);
    expect(state.status, ConnectionStatus.connected);
    expect(state.eligible, isFalse);
  });

  test('connect failure sets the failed status', () async {
    final container = _container(MomoOutcome.connectionError);
    await container.read(consentControllerProvider.notifier).connect();
    expect(
      container.read(consentControllerProvider).status,
      ConnectionStatus.failed,
    );
  });
}
