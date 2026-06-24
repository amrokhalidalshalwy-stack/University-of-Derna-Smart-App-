import 'package:flutter_project/core/services/error_tracking_service.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UniversityDatabaseSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String _computeSlotsHash(List<dynamic> slots) {
    final normalized = slots.map((s) => {
      'tname': s['tname'] ?? '',
      'rm':    s['rm']    ?? '',
      'd':     s['d']     ?? 0,
      'st':    s['st']    ?? '',
      'en':    s['en']    ?? '',
      'cid':   s['cid']   ?? '',
    }).toList();
    final jsonStr = jsonEncode(normalized);
    return sha256.convert(utf8.encode(jsonStr)).toString();
  }

  static Future<void> seedStudentData({
    required String currentUid,
    required String studentName,
    String? email,
  }) async {
    debugPrint('ðŸŒ± Smart Sync starting for: $studentName');

    try {
      final userDocRef = _firestore.collection('users').doc(currentUid);

      // 1. Ø¬Ù„Ø¨ Ø§Ù„Ø¬Ø¯ÙˆÙ„ Ø§Ù„Ø¹Ø§Ù„Ù…ÙŠ
      final globalDoc = await _firestore
          .collection('schedules')
          .doc('dept_cs')
          .get();

      if (!globalDoc.exists) {
        debugPrint('âš ï¸ dept_cs not found â€” aborting');
        return;
      }

      final List<dynamic> slots = globalDoc.data()?['slots'] ?? [];
      final String semester     = globalDoc.data()?['semester'] ?? '';
      final String newHash      = _computeSlotsHash(slots);

      // 2. Ù…Ù‚Ø§Ø±Ù†Ø© Ø§Ù„Ù€ hash â€” Ù‡Ù„ ØªØºÙŠÙ‘Ø± Ø´ÙŠØ¡ØŸ
      final userSnap   = await userDocRef.get();
      final cachedHash = userSnap.data()?['scheduleHash'] as String?;

      if (cachedHash == newHash) {
        debugPrint('âœ… No changes â€” skipping schedule write');
        await userDocRef.set({
          'name':      studentName,
          'email':     email ?? '',
          'role':      'student',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return;
      }

      debugPrint('ðŸ”„ Changes detected â€” syncing ${slots.length} slots...');

      // 3. ÙƒØ´Ù Ø§Ù„Ù…Ø³ØªÙ†Ø¯Ø§Øª Ø§Ù„ÙŠØªÙŠÙ…Ø©
      final oldSnap  = await _firestore.collection('schedules').where('user_id', isEqualTo: currentUid).get();
      final oldIds   = oldSnap.docs.map((d) => d.id).toSet();
      final newIds   = List.generate(slots.length, (i) => '${currentUid}_schedule_$i').toSet();
      final toDelete = oldIds.difference(newIds);

      final batch = _firestore.batch();

      // 4. ØªØ­Ø¯ÙŠØ« Ø¨ÙŠØ§Ù†Ø§Øª Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… + Ø­ÙØ¸ Ø§Ù„Ù€ hash
      batch.set(userDocRef, {
        'name':         studentName,
        'email':        email ?? '',
        'role':         'student',
        'scheduleHash': newHash,
        'updatedAt':    FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 5. ÙƒØªØ§Ø¨Ø© Ø§Ù„Ù€ slots â€” ØªØµØ­ÙŠØ­ tname âœ…
      for (int i = 0; i < slots.length; i++) {
        final slot = slots[i] as Map<String, dynamic>;
        final ref  = _firestore.collection('schedules').doc('${currentUid}_schedule_$i');

        batch.set(ref, {
          'user_id':      currentUid,
          'courseTitle':  slot['tname'] ?? 'Unknown', // âœ… tname ÙˆÙ„ÙŠØ³ trame
          'location':     slot['rm']    ?? 'N/A',
          'instructor':   'N/A',                      // Ø³ÙŠÙØ¶Ø§Ù Ù„Ø§Ø­Ù‚Ø§Ù‹
          'startTime':    slot['st']    ?? '00:00',
          'endTime':      slot['en']    ?? '00:00',
          'weekdayIndex': (slot['d'] as num?)?.toInt() ?? 0,
          'course_id':     slot['cid']   ?? '',
          'semester':     semester,
          'updatedAt':    FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // 6. Ø­Ø°Ù Ø§Ù„ÙŠØªÙŠÙ…Ø© ÙÙ‚Ø·
      for (final id in toDelete) {
        debugPrint('ðŸ—‘ï¸ Removing orphan: $id');
        batch.delete(_firestore.collection('schedules').doc(id));
      }

      await batch.commit();
      debugPrint('âœ… Sync complete: ${slots.length} slots, ${toDelete.length} removed');

    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(e, stackTrace, context: 'âŒ Error: \n$stackTrace');
      rethrow;
    }
  }

  static Future<void> seedSystemData() async {}
  static Future<void> wipeSystemData() async {}
  static Future<void> wipeStudentData(String uid) async {}
}