import 'package:image_picker/image_picker.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_models.dart';

/// Picks a KYC photo. Returns null if the user cancels.
typedef KycPicker = Future<KycPhoto?> Function(
  KycFile which,
  ImageSource source,
);

final ImagePicker _images = ImagePicker();

/// Real picker: camera or gallery. The selfie opens the front camera.
Future<KycPhoto?> pickKycPhoto(KycFile which, ImageSource source) async {
  final file = await _images.pickImage(
    source: source,
    imageQuality: 85,
    preferredCameraDevice:
        which == KycFile.selfie ? CameraDevice.front : CameraDevice.rear,
  );
  if (file == null) return null;
  return KycPhoto(name: file.name, path: file.path);
}
