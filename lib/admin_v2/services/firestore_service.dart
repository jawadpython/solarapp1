import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noor_energy/core/constants/partner_service_types.dart';
import 'package:noor_energy/core/services/city_service.dart';

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
  CollectionReference get _chats => _db.collection('chats');

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
    // No orderBy to avoid requiring a composite index; sort in UI if needed
    return _notifications.where('user', isEqualTo: 'admin').snapshots();
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
  }

  // Delete any request document from a given collection
  Future<void> deleteRequest({
    required String collection,
    required String requestId,
  }) async {
    await _db.collection(collection).doc(requestId).delete();
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

  // Approve technician application
  Future<void> approveTechnicianApplication(String applicationId) async {
    final appDoc = await _technicianApplications.doc(applicationId).get();
    if (!appDoc.exists) return;

    final appData = appDoc.data() as Map<String, dynamic>;
    await CityService.instance.ensureLoaded();
    final cityText = (appData['ville'] ?? appData['city'] ?? '').toString();
    final cityFields = CityService.instance.resolveCityFields(
      ville: cityText,
      cityId: appData['cityId']?.toString(),
    );

    // Create technician document
    await _technicians.add({
      'name': appData['name'] ?? '',
      'phone': appData['phone'] ?? '',
      'city': cityFields['city'] ?? '',
      if (cityFields['cityId'] != null) 'cityId': cityFields['cityId'],
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

  // Permanently delete technician application document
  Future<void> deleteTechnicianApplication(String applicationId) async {
    await _technicianApplications.doc(applicationId).delete();
  }

  // Approve partner application
  /// [specialityOverride] is used when the application has no type (legacy data).
  Future<void> approvePartnerApplication(
    String applicationId, {
    String? specialityOverride,
  }) async {
    final appDoc = await _partnerApplications.doc(applicationId).get();
    if (!appDoc.exists) return;

    final appData = appDoc.data() as Map<String, dynamic>;
    final resolvedSpeciality = () {
      final o = specialityOverride?.trim();
      if (o != null && o.isNotEmpty) return o;
      return PartnerServiceTypes.serviceTypeFromMap(appData);
    }();

    await CityService.instance.ensureLoaded();
    final cityText = (appData['ville'] ?? appData['city'] ?? '').toString();
    final cityFields = CityService.instance.resolveCityFields(
      ville: cityText,
      cityId: appData['cityId']?.toString(),
    );
    final city = cityFields['city'] ?? '';

    // Create partner document with all company information
    await _partners.add({
      'companyName': appData['nomEntreprise'] ?? appData['companyName'] ?? appData['name'] ?? '',
      'name': appData['nomEntreprise'] ?? appData['companyName'] ?? appData['name'] ?? '',
      'nomEntreprise': appData['nomEntreprise'] ?? appData['companyName'] ?? appData['name'] ?? '',
      'ICE': appData['ICE'] ?? '',
      'IF': appData['IF'] ?? '',
      'RC': appData['RC'] ?? '',
      'Patente': appData['Patente'] ?? '',
      'adresse': appData['adresse'] ?? '',
      'phone': appData['telephone'] ?? appData['phone'] ?? '',
      'telephone': appData['telephone'] ?? appData['phone'] ?? '',
      'city': city,
      'ville': city,
      if (cityFields['cityId'] != null) 'cityId': cityFields['cityId'],
      'email': appData['email'] ?? '',
      'speciality': resolvedSpeciality,
      'documentsEntreprise': appData['documentsEntreprise'] ?? '',
      'documentsEntrepriseUrls': appData['documentsEntrepriseUrls'] ?? [],
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update application status + persist resolved type for admin history / exports
    await _partnerApplications.doc(applicationId).update({
      'status': 'approved',
      'updatedAt': FieldValue.serverTimestamp(),
      'speciality': resolvedSpeciality,
    });
  }

  // Reject partner application
  Future<void> rejectPartnerApplication(String applicationId) async {
    await _partnerApplications.doc(applicationId).update({
      'status': 'rejected',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Permanently delete partner application document
  Future<void> deletePartnerApplication(String applicationId) async {
    await _partnerApplications.doc(applicationId).delete();
  }

  // Delete technician
  Future<void> deleteTechnician(String technicianId) async {
    await _technicians.doc(technicianId).delete();
  }

  // Delete partner
  Future<void> deletePartner(String partnerId) async {
    await _partners.doc(partnerId).delete();
  }

  /// Deletes a chat conversation from the admin panel.
  ///
  /// Message sub-documents are removed in batches when permitted; the chat
  /// document is always deleted last so the conversation disappears from admin.
  Future<void> deleteChatConversation(String chatId) async {
    final chatRef = _chats.doc(chatId);
    final messages = await chatRef.collection('messages').get();

    const batchLimit = 500;
    for (var i = 0; i < messages.docs.length; i += batchLimit) {
      final batch = _db.batch();
      final end = (i + batchLimit < messages.docs.length)
          ? i + batchLimit
          : messages.docs.length;
      for (var j = i; j < end; j++) {
        batch.delete(messages.docs[j].reference);
      }
      try {
        await batch.commit();
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          break;
        }
        rethrow;
      }
    }

    await chatRef.delete();
  }

  // Update partner service type (`speciality`)
  Future<void> updatePartnerServiceType({
    required String partnerId,
    required String serviceType,
  }) async {
    await _partners.doc(partnerId).update({
      'speciality': serviceType.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Mark notification as read
  Future<void> markNotificationRead(String notificationId) async {
    await _notifications.doc(notificationId).update({
      'seen': true,
      'seenAt': FieldValue.serverTimestamp(),
    });
  }

  static Map<String, int> _defaultStats() => {
        'devis': 0,
        'installation': 0,
        'maintenance': 0,
        'pumping': 0,
        'project': 0,
        'pendingTechnicianApps': 0,
        'pendingPartnerApps': 0,
        'technicians': 0,
        'partners': 0,
      };

  // Get statistics (resilient: each collection read in try/catch so one failure doesn't break all)
  Future<Map<String, int>> getStatistics() async {
    final stats = _defaultStats();

    if (Firebase.apps.isEmpty) return stats;

    Future<int> safeCount(Future<QuerySnapshot> Function() query) async {
      try {
        final snapshot = await query();
        return snapshot.docs.length;
      } catch (_) {
        return 0;
      }
    }

    try {
      stats['devis'] = await safeCount(() => _devisRequests.get());
      stats['installation'] = await safeCount(() => _installationRequests.get());
      stats['maintenance'] = await safeCount(() => _maintenanceRequests.get());
      stats['pumping'] = await safeCount(() => _pumpingRequests.get());
      stats['project'] = await safeCount(() => _projectRequests.get());
      stats['pendingTechnicianApps'] = await safeCount(
          () => _technicianApplications.where('status', isEqualTo: 'pending').get());
      stats['pendingPartnerApps'] = await safeCount(
          () => _partnerApplications.where('status', isEqualTo: 'pending').get());
      stats['technicians'] = await safeCount(
          () => _technicians.where('active', isEqualTo: true).get());
      stats['partners'] = await safeCount(
          () => _partners.where('active', isEqualTo: true).get());
    } catch (_) {
      // return default zeros
    }

    return stats;
  }
}
