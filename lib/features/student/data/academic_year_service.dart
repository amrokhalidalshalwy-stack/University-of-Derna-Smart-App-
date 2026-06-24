import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for fetching academic year settings from Firestore.
/// This allows the administration to update fees, deadlines, and other
/// academic year settings without requiring an app update.
class AcademicYearService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches the current academic year settings from Firestore.
  /// 
  /// Document path: system_settings/academic_year
  /// 
  /// Expected structure:
  /// {
  ///   "academicYear": "2026/2027",
  ///   "feesAmount": "150 LYD",
  ///   "deadline": "15 سبتمبر 2026",
  ///   "isOpen": true,
  ///   "updatedAt": timestamp
  /// }
  static Future<Map<String, dynamic>> getAcademicYearSettings() async {
    try {
      final doc = await _db.collection('system_settings').doc('academic_year').get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      
      // Return default values if document doesn't exist
      return _getDefaultSettings();
    } catch (e) {
      // Return default values on error
      return _getDefaultSettings();
    }
  }

  /// Stream of academic year settings for real-time updates.
  static Stream<Map<String, dynamic>> watchAcademicYearSettings() {
    return _db
        .collection('system_settings')
        .doc('academic_year')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      }
      return _getDefaultSettings();
    });
  }

  /// Default fallback settings when Firestore is unavailable.
  static Map<String, dynamic> _getDefaultSettings() {
    return {
      'academicYear': '2026/2027',
      'feesAmount': '150 LYD',
      'deadline': '15 سبتمبر 2026',
      'isOpen': true,
    };
  }
}
