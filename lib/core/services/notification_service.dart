import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Notification types
enum NotificationType {
  devisRequest,
  projectRequest,
  installationRequest,
  maintenanceRequest,
  pumpingRequest,
  technicianApplication,
  partnerApplication,
  statusUpdate,
}

/// Notification Service handles all notification operations
class NotificationService {
  FirebaseFirestore get _db {
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase is not initialized');
    }
    return FirebaseFirestore.instance;
  }

  CollectionReference get _notificationsCollection => _db.collection('notifications');

  /// Create a notification for admin
  Future<void> createAdminNotification({
    required NotificationType type,
    required String title,
    required String message,
    String? requestId,
    String? requestCollection,
  }) async {
    try {
      await _notificationsCollection.add({
        'type': type.name,
        'title': title,
        'message': message,
        'user': 'admin',
        'seen': false,
        'requestId': requestId,
        'requestCollection': requestCollection,
        'date': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail - notifications are not critical
      debugPrint('Failed to create admin notification: $e');
    }
  }

  /// Create a notification for a specific user
  Future<void> createUserNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
    String? requestId,
    String? requestCollection,
  }) async {
    try {
      await _notificationsCollection.add({
        'type': type.name,
        'title': title,
        'message': message,
        'user': userId,
        'seen': false,
        'requestId': requestId,
        'requestCollection': requestCollection,
        'date': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail - notifications are not critical
      debugPrint('Failed to create user notification: $e');
    }
  }

  /// Get admin notifications stream
  Stream<QuerySnapshot> getAdminNotificationsStream() {
    try {
      return _notificationsCollection
          .where('user', isEqualTo: 'admin')
          .orderBy('date', descending: true)
          .limit(100)
          .snapshots();
    } catch (e) {
      // Return empty stream on error
      return const Stream.empty();
    }
  }

  /// Get user notifications stream
  Stream<QuerySnapshot> getUserNotificationsStream(String userId) {
    try {
      return _notificationsCollection
          .where('user', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(100)
          .snapshots();
    } catch (e) {
      // Return empty stream on error
      return const Stream.empty();
    }
  }

  /// Get admin notifications count (unseen)
  Future<int> getAdminUnseenCount() async {
    try {
      final snapshot = await _notificationsCollection
          .where('user', isEqualTo: 'admin')
          .where('seen', isEqualTo: false)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get user notifications count (unseen)
  Future<int> getUserUnseenCount(String userId) async {
    try {
      final snapshot = await _notificationsCollection
          .where('user', isEqualTo: userId)
          .where('seen', isEqualTo: false)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Mark notification as seen
  Future<void> markAsSeen(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({
        'seen': true,
        'seenAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to mark notification as seen: $e');
    }
  }

  /// Mark all admin notifications as seen
  Future<void> markAllAdminAsSeen() async {
    try {
      final snapshot = await _notificationsCollection
          .where('user', isEqualTo: 'admin')
          .where('seen', isEqualTo: false)
          .get();
      
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'seen': true,
          'seenAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Failed to mark all admin notifications as seen: $e');
    }
  }

  /// Mark all user notifications as seen
  Future<void> markAllUserAsSeen(String userId) async {
    try {
      final snapshot = await _notificationsCollection
          .where('user', isEqualTo: userId)
          .where('seen', isEqualTo: false)
          .get();
      
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'seen': true,
          'seenAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Failed to mark all user notifications as seen: $e');
    }
  }
}

