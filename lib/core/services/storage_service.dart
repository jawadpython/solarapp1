import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:noor_energy/core/config/cloudinary_config.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery
  Future<List<XFile>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      return images;
    } catch (e) {
      debugPrint('Error picking images: $e');
      return [];
    }
  }

  /// Pick multiple documents/images (pdf, jpg, jpeg, png, webp)
  Future<List<PlatformFile>> pickPartnerDocuments() async {
    try {
      final result = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
        withData: kIsWeb,
      );
      return result?.files ?? [];
    } catch (e) {
      debugPrint('Error picking partner documents: $e');
      return [];
    }
  }

  /// Upload image to Cloudinary.
  /// Returns the secure URL on success, null on failure.
  Future<String?> uploadImage({
    required XFile file,
    required String path,
    bool overwrite = false,
    void Function(double)? onProgress,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      return uploadImageBytes(
        bytes: bytes,
        path: path,
        fileName: file.name,
        contentType: 'image/${_getExtension(file.name)}',
        overwrite: overwrite,
        onProgress: onProgress,
      );
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  /// Upload image bytes (web + mobile).
  Future<String?> uploadImageBytes({
    required Uint8List bytes,
    required String path,
    String fileName = 'upload.jpg',
    String contentType = 'image/jpeg',
    bool overwrite = false,
    void Function(double)? onProgress,
  }) async {
    return _uploadToCloudinary(
      bytes: bytes,
      path: path,
      fileName: fileName,
      resourceType: 'image',
      overwrite: overwrite,
      onProgress: onProgress,
    );
  }

  /// Upload file selected with file_picker (images or PDF).
  Future<String?> uploadPlatformFile({
    required PlatformFile file,
    required String path,
    void Function(double)? onProgress,
  }) async {
    try {
      late final Uint8List bytes;
      if (kIsWeb) {
        final webBytes = file.bytes;
        if (webBytes == null) return null;
        bytes = webBytes;
      } else {
        final filePath = file.path;
        if (filePath == null || filePath.isEmpty) return null;
        bytes = await File(filePath).readAsBytes();
      }

      final resourceType = _isPdf(file.name) ? 'raw' : 'image';
      return _uploadToCloudinary(
        bytes: bytes,
        path: path,
        fileName: file.name,
        resourceType: resourceType,
        onProgress: onProgress,
      );
    } catch (e) {
      debugPrint('Error uploading platform file: $e');
      return null;
    }
  }

  /// Removes a product from Firestore. Cloudinary files are not deleted here
  /// (that would require a paid Firebase Blaze backend). Orphaned files can
  /// be cleaned up manually in the Cloudinary Media Library if needed.
  Future<bool> deleteImage(String url) async {
    if (CloudinaryConfig.isCloudinaryUrl(url)) {
      debugPrint(
        'Cloudinary asset kept in Media Library (no Blaze backend): $url',
      );
    } else {
      debugPrint('Skipping legacy storage URL delete: $url');
    }
    return true;
  }

  /// Stable Cloudinary path per product so re-uploads can overwrite the image.
  String generateProductImagePath(String productId, String fileName) {
    return 'products/$productId/cover';
  }

  /// Generate a unique path for user uploads
  String generateUserUploadPath(String userId, String folder, String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = _getExtension(fileName);
    return 'users/$userId/$folder/${timestamp}_upload.$ext';
  }

  /// Generate a unique path for general uploads
  String generateUploadPath(String folder, String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = _getExtension(fileName);
    return '$folder/${timestamp}_upload.$ext';
  }

  Future<String?> _uploadToCloudinary({
    required Uint8List bytes,
    required String path,
    required String fileName,
    required String resourceType,
    bool overwrite = false,
    void Function(double)? onProgress,
  }) async {
    if (!CloudinaryConfig.isConfigured) {
      debugPrint(
        'Cloudinary is not configured. Set CLOUDINARY_CLOUD_NAME and '
        'CLOUDINARY_UPLOAD_PRESET via --dart-define or cloudinary_config.dart.',
      );
      return null;
    }

    final (folder, publicId) = _parseStoragePath(path);
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/$resourceType/upload',
    );

    onProgress?.call(0.05);

    try {
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
        ..fields['public_id'] = publicId;

      if (folder.isNotEmpty) {
        request.fields['folder'] = folder;
      }

      if (overwrite) {
        request.fields['overwrite'] = 'true';
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

      onProgress?.call(0.35);

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      onProgress?.call(0.85);

      if (streamedResponse.statusCode < 200 || streamedResponse.statusCode >= 300) {
        debugPrint(
          'Cloudinary upload failed (${streamedResponse.statusCode}): $responseBody',
        );
        return null;
      }

      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      final secureUrl = json['secure_url'] as String?;
      onProgress?.call(1.0);
      debugPrint('Cloudinary upload OK: $secureUrl');
      return secureUrl;
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      return null;
    }
  }

  (String folder, String publicId) _parseStoragePath(String path) {
    final lastSlash = path.lastIndexOf('/');
    if (lastSlash == -1) {
      return ('', _stripExtension(path));
    }

    final folder = path.substring(0, lastSlash);
    final fileName = path.substring(lastSlash + 1);
    return (folder, _stripExtension(fileName));
  }

  String _stripExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0) return fileName;
    return fileName.substring(0, dotIndex);
  }

  bool _isPdf(String fileName) => fileName.toLowerCase().endsWith('.pdf');

  String _getExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : 'jpg';
  }
}
