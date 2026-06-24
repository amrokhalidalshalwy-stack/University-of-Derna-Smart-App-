import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_project/core/services/error_tracking_service.dart';

class SmartDataSeeder {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> seedDatabase() async {
    try {
      debugPrint('🚀 [SmartDataSeeder] Starting Relational Seed Process...');

      int facultyCount = 0;
      int studentsCount = 0;
      int coursesCount = 0;
      int excusesCount = 0;
      int renewalsCount = 0;
      int examPapersCount = 0;
      int notificationsCount = 0;

      final List<String> skipped = [];

      Future<bool> createDocIfMissing(
        String collection,
        String docId,
        Map<String, dynamic> data,
      ) async {
        final docRef = _db.collection(collection).doc(docId);
        final snapshot = await docRef.get();
        if (snapshot.exists) {
          debugPrint('⏭️ موجود مسبقاً: [$docId]');
          skipped.add(docId);
          return false;
        } else {
          await docRef.set(data);
          debugPrint('✅ تم إنشاء: [$docId]');
          return true;
        }
      }

      // 1️⃣ أعضاء هيئة التدريس
      final facultyData = [
        {
          "uid": "faculty_001",
          "fullName": "د. أحمد محمد الورفلي",
          "email": "ahmed.warfali@uod.edu.ly",
          "role": "faculty",
          "departmentId": "dept_cs",
          "courses": ["course_001", "course_002"],
          "notifications": [],
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "uid": "faculty_002",
          "fullName": "د. فاطمة علي المبروك",
          "email": "fatima.mabrouk@uod.edu.ly",
          "role": "faculty",
          "departmentId": "dept_cs",
          "courses": ["course_003"],
          "notifications": [],
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "uid": "faculty_003",
          "fullName": "د. خالد إبراهيم الدرسي",
          "email": "khaled.darsi@uod.edu.ly",
          "role": "faculty",
          "departmentId": "dept_eng",
          "courses": ["course_004"],
          "notifications": [],
          "createdAt": FieldValue.serverTimestamp(),
        },
      ];

      for (var f in facultyData) {
        if (await createDocIfMissing('users', f['uid'] as String, f)) {
          facultyCount++;
        }
      }

      // 2️⃣ الطلاب
      final studentsData = [
        {
          "uid": "student_001",
          "fullName": "محمد سالم البرغثي",
          "email": "m.barghathi@student.uod.edu.ly",
          "role": "student",
          "departmentId": "dept_cs",
          "major": "علوم الحاسوب",
          "gpa": "3.45",
          "completedHours": 87,
          "semester": "الفصل الثاني 2025-2026",
          "courses": ["course_001", "course_002", "course_003"],
          "notifications": [],
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "uid": "student_002",
          "fullName": "سارة عبدالله الكيلاني",
          "email": "s.kilani@student.uod.edu.ly",
          "role": "student",
          "departmentId": "dept_cs",
          "major": "علوم الحاسوب",
          "gpa": "3.80",
          "completedHours": 92,
          "semester": "الفصل الثاني 2025-2026",
          "courses": ["course_001", "course_003"],
          "notifications": [],
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "uid": "student_003",
          "fullName": "عمر فرج الهوني",
          "email": "o.houni@student.uod.edu.ly",
          "role": "student",
          "departmentId": "dept_cs",
          "major": "علوم الحاسوب",
          "gpa": "2.90",
          "completedHours": 65,
          "semester": "الفصل الثاني 2025-2026",
          "courses": ["course_002", "course_003"],
          "notifications": [],
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "uid": "student_004",
          "fullName": "نور الدين مصطفى الزوي",
          "email": "n.zawi@student.uod.edu.ly",
          "role": "student",
          "departmentId": "dept_eng",
          "major": "هندسة الحاسوب",
          "gpa": "3.10",
          "completedHours": 74,
          "semester": "الفصل الثاني 2025-2026",
          "courses": ["course_004"],
          "notifications": [],
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "uid": "student_005",
          "fullName": "ريم حسن العقوري",
          "email": "r.aqouri@student.uod.edu.ly",
          "role": "student",
          "departmentId": "dept_cs",
          "major": "علوم الحاسوب",
          "gpa": "3.60",
          "completedHours": 80,
          "semester": "الفصل الثاني 2025-2026",
          "courses": ["course_001", "course_002"],
          "notifications": [],
          "createdAt": FieldValue.serverTimestamp(),
        },
        {
          "uid": "student_006",
          "fullName": "يوسف طاهر المغربي",
          "email": "y.maghribi@student.uod.edu.ly",
          "role": "student",
          "departmentId": "dept_eng",
          "major": "هندسة الحاسوب",
          "gpa": "2.75",
          "completedHours": 58,
          "semester": "الفصل الثاني 2025-2026",
          "courses": ["course_004"],
          "notifications": [],
          "createdAt": FieldValue.serverTimestamp(),
        },
      ];

      for (var s in studentsData) {
        if (await createDocIfMissing('users', s['uid'] as String, s)) {
          studentsCount++;
        }
      }

      // 3️⃣ المقررات
      final coursesData = [
        {
          "id": "course_001",
          "name": "برمجة الويب",
          "code": "CS301",
          "facultyUid": "faculty_001",
          "departmentId": "dept_cs",
          "enrolledStudents": ["student_001", "student_002", "student_005"],
          "schedule": "الأحد والثلاثاء 10:00-12:00",
          "room": "قاعة A3",
        },
        {
          "id": "course_002",
          "name": "تحليل الأنظمة",
          "code": "CS302",
          "facultyUid": "faculty_001",
          "departmentId": "dept_cs",
          "enrolledStudents": ["student_001", "student_003", "student_005"],
          "schedule": "الاثنين والأربعاء 08:00-10:00",
          "room": "قاعة B1",
        },
        {
          "id": "course_003",
          "name": "قواعد البيانات المتقدمة",
          "code": "CS303",
          "facultyUid": "faculty_002",
          "departmentId": "dept_cs",
          "enrolledStudents": ["student_001", "student_002", "student_003"],
          "schedule": "الثلاثاء والخميس 12:00-14:00",
          "room": "مختبر CS2",
        },
        {
          "id": "course_004",
          "name": "معالجات الإشارات الرقمية",
          "code": "ENG401",
          "facultyUid": "faculty_003",
          "departmentId": "dept_eng",
          "enrolledStudents": ["student_004", "student_006"],
          "schedule": "الأحد والثلاثاء 14:00-16:00",
          "room": "قاعة Eng5",
        },
      ];

      for (var c in coursesData) {
        if (await createDocIfMissing('courses', c['id'] as String, c)) {
          coursesCount++;
        }
      }

      // 4️⃣ عذر غياب
      final excuseData = {
        "id": "excuse_001",
        "studentUid": "student_001",
        "studentName": "محمد سالم البرغثي",
        "courseId": "course_001",
        "courseName": "برمجة الويب",
        "facultyUid": "faculty_001",
        "facultyName": "د. أحمد محمد الورفلي",
        "absenceDate": "2026-06-05",
        "reason": "مراجعة طبية طارئة",
        "excuseType": "medical",
        "attachmentUrl": "https://placeholder.com/medical_report.pdf",
        "status": "pending",
        "submittedAt": FieldValue.serverTimestamp(),
        "reviewedAt": null,
        "facultyNote": null,
      };

      if (await createDocIfMissing(
        'absence_excuses',
        excuseData['id'] as String,
        excuseData,
      )) {
        excusesCount++;
      }

      final notifFacRef = _db
          .collection('users')
          .doc('faculty_001')
          .collection('notifications')
          .doc('notif_faculty_001');
      if (!(await notifFacRef.get()).exists) {
        await notifFacRef.set({
          "id": "notif_faculty_001",
          "userUid": "faculty_001",
          "title": "عذر غياب جديد — برمجة الويب",
          "body":
              "قدّم محمد سالم البرغثي عذراً طبياً بتاريخ 2026-06-05. يرجى المراجعة.",
          "category": "excuse",
          "relatedId": "excuse_001",
          "isRead": false,
          "createdAtMs": DateTime.now().millisecondsSinceEpoch,
        });
        notificationsCount++;
      }

      final notifStuRef = _db
          .collection('users')
          .doc('student_001')
          .collection('notifications')
          .doc('notif_student_001_a');
      if (!(await notifStuRef.get()).exists) {
        await notifStuRef.set({
          "id": "notif_student_001_a",
          "userUid": "student_001",
          "title": "تم استلام عذرك",
          "body":
              "تم إرسال عذر الغياب لمادة برمجة الويب بنجاح. في انتظار موافقة الدكتور.",
          "category": "excuse",
          "relatedId": "excuse_001",
          "isRead": false,
          "createdAtMs": DateTime.now().millisecondsSinceEpoch,
        });
        notificationsCount++;
      }

      // 5️⃣ تجديد القيد
      final renewalData = {
        "id": "renewal_001",
        "studentUid": "student_002",
        "studentName": "سارة عبدالله الكيلاني",
        "semester": "الفصل الأول 2026-2027",
        "paymentMethod": "Libyan Banking Services",
        "paymentReference": "LBS-2026-00441",
        "status": "pending",
        "submittedAt": FieldValue.serverTimestamp(),
        "adminNote": null,
      };

      if (await createDocIfMissing(
        'registrationRenewals',
        renewalData['id'] as String,
        renewalData,
      )) {
        renewalsCount++;
      }

      if (await createDocIfMissing('notifications', 'notif_admin_001', {
        "id": "notif_admin_001",
        "userUid": "admin_001",
        "title": "طلب تجديد قيد جديد",
        "body": "سارة عبدالله الكيلاني تطلب تجديد القيد للفصل الأول 2026-2027.",
        "category": "renewal",
        "relatedId": "renewal_001",
        "isRead": false,
        "createdAtMs": DateTime.now().millisecondsSinceEpoch,
      })) {
        notificationsCount++;
      }

      // 6️⃣ أوراق الامتحانات
      final examPapersData = [
        {
          "id": "paper_001",
          "courseId": "course_001",
          "courseName": "برمجة الويب",
          "facultyUid": "faculty_001",
          "type": "quiz",
          "title": "اختبار الوحدة الأولى",
          "maxScore": 10,
          "date": "2026-04-15",
          "visibleToStudents": true,
          "scores": {
            "student_001": 8.5,
            "student_002": 9.0,
            "student_005": 7.5,
          },
        },
        {
          "id": "paper_002",
          "courseId": "course_001",
          "courseName": "برمجة الويب",
          "facultyUid": "faculty_001",
          "type": "midterm",
          "title": "الامتحان النصفي",
          "maxScore": 30,
          "date": "2026-05-01",
          "visibleToStudents": true,
          "scores": {"student_001": 24, "student_002": 27, "student_005": 21},
        },
        {
          "id": "paper_003",
          "courseId": "course_001",
          "courseName": "برمجة الويب",
          "facultyUid": "faculty_001",
          "type": "final",
          "title": "الامتحان النهائي",
          "maxScore": 60,
          "date": "2026-06-20",
          "visibleToStudents": false,
          "scores": {},
        },
      ];

      for (var ep in examPapersData) {
        if (await createDocIfMissing('examPapers', ep['id'] as String, ep)) {
          examPapersCount++;
        }
      }

      debugPrint('''
══════════════════════════════════════════
📊 تقرير حقن البيانات — جامعة درنة
══════════════════════════════════════════
✅ أعضاء هيئة التدريس : $facultyCount/3
✅ الطلاب              : $studentsCount/6
✅ المقررات            : $coursesCount/4
✅ عذر الغياب          : $excusesCount/1
✅ تجديد القيد         : $renewalsCount/1
✅ أوراق الامتحانات    : $examPapersCount/3
✅ الإشعارات           : $notificationsCount/3
══════════════════════════════════════════
⚠️  بيانات مكررة تم تخطيها: ${skipped.isEmpty ? "لا يوجد" : skipped.join(', ')}
══════════════════════════════════════════
      ''');
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(
        e,
        stackTrace, // ← إصلاح: st ➔ stackTrace
        context: '❌ [SmartDataSeeder] Error during seeding',
      );
    }
  }
}
