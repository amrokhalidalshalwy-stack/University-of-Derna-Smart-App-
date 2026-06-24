import * as admin from "firebase-admin";

admin.initializeApp();

export { syncAcademicRecords } from "./syncAcademicRecords";
export { assignUserRole } from "./setUserRole";
export { checkEmailExists } from "./checkEmailExists";
export { deleteUserAuth } from "./deleteUser";

import * as functions from 'firebase-functions';

/**
 * تُفعَّل عند حذف وثيقة مستخدم
 * تقوم بحذف كافة البيانات المرتبطة بالطالب
 */
export const onUserDeleted = functions.firestore
  .document('users/{userId}')
  .onDelete(async (snap, context) => {
    const userId = context.params.userId;
    const db = admin.firestore();
    const batch = db.batch();
    let operationCount = 0;

    const deleteCollection = async (
      query: admin.firestore.Query,
      batchRef: admin.firestore.WriteBatch
    ) => {
      const snapshot = await query.get();
      snapshot.docs.forEach(doc => {
        if (operationCount < 490) { // حماية من تجاوز حد الـ 500
          batchRef.delete(doc.ref);
          operationCount++;
        }
      });
    };

    // 1. حذف الدرجات
    await deleteCollection(
      db.collection('grades').where('student_id', '==', userId),
      batch
    );

    // 2. حذف سجلات الحضور
    await deleteCollection(
      db.collection('attendance').where('student_id', '==', userId),
      batch
    );

    // 3. حذف طلبات الطالب
    await deleteCollection(
      db.collection('student_requests').where('student_id', '==', userId),
      batch
    );

    // 4. حذف طلبات التجديد
    await deleteCollection(
      db.collection('renewal_requests').where('uid', '==', userId),
      batch
    );

    // 5. حذف تقدم الحفظ
    const hifzhRef = db.collection('hifzh_progress').doc(userId);
    batch.delete(hifzhRef);

    // 6. حذف الإشعارات (Subcollection)
    await deleteCollection(
      db.collection('users').doc(userId).collection('notifications'),
      batch
    );

    // 7. حذف التسجيلات (Subcollection)
    await deleteCollection(
      db.collection('users').doc(userId).collection('enrollments'),
      batch
    );

    // 8. تسجيل عملية الحذف في activityLogs
    batch.set(db.collection('activityLogs').doc(), {
      action: 'user_deleted',
      target_uid: userId,
      deleted_at: admin.firestore.FieldValue.serverTimestamp(),
      deleted_by: 'system_cascade',
    });

    await batch.commit();
    console.log(`✅ Cascade delete completed for user: ${userId}`);
  });

export const validateGradeOnWrite = functions.firestore
  .document('grades/{gradeId}')
  .onWrite(async (change, context) => {
    const newData = change.after.data();
    if (!newData) return; // حذف — لا مشكلة

    const midterm = newData.midterm ?? 0;
    const finalExam = newData.final_exam ?? 0;
    const totalScore = midterm + finalExam;

    // التحقق من صحة الدرجات
    if (
      midterm < 0 || midterm > 50 ||
      finalExam < 0 || finalExam > 50 ||
      totalScore > 100
    ) {
      // احذف الوثيقة المزيفة وسجّل المحاولة
      await change.after.ref.delete();
      await admin.firestore().collection('activityLogs').add({
        action: 'invalid_grade_rejected',
        grade_id: context.params.gradeId,
        attempted_data: newData,
        detected_at: admin.firestore.FieldValue.serverTimestamp(),
      });
      console.error(`🚨 تم رفض درجة مزيفة: ${context.params.gradeId}`);
    }
  });
