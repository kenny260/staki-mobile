import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/router/auth_redirect.dart';
import 'package:staki_mobile/domain/entities/app_user.dart';

const _unverified = AppUser(
  uid: 'u1',
  email: 'a@b.com',
  displayName: null,
  emailVerified: false,
  provider: 'password',
);

const _verified = AppUser(
  uid: 'u1',
  email: 'a@b.com',
  displayName: null,
  emailVerified: true,
  provider: 'password',
);

const _signedOut = AsyncValue<AppUser?>.data(null);

void main() {
  var landingCalls = 0;

  Future<String?> run(
    String location,
    AsyncValue<AppUser?> auth, {
    bool landingThrows = false,
  }) {
    return authRedirect(
      location: location,
      auth: auth,
      landing: () async {
        landingCalls++;
        if (landingThrows) throw StateError('offline');
        return AppRoutes.phone;
      },
    );
  }

  setUp(() => landingCalls = 0);

  group('while Firebase restores the session', () {
    test('stays put', () async {
      const loading = AsyncLoading<AppUser?>();

      expect(await run(AppRoutes.splash, loading), isNull);
      expect(await run(AppRoutes.settings, loading), isNull);
    });
  });

  group('signed out', () {
    test('may open public screens', () async {
      for (final route in [
        AppRoutes.splash,
        AppRoutes.welcome,
        AppRoutes.roleSelect,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
        AppRoutes.edgeCases,
      ]) {
        expect(await run(route, _signedOut), isNull, reason: route);
      }
    });

    test('is sent to login from protected screens', () async {
      expect(await run(AppRoutes.settings, _signedOut), AppRoutes.login);
      expect(await run(AppRoutes.phone, _signedOut), AppRoutes.login);
      expect(await run('/marketplace', _signedOut), AppRoutes.login);
    });
  });

  group('signed in, email not verified', () {
    test('is sent to verify email from anywhere else', () async {
      const auth = AsyncValue<AppUser?>.data(_unverified);

      expect(await run(AppRoutes.login, auth), AppRoutes.verifyEmail);
      expect(await run(AppRoutes.settings, auth), AppRoutes.verifyEmail);
    });

    test('stays on verify email', () async {
      const auth = AsyncValue<AppUser?>.data(_unverified);

      expect(await run(AppRoutes.verifyEmail, auth), isNull);
    });
  });

  group('signed in and verified', () {
    const auth = AsyncValue<AppUser?>.data(_verified);

    test('cold start at splash goes to the landing route', () async {
      expect(await run(AppRoutes.splash, auth), AppRoutes.phone);
      expect(landingCalls, 1);
    });

    test('does not look up the account anywhere else', () async {
      expect(await run(AppRoutes.login, auth), isNull);
      expect(await run(AppRoutes.settings, auth), isNull);
      expect(landingCalls, 0);
    });

    test('stays on splash if the landing lookup fails', () async {
      expect(await run(AppRoutes.splash, auth, landingThrows: true), isNull);
    });
  });
}
