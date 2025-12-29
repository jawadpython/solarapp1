import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noor_energy/core/services/notification_service.dart';

/// AdminService handles all admin-related Firestore operations
class AdminService {
  FirebaseFirestore get _db {
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase is not initialized');
    }
    return FirebaseFirestore.instance;
  }

  // Collection references
  CollectionReference get _devisRequests => _db.collection('devis_requests');
  CollectionReference get _installationRequests => _db.collection('installation_requests');
  CollectionReference get _maintenanceRequests => _db.collection('maintenance_requests');
  CollectionReference get _pumpingRequests => _db.collection('pumping_requests');
  CollectionReference get _technicians => _db.collection('technicians');
  CollectionReference get _partners => _db.collection('partners');
  CollectionReference get _technicianApplications => _db.collection('technician_applications');
  CollectionReference get _partnerApplications => _db.collection('partner_applications');

  /// Get all devis requests
  Future<List<Map<String, dynamic>>> getDevisRequests() async {
    try {
      final snapshot = await _devisRequests
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      // Try fallback orderBy if createdAt doesn't exist
      try {
        final snapshot = await _devisRequests
            .orderBy('date', descending: true)
            .get();
        
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
      } catch (e2) {
        return [];
      }
    }
  }

  /// Get all installation requests
  Future<List<Map<String, dynamic>>> getInstallationRequests() async {
    try {
      final snapshot = await _installationRequests
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get all maintenance requests
  Future<List<Map<String, dynamic>>> getMaintenanceRequests() async {
    try {
      final snapshot = await _maintenanceRequests
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get all pumping requests
  Future<List<Map<String, dynamic>>> getPumpingRequests() async {
    try {
      final snapshot = await _pumpingRequests
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get all technicians (active and inactive)
  Future<List<Map<String, dynamic>>> getTechnicians() async {
    try {
      final snapshot = await _technicians
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        // Default active to true if not set
        if (data['active'] == null) {
          data['active'] = true;
        }
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get active technicians only
  Future<List<Map<String, dynamic>>> getActiveTechnicians({String? city}) async {
    try {
      Query query = _technicians.where('active', isEqualTo: true);
      if (city != null && city.isNotEmpty && city != 'Tous') {
        query = query.where('city', isEqualTo: city);
      }
      final snapshot = await query.orderBy('createdAt', descending: true).get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get all partners
  Future<List<Map<String, dynamic>>> getPartners() async {
    try {
      final snapshot = await _partners
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Update request status (approve/reject)
  Future<bool> updateRequestStatus({
    required String collection,
    required String requestId,
    required String status,
  }) async {
    try {
      // Get request data to find userId
      final requestDoc = await _db.collection(collection).doc(requestId).get();
      if (!requestDoc.exists) return false;
      
      final requestData = requestDoc.data() as Map<String, dynamic>;
      final userId = requestData['userId'] as String?;
      
      await _db.collection(collection).doc(requestId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Create user notification if userId exists
      if (userId != null && userId.isNotEmpty) {
        try {
          String title = '';
          String message = '';
          
          switch (collection) {
            case 'devis_requests':
              title = 'Mise à jour de votre demande de devis';
              message = status == 'approved' 
                  ? 'Votre demande de devis a été approuvée'
                  : 'Votre demande de devis a été rejetée';
              break;
            case 'installation_requests':
              title = 'Mise à jour de votre demande d\'installation';
              message = status == 'approved'
                  ? 'Votre demande d\'installation a été approuvée'
                  : 'Votre demande d\'installation a été rejetée';
              break;
            case 'maintenance_requests':
              title = 'Mise à jour de votre demande de maintenance';
              message = status == 'approved'
                  ? 'Votre demande de maintenance a été approuvée'
                  : 'Votre demande de maintenance a été rejetée';
              break;
            case 'pumping_requests':
              title = 'Mise à jour de votre demande de pompage';
              message = status == 'approved'
                  ? 'Votre demande de pompage a été approuvée'
                  : 'Votre demande de pompage a été rejetée';
              break;
          }
          
          if (title.isNotEmpty) {
            await NotificationService().createUserNotification(
              userId: userId,
              type: NotificationType.statusUpdate,
              title: title,
              message: message,
              requestId: requestId,
              requestCollection: collection,
            );
          }
        } catch (e) {
          // Silently fail - notification is not critical
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Assign technician to a request
  Future<bool> assignTechnician({
    required String collection,
    required String requestId,
    required String technicianId,
    required String technicianName,
    required String technicianPhone,
  }) async {
    try {
      // Get request data to find userId
      final requestDoc = await _db.collection(collection).doc(requestId).get();
      if (!requestDoc.exists) return false;
      
      final requestData = requestDoc.data() as Map<String, dynamic>;
      final userId = requestData['userId'] as String?;
      
      await _db.collection(collection).doc(requestId).update({
        'assignedTechnicianId': technicianId,
        'assignedTechnicianName': technicianName,
        'assignedTechnicianPhone': technicianPhone,
        'status': 'assigned',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Create user notification
      if (userId != null && userId.isNotEmpty) {
        try {
          String title = '';
          switch (collection) {
            case 'devis_requests':
              title = 'Technicien assigné à votre demande de devis';
              break;
            case 'installation_requests':
              title = 'Technicien assigné à votre demande d\'installation';
              break;
            case 'maintenance_requests':
              title = 'Technicien assigné à votre demande de maintenance';
              break;
            case 'pumping_requests':
              title = 'Technicien assigné à votre demande de pompage';
              break;
          }
          
          if (title.isNotEmpty) {
            await NotificationService().createUserNotification(
              userId: userId,
              type: NotificationType.statusUpdate,
              title: title,
              message: 'Un technicien ($technicianName) a été assigné à votre demande',
              requestId: requestId,
              requestCollection: collection,
            );
          }
        } catch (e) {
          // Silently fail - notification is not critical
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update technician active status
  Future<bool> updateTechnicianStatus({
    required String technicianId,
    required bool active,
  }) async {
    try {
      await _technicians.doc(technicianId).update({
        'active': active,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete technician (soft delete - set active=false)
  Future<bool> deleteTechnician(String technicianId) async {
    try {
      await _technicians.doc(technicianId).update({
        'active': false,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update partner active status
  Future<bool> updatePartnerStatus({
    required String partnerId,
    required bool active,
  }) async {
    try {
      await _partners.doc(partnerId).update({
        'active': active,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get technician applications
  Future<List<Map<String, dynamic>>> getTechnicianApplications() async {
    try {
      final snapshot = await _technicianApplications
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get partner applications
  Future<List<Map<String, dynamic>>> getPartnerApplications() async {
    try {
      final snapshot = await _partnerApplications
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Approve technician application
  Future<bool> approveTechnicianApplication(String applicationId) async {
    try {
      // Get application data
      final appDoc = await _technicianApplications.doc(applicationId).get();
      if (!appDoc.exists) return false;
      
      final appData = appDoc.data() as Map<String, dynamic>;
      
      // Create technician document
      await _technicians.add({
        'name': appData['name'] ?? '',
        'phone': appData['phone'] ?? '',
        'city': appData['city'] ?? '',
        'email': appData['email'] ?? '',
        'speciality': appData['speciality'] ?? '',
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Update application status
      await _technicianApplications.doc(applicationId).update({
        'status': 'approved',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reject technician application
  Future<bool> rejectTechnicianApplication(String applicationId) async {
    try {
      await _technicianApplications.doc(applicationId).update({
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Approve partner application
  Future<bool> approvePartnerApplication(String applicationId) async {
    try {
      // Get application data
      final appDoc = await _partnerApplications.doc(applicationId).get();
      if (!appDoc.exists) return false;
      
      final appData = appDoc.data() as Map<String, dynamic>;
      
      // Create partner document
      await _partners.add({
        'companyName': appData['companyName'] ?? appData['name'] ?? '',
        'name': appData['companyName'] ?? appData['name'] ?? '', // Keep for backward compatibility
        'phone': appData['phone'] ?? '',
        'city': appData['city'] ?? '',
        'email': appData['email'] ?? '',
        'speciality': appData['speciality'] ?? '',
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Update application status
      await _partnerApplications.doc(applicationId).update({
        'status': 'approved',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reject partner application
  Future<bool> rejectPartnerApplication(String applicationId) async {
    try {
      await _partnerApplications.doc(applicationId).update({
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}

