import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:image_picker/image_picker.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;
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

  /// Upload image to Firebase Storage
  /// Returns the download URL on success, null on failure
  Future<String?> uploadImage({
    required XFile file,
    required String path,
    void Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      UploadTask uploadTask;

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/${_getExtension(file.name)}'),
        );
      } else {
        uploadTask = ref.putFile(
          File(file.path),
          SettableMetadata(contentType: 'image/${_getExtension(file.name)}'),
        );
      }

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((event) {
          final progress = event.bytesTransferred / event.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('Firebase Storage error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  /// Upload image from bytes (useful for web)
  Future<String?> uploadImageBytes({
    required Uint8List bytes,
    required String path,
    String contentType = 'image/jpeg',
    void Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((event) {
          final progress = event.bytesTransferred / event.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('Firebase Storage error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error uploading image bytes: $e');
      return null;
    }
  }

  /// Upload file selected with file_picker.
  Future<String?> uploadPlatformFile({
    required PlatformFile file,
    required String path,
    void Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(
        contentType: _guessContentType(file.name),
      );
      late final UploadTask uploadTask;

      if (kIsWeb) {
        final bytes = file.bytes;
        if (bytes == null) return null;
        uploadTask = ref.putData(bytes, metadata);
      } else {
        final filePath = file.path;
        if (filePath == null || filePath.isEmpty) return null;
        uploadTask = ref.putFile(File(filePath), metadata);
      }

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((event) {
          final total = event.totalBytes;
          if (total > 0) {
            onProgress(event.bytesTransferred / total);
          }
        });
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      debugPrint('Firebase Storage error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error uploading platform file: $e');
      return null;
    }
  }

  /// Delete an image from Firebase Storage by URL
  Future<bool> deleteImage(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
      debugPrint('Image deleted successfully: $url');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('Firebase Storage error deleting: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Generate a unique path for product images
  String generateProductImagePath(String productId, String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = _getExtension(fileName);
    return 'products/$productId/${timestamp}_$productId.$ext';
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

  String _getExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : 'jpg';
  }

  String _guessContentType(String fileName) {
    final ext = _getExtension(fileName);
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
}
