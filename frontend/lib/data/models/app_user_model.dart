import 'package:firebase_auth/firebase_auth.dart';
import 'package:staki_mobile/domain/entities/app_user.dart';

class AppUserModel {
  static AppUser fromFirebase(User u) => AppUser(
        uid: u.uid,
        email: u.email,
        displayName: u.displayName,
        emailVerified: u.emailVerified,
        provider: u.providerData.isNotEmpty
            ? u.providerData.first.providerId
            : 'password',
      );
}
