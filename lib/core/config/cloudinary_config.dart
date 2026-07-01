/// Cloudinary settings for file uploads (images + PDFs).
///
/// Setup (free tier):
/// 1. Create account at https://cloudinary.com
/// 2. Dashboard → copy **Cloud name**
/// 3. Settings → Upload → Upload presets → Add preset
///    - Signing mode: **Unsigned**
///    - Allowed formats: jpg, png, webp, pdf (recommended)
/// 4. Paste values in [fileCloudName] and [fileUploadPreset] below
///    (or pass `--dart-define=CLOUDINARY_CLOUD_NAME=...` at build time)
class CloudinaryConfig {
  /// Paste your Cloudinary cloud name here.
  static const String fileCloudName = 'k6ca6kfg';

  /// Paste your unsigned upload preset name here.
  static const String fileUploadPreset = 'solarapp1';

  static String get cloudName {
    const fromEnv = String.fromEnvironment('CLOUDINARY_CLOUD_NAME');
    return fromEnv.isNotEmpty ? fromEnv : fileCloudName;
  }

  static String get uploadPreset {
    const fromEnv = String.fromEnvironment('CLOUDINARY_UPLOAD_PRESET');
    return fromEnv.isNotEmpty ? fromEnv : fileUploadPreset;
  }

  static bool get isConfigured =>
      cloudName.isNotEmpty && uploadPreset.isNotEmpty;

  static bool isCloudinaryUrl(String url) =>
      url.contains('res.cloudinary.com');

  /// Parses a Cloudinary delivery URL into [publicId] + [resourceType].
  static ({String publicId, String resourceType})? parseAssetFromUrl(
    String url,
  ) {
    if (!isCloudinaryUrl(url)) return null;

    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final segments = uri.pathSegments;
    if (segments.length < 4) return null;

    final resourceType = segments[1];
    if (resourceType != 'image' &&
        resourceType != 'raw' &&
        resourceType != 'video') {
      return null;
    }

    final uploadIndex = segments.indexOf('upload');
    if (uploadIndex < 0 || uploadIndex + 1 >= segments.length) return null;

    var idSegments = segments.sublist(uploadIndex + 1);

    // Drop version segment (v1234567890).
    if (idSegments.isNotEmpty && RegExp(r'^v\d+$').hasMatch(idSegments.first)) {
      idSegments = idSegments.sublist(1);
    }

    // Drop transformation segments (e.g. w_500,h_500,c_fill).
    while (idSegments.isNotEmpty &&
        idSegments.first.contains('_') &&
        !idSegments.first.contains('.')) {
      idSegments = idSegments.sublist(1);
    }

    if (idSegments.isEmpty) return null;

    final fileSegment = idSegments.last;
    final dotIndex = fileSegment.lastIndexOf('.');
    final fileNameWithoutExt =
        dotIndex > 0 ? fileSegment.substring(0, dotIndex) : fileSegment;

    if (idSegments.length == 1) {
      return (publicId: fileNameWithoutExt, resourceType: resourceType);
    }

    final folder = idSegments.sublist(0, idSegments.length - 1).join('/');
    return (
      publicId: '$folder/$fileNameWithoutExt',
      resourceType: resourceType,
    );
  }
}
