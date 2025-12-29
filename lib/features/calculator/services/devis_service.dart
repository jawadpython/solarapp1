import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:noor_energy/features/calculator/models/devis_request.dart';
import 'package:noor_energy/core/services/notification_service.dart';

class DevisService {
  /// Save devis request to Firestore
  /// Throws exception if Firebase is not available or save fails
  static Future<void> saveRequest(DevisRequest req) async {
    // Use both print and debugPrint for web compatibility
    print('🚀🚀🚀 DevisService.saveRequest() CALLED 🚀🚀🚀');
    debugPrint('🚀 DevisService.saveRequest() called');
    developer.log('DevisService.saveRequest() called', name: 'DevisService');
    
    // Check if Firebase is initialized
    if (Firebase.apps.isEmpty) {
      print('❌❌❌ ERROR: Firebase apps is empty! ❌❌❌');
      debugPrint('❌ ERROR: Firebase apps is empty!');
      throw Exception('Firebase is not initialized. Please check your Firebase configuration.');
    }

    print('✅✅✅ Firebase is initialized. Apps count: ${Firebase.apps.length} ✅✅✅');
    debugPrint('✅ Firebase is initialized. Apps count: ${Firebase.apps.length}');
    
    // Validate request object
    if (req == null) {
      debugPrint('❌ ERROR: Request object is null!');
      throw Exception('Request object is null');
    }
    
    print('📝 Attempting to save devis request for: ${req.fullName ?? "NULL"}');
    print('📋 Request details: systemType=${req.systemType ?? "NULL"}, regionCode=${req.regionCode ?? "NULL"}');
    print('📋 Request ID: ${req.id ?? "NULL"}');
    debugPrint('📝 Attempting to save devis request for: ${req.fullName ?? "NULL"}');
    debugPrint('📋 Request details: systemType=${req.systemType ?? "NULL"}, regionCode=${req.regionCode ?? "NULL"}');
    debugPrint('📋 Request ID: ${req.id ?? "NULL"}');

    try {
      print('🔍 Getting Firestore instance...');
      debugPrint('🔍 Getting Firestore instance...');
      final db = FirebaseFirestore.instance;
      print('📦 Firestore instance obtained successfully');
      debugPrint('📦 Firestore instance obtained successfully');
      print('🔍 Firestore instance type: ${db.runtimeType}');
      debugPrint('🔍 Firestore instance type: ${db.runtimeType}');
      
      // Prepare data map
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
        'status': 'pending', // Default status
      };
      
      print('💾 Saving to Firestore collection: devis_requests');
      print('📋 Data keys: ${data.keys.toList()}');
      print('📋 Data preview: fullName=${data['fullName']}, phone=${data['phone']}, city=${data['city']}');
      debugPrint('💾 Saving to Firestore collection: devis_requests');
      debugPrint('📋 Data keys: ${data.keys.toList()}');
      debugPrint('📋 Data preview: fullName=${data['fullName']}, phone=${data['phone']}, city=${data['city']}');
      
      // Save to Firestore - collection will be created automatically if it doesn't exist
      print('⏳⏳⏳ Calling db.collection("devis_requests").add()... ⏳⏳⏳');
      debugPrint('⏳ Calling db.collection("devis_requests").add()...');
      print('⏳ This may take a few seconds...');
      debugPrint('⏳ This may take a few seconds...');
      
      final docRef = await db.collection('devis_requests').add(data).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('❌❌❌ TIMEOUT: Firestore add() operation timed out after 30 seconds ❌❌❌');
          debugPrint('❌ TIMEOUT: Firestore add() operation timed out after 30 seconds');
          throw Exception('Firestore operation timed out. Please check your internet connection and Firestore security rules.');
        },
      );
      
      print('✅✅✅ Successfully saved devis request! Document ID: ${docRef.id} ✅✅✅');
      debugPrint('✅ Successfully saved devis request! Document ID: ${docRef.id}');
      
      // Create admin notification
      try {
        debugPrint('🔔 Creating admin notification...');
        await NotificationService().createAdminNotification(
          type: NotificationType.devisRequest,
          title: 'Nouvelle demande de devis',
          message: 'Un utilisateur a envoyé une demande de devis',
          requestId: docRef.id,
          requestCollection: 'devis_requests',
        );
        debugPrint('✅ Admin notification created successfully');
      } catch (e) {
        // Log but don't fail - notification is not critical for the main operation
        debugPrint('⚠️ Failed to create admin notification: $e');
      }
    } on FirebaseException catch (e) {
      print('❌❌❌ FirebaseException: ${e.code} - ${e.message} ❌❌❌');
      print('📋 Details: ${e.toString()}');
      debugPrint('❌ FirebaseException: ${e.code} - ${e.message}');
      debugPrint('📋 Details: ${e.toString()}');
      developer.log('FirebaseException: ${e.code} - ${e.message}', error: e, name: 'DevisService');
      throw Exception('Erreur Firebase: ${e.code} - ${e.message}');
    } catch (e, stackTrace) {
      print('❌❌❌ General Exception: $e ❌❌❌');
      print('📋 Stack trace: $stackTrace');
      debugPrint('❌ General Exception: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      developer.log('General Exception', error: e, stackTrace: stackTrace, name: 'DevisService');
      throw Exception('Erreur lors de l\'enregistrement: ${e.toString()}');
    }
  }
}

