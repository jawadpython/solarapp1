import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:noor_energy/features/calculator/models/devis_request.dart';
import 'package:noor_energy/core/services/notification_service.dart';

class DevisService {
  /// Save devis request to Firestore
  static Future<void> saveRequest(DevisRequest req) async {
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase is not initialized.');
    }

    try {
      final db = FirebaseFirestore.instance;
      final userId = FirebaseAuth.instance.currentUser?.uid;

      final data = {
        'id': req.id,
        'createdAt': FieldValue.serverTimestamp(),
        'date': Timestamp.fromDate(req.date),
        'fullName': req.fullName,
        'phone': req.phone,
        'city': req.city,
        'gps': req.gps,
        'note': req.note,
        'factureImagePath': req.factureImagePath,
        'systemType': req.systemType,
        'regionCode': req.regionCode,
        'kwhMonth': req.kwhMonth,
        'powerKW': req.powerKW,
        'panels': req.panels,
        'savingsMonth': req.savingsMonth,
        'savingsYear': req.savingsYear,
        'status': 'pending',
        if (userId != null) 'userId': userId,
      };

      final docRef = await db.collection('devis_requests').add(data).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
              'Firestore operation timed out. Please check your internet connection.');
        },
      );

      if (kDebugMode) debugPrint('✅ Devis request saved: ${docRef.id}');

      try {
        await NotificationService().createAdminNotification(
          type: NotificationType.devisRequest,
          title: 'Nouvelle demande de devis',
          message: 'Un utilisateur a envoyé une demande de devis',
          requestId: docRef.id,
          requestCollection: 'devis_requests',
        );
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ Failed to create admin notification: $e');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) debugPrint('❌ FirebaseException: ${e.code} - ${e.message}');
      throw Exception('Erreur Firebase: ${e.code} - ${e.message}');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Exception: $e');
      throw Exception('Erreur lors de l\'enregistrement: ${e.toString()}');
    }
  }
}
