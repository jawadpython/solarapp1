import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DateFormatter {
  static String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      return 'N/A';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Il y a quelques secondes';
        }
        return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
      }
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else {
      return DateFormat('dd MMM yyyy — HH:mm', 'fr').format(dateTime);
    }
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'fr').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy — HH:mm', 'fr').format(date);
  }
}

