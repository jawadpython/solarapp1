import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Admin Analytics Service - Provides statistics and analytics data
class AdminAnalyticsService {
  FirebaseFirestore get _db {
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase is not initialized');
    }
    return FirebaseFirestore.instance;
  }

  /// Get total count for a collection
  Future<int> getCollectionCount(String collectionName) async {
    try {
      final snapshot = await _db.collection(collectionName).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get statistics overview
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final devisCount = await getCollectionCount('devis_requests');
      final installationCount = await getCollectionCount('installation_requests');
      final maintenanceCount = await getCollectionCount('maintenance_requests');
      final pumpingCount = await getCollectionCount('pumping_requests');
      final techniciansCount = await getCollectionCount('technicians');
      final partnersCount = await getCollectionCount('partners');
      
      // Get pending applications
      final techAppsSnapshot = await _db.collection('technician_applications')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      final partnerAppsSnapshot = await _db.collection('partner_applications')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      
      final pendingApplications = (techAppsSnapshot.count ?? 0) + (partnerAppsSnapshot.count ?? 0);
      
      // Get status counts
      final installationPending = await _getStatusCount('installation_requests', 'pending');
      final installationApproved = await _getStatusCount('installation_requests', 'approved');
      final installationRejected = await _getStatusCount('installation_requests', 'rejected');
      final installationAssigned = await _getStatusCount('installation_requests', 'assigned');
      
      final maintenancePending = await _getStatusCount('maintenance_requests', 'pending');
      final maintenanceApproved = await _getStatusCount('maintenance_requests', 'approved');
      final maintenanceRejected = await _getStatusCount('maintenance_requests', 'rejected');
      final maintenanceAssigned = await _getStatusCount('maintenance_requests', 'assigned');
      
      final totalPending = installationPending + maintenancePending;
      final totalApproved = installationApproved + maintenanceApproved;
      final totalRejected = installationRejected + maintenanceRejected;
      final totalAssigned = installationAssigned + maintenanceAssigned;
      
      return {
        'devisRequests': devisCount,
        'installationRequests': installationCount,
        'maintenanceRequests': maintenanceCount,
        'pumpingRequests': pumpingCount,
        'technicians': techniciansCount,
        'partners': partnersCount,
        'pendingApplications': pendingApplications,
        'totalPending': totalPending,
        'totalApproved': totalApproved,
        'totalRejected': totalRejected,
        'totalAssigned': totalAssigned,
        'totalNotAssigned': totalPending + totalApproved - totalAssigned,
      };
    } catch (e) {
      return {
        'devisRequests': 0,
        'installationRequests': 0,
        'maintenanceRequests': 0,
        'pumpingRequests': 0,
        'technicians': 0,
        'partners': 0,
        'pendingApplications': 0,
        'totalPending': 0,
        'totalApproved': 0,
        'totalRejected': 0,
        'totalAssigned': 0,
        'totalNotAssigned': 0,
      };
    }
  }

  /// Get count by status
  Future<int> _getStatusCount(String collection, String status) async {
    try {
      final snapshot = await _db.collection(collection)
          .where('status', isEqualTo: status)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get latest requests (any type)
  Future<List<Map<String, dynamic>>> getLatestRequests({int limit = 5}) async {
    try {
      final allRequests = <Map<String, dynamic>>[];
      
      // Get latest from each collection
      final devis = await _db.collection('devis_requests')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      final installation = await _db.collection('installation_requests')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      final maintenance = await _db.collection('maintenance_requests')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      // Combine and sort
      allRequests.addAll(devis.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['type'] = 'Devis';
        data['name'] = data['fullName'] ?? 'N/A';
        return data;
      }));
      
      allRequests.addAll(installation.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['type'] = 'Installation';
        return data;
      }));
      
      allRequests.addAll(maintenance.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['type'] = 'Maintenance';
        return data;
      }));
      
      // Sort by createdAt and return top limit
      allRequests.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });
      
      return allRequests.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get latest technician applications
  Future<List<Map<String, dynamic>>> getLatestTechnicianApplications({int limit = 5}) async {
    try {
      final snapshot = await _db.collection('technician_applications')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get latest partner applications
  Future<List<Map<String, dynamic>>> getLatestPartnerApplications({int limit = 5}) async {
    try {
      final snapshot = await _db.collection('partner_applications')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get requests per type for pie chart
  Future<Map<String, double>> getRequestsPerType() async {
    try {
      final devis = await getCollectionCount('devis_requests');
      final installation = await getCollectionCount('installation_requests');
      final maintenance = await getCollectionCount('maintenance_requests');
      final pumping = await getCollectionCount('pumping_requests');
      
      return {
        'Devis': devis.toDouble(),
        'Installation': installation.toDouble(),
        'Maintenance': maintenance.toDouble(),
        'Pompage': pumping.toDouble(),
      };
    } catch (e) {
      return {};
    }
  }

  /// Get monthly requests trend (last 6 months)
  Future<List<Map<String, dynamic>>> getMonthlyTrend() async {
    try {
      final now = DateTime.now();
      final months = <Map<String, dynamic>>[];
      
      for (int i = 5; i >= 0; i--) {
        final monthStart = DateTime(now.year, now.month - i, 1);
        final monthEnd = DateTime(now.year, now.month - i + 1, 0, 23, 59, 59);
        
        final devis = await _getCountInRange('devis_requests', monthStart, monthEnd);
        final installation = await _getCountInRange('installation_requests', monthStart, monthEnd);
        final maintenance = await _getCountInRange('maintenance_requests', monthStart, monthEnd);
        
        months.add({
          'month': _getMonthName(monthStart.month),
          'devis': devis,
          'installation': installation,
          'maintenance': maintenance,
          'total': devis + installation + maintenance,
        });
      }
      
      return months;
    } catch (e) {
      return [];
    }
  }

  Future<int> _getCountInRange(String collection, DateTime start, DateTime end) async {
    try {
      // Use count query for better performance
      final snapshot = await _db.collection(collection)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      // If createdAt field doesn't exist or query fails, return 0
      // This prevents crashes and allows graceful degradation
      return 0;
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return months[month - 1];
  }

  /// Get approved vs rejected ratio
  Future<Map<String, double>> getApprovedRejectedRatio() async {
    try {
      final approved = await _getStatusCount('installation_requests', 'approved') +
                      await _getStatusCount('maintenance_requests', 'approved');
      final rejected = await _getStatusCount('installation_requests', 'rejected') +
                      await _getStatusCount('maintenance_requests', 'rejected');
      
      return {
        'approved': approved.toDouble(),
        'rejected': rejected.toDouble(),
      };
    } catch (e) {
      return {'approved': 0.0, 'rejected': 0.0};
    }
  }

  /// Get pumping vs normal solar share
  Future<Map<String, double>> getPumpingVsSolarShare() async {
    try {
      final pumping = await getCollectionCount('pumping_requests');
      final devis = await getCollectionCount('devis_requests');
      final installation = await getCollectionCount('installation_requests');
      final normalSolar = devis + installation;
      
      return {
        'pumping': pumping.toDouble(),
        'normalSolar': normalSolar.toDouble(),
      };
    } catch (e) {
      return {'pumping': 0.0, 'normalSolar': 0.0};
    }
  }
}

