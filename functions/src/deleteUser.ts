import * as admin from "firebase-admin";
import { https } from 'firebase-functions/v1';

/**
 * Cloud Function لحذف مستخدم من Firebase Authentication
 * تُستدعى عند رفض طلب التسجيل من قبل المسؤول
 */
export const deleteUserAuth = https.onCall(async (data: { uid: string }, context: https.CallableContext) => {
  // التحقق من صلاحية المستخدم (يجب أن يكون admin)
  if (!context.auth) {
    throw new https.HttpsError(
      'unauthenticated',
      'يجب تسجيل الدخول'
    );
  }

  const callerUid = context.auth.uid;
  const db = admin.firestore();

  // التحقق من أن المستخدم هو admin
  const adminDoc = await db.collection('users').doc(callerUid).get();
  if (!adminDoc.exists || adminDoc.data()?.['role'] !== 'admin') {
    throw new https.HttpsError(
      'permission-denied',
      'غير مصرح: ليس لديك صلاحية admin'
    );
  }

  const targetUid = data.uid;
  
  if (!targetUid) {
    throw new https.HttpsError(
      'invalid-argument',
      'uid مطلوب'
    );
  }

  try {
    // حذف المستخدم من Firebase Authentication
    await admin.auth().deleteUser(targetUid);
    
    console.log(`✅ تم حذف المستخدم من Firebase Auth: ${targetUid}`);
    
    return { success: true, uid: targetUid };
  } catch (error: any) {
    console.error(`❌ خطأ في حذف المستخدم: ${error}`);
    
    // إذا كان المستخدم غير موجود في Firebase Auth، نعتبر العملية ناجحة
    // لأن الهدف هو التأكد من عدم وجوده
    if (error.code === 'auth/user-not-found') {
      console.log(`ℹ️ المستخدم غير موجود في Firebase Auth: ${targetUid}`);
      return { success: true, uid: targetUid, note: 'user_not_found' };
    }
    
    throw new https.HttpsError(
      'internal',
      'فشل حذف المستخدم من Firebase Authentication'
    );
  }
});
