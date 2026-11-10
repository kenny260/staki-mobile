import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staki_mobile/presentation/features/documents/providers/document_models.dart';

/// Picks a document from the given source. Returns null if the user cancels.
typedef DocumentPicker = Future<PickedDocument?> Function(UploadSource source);

final ImagePicker _images = ImagePicker();

/// Real picker: camera, gallery and files on the device.
Future<PickedDocument?> pickFromDevice(UploadSource source) async {
  switch (source) {
    case UploadSource.scan:
    case UploadSource.camera:
      return _fromImage(
        await _images.pickImage(source: ImageSource.camera, imageQuality: 85),
      );
    case UploadSource.gallery:
      return _fromImage(
        await _images.pickImage(source: ImageSource.gallery, imageQuality: 85),
      );
    case UploadSource.files:
      return _fromFiles();
  }
}

PickedDocument? _fromImage(XFile? file) {
  if (file == null) return null;
  return PickedDocument(name: file.name, path: file.path);
}

Future<PickedDocument?> _fromFiles() async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
  );
  if (result.isEmpty) return null;
  final file = result.first;
  final path = file.path;
  if (path == null) return null;
  return PickedDocument(name: file.name, path: path);
}
