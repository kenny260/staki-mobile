import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:staki_mobile/core/constants/cloudinary_config.dart';

/// What Cloudinary returns after a successful upload.
class CloudinaryUpload {
  const CloudinaryUpload({
    required this.url,
    required this.publicId,
    required this.resourceType,
    required this.bytes,
  });

  /// HTTPS link to the file. Save this in Firestore.
  final String url;
  final String publicId;
  final String resourceType;
  final int bytes;
}

class CloudinaryException implements Exception {
  const CloudinaryException(this.message);

  final String message;

  @override
  String toString() => 'CloudinaryException: $message';
}

/// Uploads files straight from the device to Cloudinary with the unsigned
/// preset. Deleting files needs the API secret, so that must happen on a
/// server (Cloud Function) later, never in the app.
class CloudinaryDataSource {
  CloudinaryDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  /// Uploads the file at [filePath] into `staki/<folder>`.
  Future<CloudinaryUpload> uploadFile({
    required String filePath,
    required String folder,
  }) async {
    final request = http.MultipartRequest('POST', CloudinaryConfig.uploadUri)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..fields['folder'] = '${CloudinaryConfig.rootFolder}/$folder'
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final http.Response response;
    try {
      response = await http.Response.fromStream(await _client.send(request));
    } on Exception {
      throw const CloudinaryException(
        'No connection. Check your internet and try again.',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      final error = body['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String?;
      throw CloudinaryException(
        message ?? 'Upload failed (${response.statusCode}).',
      );
    }

    return CloudinaryUpload(
      url: body['secure_url'] as String,
      publicId: body['public_id'] as String,
      resourceType: body['resource_type'] as String,
      bytes: body['bytes'] as int,
    );
  }
}
