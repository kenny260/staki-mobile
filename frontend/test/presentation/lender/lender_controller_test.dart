import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_models.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_providers.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_repository.dart';

ProviderContainer _container(MockLenderRepository repository) {
  final container = ProviderContainer(
    overrides: [lenderRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return container;
}

MockLenderRepository _repository({bool failSubmit = false}) =>
    MockLenderRepository(delay: Duration.zero, failSubmit: failSubmit);

const _photo = KycPhoto(name: 'doc.jpg', path: '/tmp/doc.jpg');

void main() {
  test('verifyOtp accepts the right code and rejects a wrong one', () async {
    final container = _container(_repository());
    final controller = container.read(lenderControllerProvider.notifier);
    await controller.sendOtp('788555210');

    expect(await controller.verifyOtp('000000'), isFalse);
    expect(container.read(lenderControllerProvider).otpVerified, isFalse);

    expect(await controller.verifyOtp(MockLenderRepository.validCode), isTrue);
    expect(container.read(lenderControllerProvider).otpVerified, isTrue);
  });

  test('createPin needs exactly four digits', () async {
    final container = _container(_repository());
    final controller = container.read(lenderControllerProvider.notifier);

    expect(await controller.createPin('12'), isFalse);
    expect(container.read(lenderControllerProvider).pinSet, isFalse);

    expect(await controller.createPin('1234'), isTrue);
    expect(container.read(lenderControllerProvider).pinSet, isTrue);
  });

  test('a saved draft is read back by a fresh session', () async {
    final repository = _repository();
    final first = _container(repository);
    final controller = first.read(lenderControllerProvider.notifier);
    await controller.sendOtp('788555210');
    controller.chooseType(InvestorType.diaspora);
    expect(await controller.saveDraft(), isTrue);

    final second = _container(repository);
    await second.read(lenderControllerProvider.notifier).start();
    final draft = second.read(lenderControllerProvider).draft;
    expect(draft.phone, '788555210');
    expect(draft.profileType, InvestorType.diaspora);
  });

  test('a KYC file can be attached and then removed', () async {
    final container = _container(_repository());
    final controller = container.read(lenderControllerProvider.notifier)
      ..attach(KycFile.governmentId, _photo);
    expect(
      container.read(lenderControllerProvider).draft.idFileName,
      'doc.jpg',
    );

    expect(await controller.removeFile(KycFile.governmentId), isTrue);
    expect(container.read(lenderControllerProvider).draft.idFileName, isNull);
  });

  test('submit fails while the registration is incomplete', () async {
    final container = _container(_repository());
    final profile =
        await container.read(lenderControllerProvider.notifier).submit();
    expect(profile, isNull);
  });

  test('submit creates the profile once every step is done', () async {
    final container = _container(_repository());
    final controller = container.read(lenderControllerProvider.notifier)
      ..chooseType(InvestorType.individual)
      ..attach(KycFile.governmentId, _photo)
      ..attach(KycFile.selfie, _photo)
      ..toggleRisk()
      ..toggleStructure();
    await controller.sendOtp('788555210');

    final profile = await controller.submit();
    expect(profile, isNotNull);
    expect(profile!.type, InvestorType.individual);
    expect(container.read(lenderControllerProvider).profile, isNotNull);
  });

  test('a failing backend makes submit return null', () async {
    final container = _container(_repository(failSubmit: true));
    final controller = container.read(lenderControllerProvider.notifier)
      ..chooseType(InvestorType.individual)
      ..attach(KycFile.governmentId, _photo)
      ..attach(KycFile.selfie, _photo)
      ..toggleRisk()
      ..toggleStructure();
    await controller.sendOtp('788555210');

    expect(await controller.submit(), isNull);
  });
}
