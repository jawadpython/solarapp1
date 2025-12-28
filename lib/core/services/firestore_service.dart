import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// FirestoreService handles all database operations using Cloud Firestore.
/// 
/// Firestore is a NoSQL document database that provides:
/// - Real-time data synchronization
/// - Offline support
/// - Automatic scaling
/// 
/// Data structure:
/// - Collections contain Documents
/// - Documents contain Fields (key-value pairs)
/// - Documents can also contain Sub-collections
class FirestoreService {
  // Lazy getter for FirebaseFirestore instance to avoid errors if Firebase isn't initialized
  FirebaseFirestore get _db {
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase is not initialized. Please configure Firebase first.');
    }
    return FirebaseFirestore.instance;
  }

  // ============================================================
  // COLLECTION REFERENCES
  // ============================================================
  
  /// Reference to the 'users' collection where user profiles are stored.
  /// Each document ID is the user's Firebase Auth UID.
  CollectionReference get usersCollection => _db.collection('users');
  
  /// Reference to the 'project_requests' collection.
  /// Stores all solar project study requests.
  CollectionReference get projectRequestsCollection => _db.collection('project_requests');
  
  /// Reference to the 'installation_requests' collection.
  /// Stores all installation requests.
  CollectionReference get installationRequestsCollection => _db.collection('installation_requests');

  /// Reference to the 'pumping_requests' collection.
  /// Stores all pumping devis requests.
  CollectionReference get pumpingRequestsCollection => _db.collection('pumping_requests');

  // ============================================================
  // USER OPERATIONS
  // ============================================================

  /// Creates a new user document in Firestore.
  /// 
  /// Called after successful Firebase Auth registration.
  /// Uses the Auth UID as the document ID for easy lookup.
  /// 
  /// [userId] - The Firebase Auth UID
  /// [email] - User's email address
  /// [name] - User's display name
  /// [role] - User role: 'admin', 'technician', or 'client' (default: 'client')
  Future<void> createUserDocument({
    required String userId,
    required String email,
    required String name,
    String? phone,
    String role = 'client',
  }) async {
    // .doc(userId) creates/references a document with that ID
    // .set() creates the document or overwrites if it exists
    await usersCollection.doc(userId).set({
      'uid': userId,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role, // 'admin', 'technician', or 'client'
      'createdAt': FieldValue.serverTimestamp(), // Server-side timestamp
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Retrieves a user document by their UID.
  /// 
  /// Returns null if the user document doesn't exist.
  Future<Map<String, dynamic>?> getUserDocument(String userId) async {
    // .get() fetches the document once (not real-time)
    final DocumentSnapshot doc = await usersCollection.doc(userId).get();
    
    // Check if document exists before accessing data
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  /// Gets user role from Firestore
  /// Returns 'client' as default if role not found
  Future<String> getUserRole(String userId) async {
    try {
      final userDoc = await getUserDocument(userId);
      if (userDoc != null && userDoc['role'] != null) {
        return userDoc['role'] as String;
      }
      return 'client'; // Default role
    } catch (e) {
      return 'client'; // Default on error
    }
  }

  /// Updates specific fields in a user document.
  /// 
  /// Only updates the fields provided, leaves others unchanged.
  Future<void> updateUserDocument(String userId, Map<String, dynamic> data) async {
    // .update() only modifies specified fields
    // Throws error if document doesn't exist
    await usersCollection.doc(userId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // PROJECT REQUEST OPERATIONS
  // ============================================================

  /// Saves a new project study request to Firestore.
  /// 
  /// Returns the auto-generated document ID.
  /// 
  /// [userId] - The requesting user's UID
  /// [projectType] - ON-GRID, OFF-GRID, PUMPING, or HYBRID
  /// [consumption] - Energy consumption value
  /// [isKwh] - true if consumption is in kWh, false if kW
  /// [panelPower] - Selected panel power in watts
  /// [estimatedPower] - Calculated installation power in kW
  Future<String> saveProjectRequest({
    required String userId,
    required String projectType,
    required double consumption,
    required bool isKwh,
    required int panelPower,
    required double estimatedPower,
  }) async {
    // .add() creates a new document with auto-generated ID
    final DocumentReference docRef = await projectRequestsCollection.add({
      'userId': userId,
      'projectType': projectType,
      'consumption': consumption,
      'isKwh': isKwh,
      'panelPower': panelPower,
      'estimatedPower': estimatedPower,
      'status': 'pending', // pending, approved, rejected
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // Return the auto-generated document ID
    return docRef.id;
  }

  /// Retrieves all project requests for a specific user.
  /// 
  /// Returns a list of requests ordered by creation date (newest first).
  Future<List<Map<String, dynamic>>> getUserProjectRequests(String userId) async {
    // .where() filters documents by field value
    // .orderBy() sorts the results
    final QuerySnapshot snapshot = await projectRequestsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    
    // Convert QuerySnapshot to List of Maps
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Include document ID
      return data;
    }).toList();
  }

  /// Retrieves a single project request by its document ID.
  Future<Map<String, dynamic>?> getProjectRequest(String requestId) async {
    final DocumentSnapshot doc = await projectRequestsCollection.doc(requestId).get();
    
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }
    return null;
  }

  /// Updates the status of a project request.
  /// 
  /// [status] should be: 'pending', 'approved', or 'rejected'
  Future<void> updateProjectRequestStatus(String requestId, String status) async {
    await projectRequestsCollection.doc(requestId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // REAL-TIME LISTENERS (Optional - for live updates)
  // ============================================================

  /// Returns a stream of project requests for real-time updates.
  /// 
  /// Use with StreamBuilder in the UI for live data.
  Stream<QuerySnapshot> streamUserProjectRequests(String userId) {
    return projectRequestsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots(); // .snapshots() returns a Stream instead of Future
  }

  // ============================================================
  // INSTALLATION REQUEST OPERATIONS
  // ============================================================

  /// Saves a new installation request to Firestore.
  /// 
  /// Returns the auto-generated document ID.
  Future<String> saveInstallationRequest({
    required String name,
    required String phone,
    required String systemType,
    required String locationType,
    String? description,
    String? location,
    String? city,
    List<String>? photoUrls,
    String? userId,
  }) async {
    // Check if Firebase is initialized
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase is not initialized. Please configure Firebase first.');
    }
    
    final DocumentReference docRef = await installationRequestsCollection.add({
      'userId': userId,
      'name': name,
      'phone': phone,
      'systemType': systemType,
      'locationType': locationType,
      'description': description,
      'location': location,
      'city': city,
      'photoUrls': photoUrls ?? [],
      'status': 'pending', // pending, approved, rejected, in_progress, completed
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    return docRef.id;
  }

  // ============================================================
  // PUMPING REQUEST OPERATIONS
  // ============================================================

  /// Saves a new pumping devis request to Firestore.
  /// 
  /// Returns the auto-generated document ID.
  Future<String> savePumpingRequest({
    required String name,
    required String phone,
    required String city,
    String? gps,
    String? note,
    required double q,
    required double h,
    required double pumpKW,
    required double pvPower,
    required int panels,
    required double savingMonth,
    required double savingYear,
    required String regionCode,
    String? userId,
  }) async {
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase is not initialized. Please configure Firebase first.');
    }
    
    final DocumentReference docRef = await pumpingRequestsCollection.add({
      'userId': userId,
      'name': name,
      'phone': phone,
      'city': city,
      'gps': gps,
      'note': note,
      'Q': q,
      'H': h,
      'pumpKW': pumpKW,
      'PVpower': pvPower,
      'panels': panels,
      'savingMonth': savingMonth,
      'savingYear': savingYear,
      'regionCode': regionCode,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    return docRef.id;
  }
}

