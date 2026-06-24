// admin_service.dart — Riverpod provider for admin Firestore operations
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/core/constants/app_roles.dart';

final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService(
    ref.read(firestoreProvider),
  );
});

// Stream of all registration documents (for verification queue)
final registrationsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  return ref
      .read(firestoreProvider)
      .collection('registrations')
      .orderBy('submittedAt', descending: true)
      .snapshots()
      .map((snap) {
        final docs = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        return docs;
      });
});

class AdminService {
  final FirebaseFirestore _db;
  AdminService(this._db);

  /// Approves a student registration.
  /// بناءً على فكرتك: يتم نقل البيانات وإنشاء حساب المستخدم في الفايرستور (users) لأول مرة هنا فقط
  Future<void> approveStudent({required String uid, String notes = ''}) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('غير مسجل الدخول');

    final adminUserDoc = await _db.collection('users').doc(currentUser.uid).get();
    final role = adminUserDoc.data()?['role'] ?? '';
    if (role != 'admin') throw Exception('غير مصرح: ليس لديك صلاحية admin');

    final now = FieldValue.serverTimestamp();
    final adminUid = currentUser.uid;

    // جلب بيانات طلب التسجيل بالكامل
    final regDoc = await _db.collection('registrations').doc(uid).get();
    if (!regDoc.exists) throw Exception('طلب التسجيل غير موجود');
    final regData = regDoc.data() ?? {};

    final batch = _db.batch();

    // 1. تحديث حالة طلب التسجيل إلى مقبول
    batch.update(_db.collection('registrations').doc(uid), {
      'status': RegistrationStatus.approved.value,
      'adminUid': adminUid,
      'adminNotes': notes,
      'decisionDate': now,
    });

    // 2. تفعيل فكرتك: إنشاء مستند الطالب في مجموعة الـ users لأول مرة بنقل بياناته بالكامل
    final userDocumentRef = _db.collection('users').doc(uid);
    
    final newUserProfile = <String, dynamic>{
      'uid': uid,
      'email': regData['email'] ?? '',
      'fullName': regData['fullNameAr'] ?? '', // الاسم المعروض الافتراضي
      'fullNameAr': regData['fullNameAr'] ?? '',
      'fullNameEn': regData['fullNameEn'] ?? '',
      'phone': regData['phone'] ?? '',
      'national_id': regData['nationalId'] ?? '',
      'gender': regData['gender'] ?? '',
      'major': regData['department'] ?? regData['faculty'] ?? '',
      'faculty': regData['faculty'] ?? '',
      'department': regData['department'] ?? '',
      'university_id': regData['universityId'] ?? regData['id'] ?? 'UOD-${regData['nationalId'] ?? uid.substring(0,5)}', // توليد رقم قيد تلقائي إن لم يوجد
      'role': 'student', // تحديد الصلاحية كطالب
      'status': RegistrationStatus.approved.value,
      'gpa': '0.00', // قيم ابتدائية للسجل الأكاديمي
      'completed_hours': 0,
      'createdAt': regData['submittedAt'] ?? now,
      'updatedAt': now,
      'enrollmentDate': now,
    };

    // استخدام set مع مرونة الدمج لضمان إنشاء المستند بشكل كامل وصحيح
    batch.set(userDocumentRef, newUserProfile, SetOptions(merge: true));

    await batch.commit();

    // إرسال بريد إلكتروني تلقائي بالقبول
    await _queueEmail(
      uid: uid,
      email: regData['email'] ?? '',
      fullNameAr: regData['fullNameAr'] ?? '',
      templateType: 'approved',
      subject: 'تم قبول طلب إنشاء حسابك ✓ - جامعة درنة',
      body:
          'عزيزي ${regData['fullNameAr'] ?? ''}،\n\nيسعدنا إعلامك بأنه تم تفعيل وقبول طلب إنشاء حسابك في منظومة جامعة درنة من قبل مدير النظام.\n\nيمكنك الآن تسجيل الدخول مباشرة باستخدام بريدك الإلكتروني والكلمة المرور الخاصة بك عبر بوابة الطلاب.\n\nبالتوفيق والنجاح.\nإدارة المسجل العام.',
    );

    // تسجيل العملية في سجل النشاطات للأمان
    await _log(adminUid: adminUid, action: 'approved_and_created', targetUid: uid);
  }

  /// Rejects a student registration.
  /// في حالة الرفض: يتم حذف المستندات بالكامل من كل من المجموعتين registrations و users
  /// بالإضافة إلى حذف المستخدم من Firebase Authentication
  Future<void> rejectStudent({
    required String uid,
    required String reason,
    String notes = '',
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('غير مسجل الدخول');

    final adminUserDoc = await _db.collection('users').doc(currentUser.uid).get();
    final role = adminUserDoc.data()?['role'] ?? '';
    if (role != 'admin') throw Exception('غير مصرح: ليس لديك صلاحية admin');

    final adminUid = currentUser.uid;

    // جلب بيانات البريد لإرسال إشعار بالرفض قبل الحذف
    final regDoc = await _db.collection('registrations').doc(uid).get();
    final data = regDoc.data() ?? {};

    // حذف المستخدم من Firebase Authentication باستخدام Cloud Function
    try {
      final functions = FirebaseFunctions.instance;
      await functions.httpsCallable('deleteUserAuth').call({'uid': uid});
      debugPrint('✅ تم حذف المستخدم من Firebase Auth: $uid');
    } catch (e) {
      debugPrint('⚠️ فشل حذف المستخدم من Firebase Auth: $e');
      // نستمر في الحذف من Firestore حتى لو فشل حذف Firebase Auth
    }

    // حذف المستندات بالكامل من كلا المجموعتين
    await _db.collection('registrations').doc(uid).delete();
    await _db.collection('users').doc(uid).delete();

    // إرسال إشعار بالرفض
    await _queueEmail(
      uid: uid,
      email: data['email'] ?? '',
      fullNameAr: data['fullNameAr'] ?? '',
      templateType: 'rejected',
      subject: 'تحديث حول طلب إنشاء الحساب - جامعة درنة',
      body:
          'عزيزي ${data['fullNameAr'] ?? ''}،\n\nنعتذر لإعلامك بأنه تم رفض طلب إنشاء حسابك في المنظومة.\nالسبب: $reason\n\nيرجى مراجعة إدارة المسجل العام أو إعادة التقديم ببيانات صحيحة.',
    );

    await _log(
      adminUid: adminUid,
      action: 'rejected_request',
      targetUid: uid,
      detail: reason,
    );
  }

  Future<void> _queueEmail({
    required String uid,
    required String email,
    required String fullNameAr,
    required String templateType,
    required String subject,
    required String body,
  }) async {
    await _db.collection('emailQueue').add({
      'uid': uid,
      'recipientEmail': email,
      'subject': subject,
      'body': body,
      'templateType': templateType,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _log({
    required String adminUid,
    required String action,
    required String targetUid,
    String detail = '',
  }) async {
    await _db.collection('activityLogs').add({
      'adminUid': adminUid,
      'action': action,
      'targetUid': targetUid,
      'detail': detail,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}