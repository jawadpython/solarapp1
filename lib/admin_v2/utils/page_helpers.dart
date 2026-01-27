import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper functions for admin pages
class PageHelpers {
  /// Apply filters to data list
  static List<Map<String, dynamic>> applyFilters({
    required List<Map<String, dynamic>> data,
    String? statusFilter,
    DateTime? startDate,
    DateTime? endDate,
    String? regionFilter,
    String searchQuery = '',
  }) {
    return data.where((item) {
      // Status filter
      if (statusFilter != null && item['status']?.toString() != statusFilter) {
        return false;
      }

      // Date range filter
      if (startDate != null || endDate != null) {
        final createdAt = item['createdAt'] ?? item['date'];
        if (createdAt != null) {
          DateTime? itemDate;
          if (createdAt is Timestamp) {
            itemDate = createdAt.toDate();
          } else if (createdAt is DateTime) {
            itemDate = createdAt;
          }
          if (itemDate != null) {
            if (startDate != null && itemDate.isBefore(startDate)) return false;
            if (endDate != null && itemDate.isAfter(endDate.add(const Duration(days: 1)))) return false;
          }
        }
      }

      // Region filter
      if (regionFilter != null) {
        final city = item['city']?.toString().toLowerCase() ?? '';
        if (city != regionFilter.toLowerCase()) return false;
      }

      // Search filter
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final name = (item['name']?.toString() ?? item['fullName']?.toString() ?? '').toLowerCase();
        final phone = (item['phone']?.toString() ?? item['phoneNumber']?.toString() ?? '').toLowerCase();
        final city = (item['city']?.toString() ?? '').toLowerCase();
        final email = (item['email']?.toString() ?? '').toLowerCase();
        if (!name.contains(query) && !phone.contains(query) && !city.contains(query) && !email.contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
