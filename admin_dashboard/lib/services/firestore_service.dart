import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AdminFirestoreService {
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
  CollectionReference get _technicianApplications => _db.collection('technician_applications');
  CollectionReference get _partnerApplications => _db.collection('partner_applications');
  CollectionReference get _technicians => _db.collection('technicians');
  CollectionReference get _partners => _db.collection('partners');
  CollectionReference get _notifications => _db.collection('notifications');
  CollectionReference get _projectRequests => _db.collection('project_requests');

  // Streams for real-time updates
  Stream<QuerySnapshot> streamDevisRequests() {
    return _devisRequests.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> streamInstallationRequests() {
    return _installationRequests.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> streamMaintenanceRequests() {
    return _maintenanceRequests.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> streamPumpingRequests() {
    return _pumpingRequests.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> streamProjectRequests() {
    return _projectRequests.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> streamTechnicianApplications() {
    return _technicianApplications.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> streamPartnerApplications() {
    return _partnerApplications.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> streamTechnicians() {
    return _technicians.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> streamPartners() {
    return _partners.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> streamNotifications() {
    return _notifications.where('user', isEqualTo: 'admin').orderBy('date', descending: true).snapshots();
  }

  // Update request status
  Future<void> updateRequestStatus({
    required String collection,
    required String requestId,
    required String status,
  }) async {
    await _db.collection(collection).doc(requestId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    // Create admin notification
    await _createAdminNotification(
      type: collection.replaceAll('_requests', ''),
      title: 'Statut mis à jour',
      message: 'Le statut de la demande a été changé en: $status',
      requestId: requestId,
      requestCollection: collection,
    );
  }

  // Assign technician to request
  Future<void> assignTechnician({
    required String collection,
    required String requestId,
    required Map<String, dynamic> technician,
  }) async {
    await _db.collection(collection).doc(requestId).update({
      'status': 'assigned',
      'assignedTechnician': {
        'id': technician['id'],
        'name': technician['name'],
        'phone': technician['phone'],
        'city': technician['city'],
      },
      'assignedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    // Create admin notification
    await _createAdminNotification(
      type: collection.replaceAll('_requests', ''),
      title: 'Technicien assigné',
      message: '${technician['name']} a été assigné à cette demande',
      requestId: requestId,
      requestCollection: collection,
    );
  }

  // Bulk update status
  Future<void> bulkUpdateStatus({
    required String collection,
    required List<String> requestIds,
    required String status,
  }) async {
    final batch = _db.batch();
    for (final id in requestIds) {
      final ref = _db.collection(collection).doc(id);
      batch.update(ref, {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    
    // Create admin notification
    await _createAdminNotification(
      type: collection.replaceAll('_requests', ''),
      title: 'Mise à jour en masse',
      message: '${requestIds.length} demande(s) mise(s) à jour: $status',
      requestId: requestIds.first,
      requestCollection: collection,
    );
  }

  // Get active technicians for assignment
  Future<List<Map<String, dynamic>>> getActiveTechnicians() async {
    final snapshot = await _technicians.where('active', isEqualTo: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return <String, dynamic>{
        ...data,
        'id': doc.id,
      };
    }).toList();
  }

  // Helper to create admin notifications
  Future<void> _createAdminNotification({
    required String type,
    required String title,
    required String message,
    required String requestId,
    required String requestCollection,
  }) async {
    try {
      await _notifications.add({
        'type': type,
        'title': title,
        'message': message,
        'user': 'admin',
        'date': FieldValue.serverTimestamp(),
        'seen': false,
        'requestId': requestId,
        'requestCollection': requestCollection,
      });
    } catch (e) {
      // Silently fail - notification is not critical
    }
  }

  // Approve technician application
  Future<void> approveTechnicianApplication(String applicationId) async {
    final appDoc = await _technicianApplications.doc(applicationId).get();
    if (!appDoc.exists) return;

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
  }

  // Reject technician application
  Future<void> rejectTechnicianApplication(String applicationId) async {
    await _technicianApplications.doc(applicationId).update({
      'status': 'rejected',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Approve partner application
  Future<void> approvePartnerApplication(String applicationId) async {
    final appDoc = await _partnerApplications.doc(applicationId).get();
    if (!appDoc.exists) return;

    final appData = appDoc.data() as Map<String, dynamic>;
    
    // Create partner document
    await _partners.add({
      'companyName': appData['companyName'] ?? appData['name'] ?? '',
      'name': appData['companyName'] ?? appData['name'] ?? '',
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
  }

  // Reject partner application
  Future<void> rejectPartnerApplication(String applicationId) async {
    await _partnerApplications.doc(applicationId).update({
      'status': 'rejected',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Mark notification as read
  Future<void> markNotificationRead(String notificationId) async {
    await _notifications.doc(notificationId).update({
      'seen': true,
    });
  }

  // Delete technician
  Future<void> deleteTechnician(String technicianId) async {
    await _technicians.doc(technicianId).delete();
  }

  // Delete partner
  Future<void> deletePartner(String partnerId) async {
    await _partners.doc(partnerId).delete();
  }

  // Get statistics
  Future<Map<String, int>> getStatistics() async {
    final devisSnapshot = await _devisRequests.get();
    final installationSnapshot = await _installationRequests.get();
    final maintenanceSnapshot = await _maintenanceRequests.get();
    final pumpingSnapshot = await _pumpingRequests.get();
    final technicianAppSnapshot = await _technicianApplications.where('status', isEqualTo: 'pending').get();
    final partnerAppSnapshot = await _partnerApplications.where('status', isEqualTo: 'pending').get();
    final techniciansSnapshot = await _technicians.where('active', isEqualTo: true).get();
    final partnersSnapshot = await _partners.where('active', isEqualTo: true).get();

    return {
      'devis': devisSnapshot.docs.length,
      'installation': installationSnapshot.docs.length,
      'maintenance': maintenanceSnapshot.docs.length,
      'pumping': pumpingSnapshot.docs.length,
      'pendingTechnicianApps': technicianAppSnapshot.docs.length,
      'pendingPartnerApps': partnerAppSnapshot.docs.length,
      'technicians': techniciansSnapshot.docs.length,
      'partners': partnersSnapshot.docs.length,
    };
  }
}

