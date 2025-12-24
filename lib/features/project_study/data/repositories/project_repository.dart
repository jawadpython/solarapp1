import 'package:noor_energy/features/project_study/data/models/project_request.dart';

// TODO: Connect to Firebase Firestore
abstract class ProjectRepository {
  Future<String> createRequest(ProjectRequest request);
  Future<List<ProjectRequest>> getUserRequests(String userId);
  Future<ProjectRequest?> getRequestById(String id);
  Future<void> updateRequestStatus(String id, String status);
}

class ProjectRepositoryImpl implements ProjectRepository {
  // TODO: Add FirebaseFirestore instance

  @override
  Future<String> createRequest(ProjectRequest request) async {
    // TODO: Implement Firestore add
    return '';
  }

  @override
  Future<List<ProjectRequest>> getUserRequests(String userId) async {
    // TODO: Implement Firestore query
    return [];
  }

  @override
  Future<ProjectRequest?> getRequestById(String id) async {
    // TODO: Implement Firestore get
    return null;
  }

  @override
  Future<void> updateRequestStatus(String id, String status) async {
    // TODO: Implement Firestore update
  }
}

