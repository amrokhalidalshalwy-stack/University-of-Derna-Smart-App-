// bootstrap_admin.js
// سكربت لمرة واحدة فقط: يضمن وجود وثيقة users/{uid} بحقل role == 'admin'
// لحساب أدمن موجود مسبقًا في Firebase Authentication.
// يستخدم Admin SDK الذي يتجاوز Firestore Security Rules بالكامل.
//
// 🔧 مُعدَّل لاستخدام الـ Modular API الرسمي لـ firebase-admin (v11+)
// بدل النمط القديم admin.credential.cert(...) الذي قد يُرجع undefined
// في بعض بيئات/إصدارات الحزمة بسبب تعارض في طريقة تصدير الموديول
// (CommonJS exports map). الاستيراد المباشر من المسارات الفرعية أدناه
// يتجنّب هذه المشكلة تمامًا بغض النظر عن إصدار الحزمة أو إعدادات المشروع.
//
// طريقة الاستخدام:
// 1) ثبّت الحزمة (مرة واحدة):
//      npm install firebase-admin
// 2) نزّل ملف مفتاح حساب الخدمة (Service Account) من:
//      Firebase Console → إعدادات المشروع → Service accounts → Generate new private key
//    وضعه بجانب هذا الملف باسم serviceAccountKey.json (لا ترفعه لأي مستودع عام).
// 3) عدّل المتغيرين ADMIN_UID و ADMIN_EMAIL أدناه ليطابقا حساب الأدمن الفعلي
//    (تجده في Firebase Console → Authentication → Users، انسخ User UID).
// 4) شغّل: node bootstrap_admin.js

const { initializeApp, cert, getApps } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const serviceAccount = require('./serviceAccountKey.json');

// تحقّق دفاعي: لا تُهيّئ التطبيق مرتين إن أُعيد تشغيل السكربت بسرعة
// (غير ضروري عمليًا في تشغيل واحد عبر node، لكنه أكثر أمانًا).
const app = getApps().length
  ? getApps()[0]
  : initializeApp({ credential: cert(serviceAccount) });

const db = getFirestore(app);

const ADMIN_UID = 'PUT_ADMIN_UID_HERE';
const ADMIN_EMAIL = 'admin@uod.edu.ly';
const ADMIN_NAME_AR = 'مدير النظام';

async function main() {
  const ref = db.collection('users').doc(ADMIN_UID);
  const existing = await ref.get();

  if (existing.exists) {
    console.log('الوثيقة موجودة حاليًا بالحقول التالية:');
    console.log(existing.data());
    await ref.set({ role: 'admin', status: 'approved' }, { merge: true });
    console.log('✅ تم تحديث role إلى "admin" بنجاح (مع الحفاظ على باقي الحقول).');
  } else {
    await ref.set({
      uid: ADMIN_UID,
      email: ADMIN_EMAIL,
      fullNameAr: ADMIN_NAME_AR,
      role: 'admin',
      status: 'approved',
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    console.log('✅ تم إنشاء وثيقة users/{uid} جديدة للأدمن بنجاح.');
  }

  const finalDoc = await ref.get();
  console.log('الحالة النهائية لوثيقة الأدمن:', finalDoc.data());
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('❌ فشل السكربت:', err);
    process.exit(1);
  });