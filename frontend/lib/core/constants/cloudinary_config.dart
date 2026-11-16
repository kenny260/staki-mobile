/// Cloudinary settings for file uploads (images and documents).
///
/// Uploads use an unsigned preset, so no API secret lives in the app.
/// Never add the Cloudinary API secret here.
abstract final class CloudinaryConfig {
  static const String cloudName = 'ybzufhwg';
  static const String uploadPreset = 'staki_mobile';

  /// Root folder for everything the app uploads.
  static const String rootFolder = 'staki';

  /// `auto` lets Cloudinary accept images and PDFs on one endpoint.
  static Uri get uploadUri =>
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/auto/upload');
}
