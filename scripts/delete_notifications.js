const fs = require("fs");
const path = require("path");
const { initializeApp, cert, getApps } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

// ─────────────────────────────────────────────────────────────────────────────
// تهيئة Firebase Admin SDK
// ─────────────────────────────────────────────────────────────────────────────

function key() {
  const r = path.resolve(__dirname, "./serviceAccountKey.json");
  if (fs.existsSync(r)) return r;
  throw new Error("❌ ملف حساب الخدمة serviceAccountKey.json غير موجود في مجلد scripts!");
}

function init() {
  if (getApps().length === 0) {
    const accountData = JSON.parse(fs.readFileSync(key(), "utf8"));
    initializeApp({ credential: cert(accountData) });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// حذف المستندات من مجموعة notifications العامة
// ─────────────────────────────────────────────────────────────────────────────

async function deleteGlobalNotifications(db) {
  const notificationsRef = db.collection("notifications");
  const snapshot = await notificationsRef.get();
  
  if (snapshot.empty) {
    console.log("✅ مجموعة notifications العامة فارغة بالفعل");
    return 0;
  }
  
  const batch = db.batch();
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });
  
  await batch.commit();
  return snapshot.size;
}

// ─────────────────────────────────────────────────────────────────────────────
// حذف المستندات من مجموعة notifications الفرعية لمستخدم
// ─────────────────────────────────────────────────────────────────────────────

async function deleteUserNotifications(db, uid) {
  const notificationsRef = db.collection("users").doc(uid).collection("notifications");
  const snapshot = await notificationsRef.get();
  
  if (snapshot.empty) return 0;
  
  const batch = db.batch();
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });
  
  await batch.commit();
  return snapshot.size;
}

// ─────────────────────────────────────────────────────────────────────────────
// حذف جميع المستندات من جميع مجموعات notifications الفرعية
// ─────────────────────────────────────────────────────────────────────────────

async function deleteAllUserNotifications(db) {
  const usersRef = db.collection("users");
  const usersSnapshot = await usersRef.listDocuments();
  
  let totalDeleted = 0;
  for (const userDoc of usersSnapshot) {
    const uid = userDoc.id;
    const deleted = await deleteUserNotifications(db, uid);
    if (deleted > 0) {
      console.log(`  ✓ حذف ${deleted} إشعار من المستخدم ${uid}`);
      totalDeleted += deleted;
    }
  }
  
  return totalDeleted;
}

// ─────────────────────────────────────────────────────────────────────────────
// الدالة الرئيسية
// ─────────────────────────────────────────────────────────────────────────────

async function main() {
  try {
    init();
    const db = getFirestore();

    console.log("⏳ جاري حذف جميع مستندات الإشعارات مع الحفاظ على المسار...\n");

    // حذف الإشعارات العامة
    console.log("🗑️  جاري حذف الإشعارات العامة (notifications)...");
    const globalDeleted = await deleteGlobalNotifications(db);
    console.log(`✅ تم حذف ${globalDeleted} إشعار من مجموعة notifications العامة\n`);

    // حذف إشعارات المستخدمين
    console.log("🗑️  جاري حذف إشعارات المستخدمين (users/{uid}/notifications)...");
    const userDeleted = await deleteAllUserNotifications(db);
    console.log(`✅ تم حذف ${userDeleted} إشعار من مجموعات المستخدمين\n`);

    const totalDeleted = globalDeleted + userDeleted;
    console.log(`🎉 تم الحذف بنجاح! الإجمالي: ${totalDeleted} مستند`);
    console.log("📝 المسارات محفوظة ويمكن إضافة مستندات جديدة مستقبلاً");

  } catch (error) {
    console.error("❌ حدث خطأ أثناء تنفيذ السكربت:", error.message || error);
    process.exit(1);
  } finally {
    process.exit(0);
  }
}

main().catch(err => {
  console.error("❌ خطأ حرج في السكربت:", err);
  process.exit(1);
});
