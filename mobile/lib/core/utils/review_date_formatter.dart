import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore yorum tarihlerini Google seed formatına yakın gösterir (ör. "2 ay önce").
class ReviewDateFormatter {
  ReviewDateFormatter._();

  static String format({dynamic date, dynamic createdAt}) {
    if (date is String && date.trim().isNotEmpty) {
      return date.trim();
    }

    final dateTime = _toDateTime(createdAt);
    if (dateTime == null) return '';

    return _relativeTurkish(dateTime);
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  static String _relativeTurkish(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);

    if (diff.isNegative) return 'az önce';

    if (diff.inDays == 0) {
      if (diff.inHours < 1) return 'az önce';
      if (diff.inHours == 1) return '1 saat önce';
      return '${diff.inHours} saat önce';
    }
    if (diff.inDays == 1) return 'dün';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';

    final weeks = diff.inDays ~/ 7;
    if (diff.inDays < 30) {
      return weeks == 1 ? 'bir hafta önce' : '$weeks hafta önce';
    }

    final months = diff.inDays ~/ 30;
    if (diff.inDays < 365) {
      return months == 1 ? 'bir ay önce' : '$months ay önce';
    }

    final years = diff.inDays ~/ 365;
    return years == 1 ? 'bir yıl önce' : '$years yıl önce';
  }
}
