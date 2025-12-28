import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noor_energy/features/calculator/models/devis_request.dart';

class DevisService {
  static final List<DevisRequest> _requests = []; // Temporary in-memory storage

  /// Save devis request to Firestore (when Firebase Storage billing enabled)
  /// Falls back to in-memory storage if Firebase not available
  static Future<void> saveRequest(DevisRequest req) async {
    try {
      // Try to save to Firestore if Firebase is initialized
      if (Firebase.apps.isNotEmpty) {
        await FirebaseFirestore.instance.collection('devis_requests').add({
          'id': req.id,
          'date': req.date.toIso8601String(),
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
          'createdAt': FieldValue.serverTimestamp(),
        });
        return; // Successfully saved to Firestore
      }
    } catch (e) {
      // Fallback to in-memory if Firestore fails
    }
    
    // Fallback: Save to in-memory list
    await Future.delayed(const Duration(milliseconds: 400));
    _requests.add(req);
  }

  static List<DevisRequest> getAllRequests() {
    return List.unmodifiable(_requests);
  }

  static int getRequestCount() {
    return _requests.length;
  }
}

