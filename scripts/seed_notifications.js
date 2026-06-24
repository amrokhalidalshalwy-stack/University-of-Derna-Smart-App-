const fs = require("fs");
const path = require("path");
const { initializeApp, cert, getApps } = require("firebase-admin/app");
const { getFirestore, FieldValue, Timestamp } = require("firebase-admin/firestore");
const { getAuth } = require("firebase-admin/auth");

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
// بيانات المستخدمين
// ─────────────────────────────────────────────────────────────────────────────

const USERS = {
  students: [
    { email: "ahmed.ali@uod.edu.ly", name: "أحمد محمد علي" },
    { email: "fatima.omar@uod.edu.ly", name: "فاطمة عمر المبروك" },
    { email: "ali.hassan@uod.edu.ly", name: "علي حسن الورفلي" },
  ],
  faculty: [
    { email: "layla.hassan@uod.edu.ly", name: "د. ليلى خالد الحسن" },
    { email: "khaled.abdallah@uod.edu.ly", name: "د. خالد عبد الله" },
  ],
  admin: [
    { email: "admin@uod.edu.ly", name: "مدير النظام" },
  ],
};

// ─────────────────────────────────────────────────────────────────────────────
// الإشعارات المترابطة (8 أحداث)
// ─────────────────────────────────────────────────────────────────────────────

const EVENTS = [
  // [حدث 1] رصد درجة أحمد في CS401 برمجة متقدمة: 87/100
  {
    id: 1,
    type: "grade",
    recipients: [
      { role: "student", email: "ahmed.ali@uod.edu.ly", title: "درجة جديدة — برمجة متقدمة", body: "تم رصد درجتك في CS401: 87/100", isRead: false },
      { role: "faculty", email: "layla.hassan@uod.edu.ly", title: "تم رفع درجة طالب", body: "تم تسجيل درجة أحمد محمد علي في CS401: 87/100", isRead: true },
      { role: "admin", email: "admin@uod.edu.ly", title: "رصد درجة — CS401", body: "تم رصد درجة أحمد محمد علي في برمجة متقدمة: 87/100", isRead: true },
    ],
    hoursAgo: 72, // قبل 3 أيام
  },
  // [حدث 2] رصد درجة فاطمة في CS405 الذكاء الاصطناعي: 91/100
  {
    id: 2,
    type: "grade",
    recipients: [
      { role: "student", email: "fatima.omar@uod.edu.ly", title: "درجة جديدة — الذكاء الاصطناعي", body: "تم رصد درجتك في CS405: 91/100", isRead: false },
      { role: "faculty", email: "khaled.abdallah@uod.edu.ly", title: "تم رفع درجة طالبة", body: "تم تسجيل درجة فاطمة عمر المبروك في CS405: 91/100", isRead: true },
      { role: "admin", email: "admin@uod.edu.ly", title: "رصد درجة — CS405", body: "تم رصد درجة فاطمة عمر المبروك في الذكاء الاصطناعي: 91/100", isRead: true },
    ],
    hoursAgo: 60, // قبل 2.5 يوم
  },
  // [حدث 3] رصد درجة علي في CS408 الأمن السيبراني: 65/100
  {
    id: 3,
    type: "grade",
    recipients: [
      { role: "student", email: "ali.hassan@uod.edu.ly", title: "درجة جديدة — الأمن السيبراني", body: "تم رصد درجتك في CS408: 65/100", isRead: false },
      { role: "faculty", email: "khaled.abdallah@uod.edu.ly", title: "تم رفع درجة طالب", body: "تم تسجيل درجة علي حسن الورفلي في CS408: 65/100", isRead: true },
      { role: "admin", email: "admin@uod.edu.ly", title: "رصد درجة — CS408", body: "تم رصد درجة علي حسن الورفلي في الأمن السيبراني: 65/100", isRead: true },
    ],
    hoursAgo: 48, // قبل يومين
  },
  // [حدث 4] تجاوز أحمد نسبة الغياب في CS303 شبكات حاسوب
  {
    id: 4,
    type: "تنبيه",
    recipients: [
      { role: "student", email: "ahmed.ali@uod.edu.ly", title: "تحذير غياب — شبكات حاسوب", body: "تجاوزت 20% من نسبة الغياب في CS303", isRead: false },
      { role: "faculty", email: "layla.hassan@uod.edu.ly", title: "طالب تجاوز حد الغياب", body: "أحمد محمد علي تجاوز 20% غياب في CS303 شبكات حاسوب", isRead: true },
      { role: "admin", email: "admin@uod.edu.ly", title: "تنبيه غياب — CS303", body: "أحمد محمد علي تجاوز نسبة الغياب المسموح بها في شبكات حاسوب", isRead: true },
    ],
    hoursAgo: 24, // قبل يوم واحد
  },
  // [حدث 5] تجاوز علي نسبة الغياب في CS405 الذكاء الاصطناعي
  {
    id: 5,
    type: "تنبيه",
    recipients: [
      { role: "student", email: "ali.hassan@uod.edu.ly", title: "تحذير غياب — الذكاء الاصطناعي", body: "تجاوزت 20% من نسبة الغياب في CS405", isRead: false },
      { role: "faculty", email: "khaled.abdallah@uod.edu.ly", title: "طالب تجاوز حد الغياب", body: "علي حسن الورفلي تجاوز 20% غياب في CS405 الذكاء الاصطناعي", isRead: true },
      { role: "admin", email: "admin@uod.edu.ly", title: "تنبيه غياب — CS405", body: "علي حسن الورفلي تجاوز نسبة الغياب المسموح بها في الذكاء الاصطناعي", isRead: true },
    ],
    hoursAgo: 20, // قبل 20 ساعة
  },
  // [حدث 6] طلب تجديد قيد من فاطمة
  {
    id: 6,
    type: "تنبيه",
    recipients: [
      { role: "student", email: "fatima.omar@uod.edu.ly", title: "طلب تجديد القيد", body: "تم استلام طلب تجديد قيدك وهو قيد المراجعة", isRead: false },
      { role: "admin", email: "admin@uod.edu.ly", title: "طلب تجديد قيد جديد", body: "فاطمة عمر المبروك تقدمت بطلب تجديد قيد — يتطلب مراجعة", isRead: true },
    ],
    hoursAgo: 5, // قبل 5 ساعات
  },
  // [حدث 7] إعلان عام — جدول الامتحانات النهائية (للجميع)
  {
    id: 7,
    type: "إعلان",
    recipients: [
      { role: "student", email: "ahmed.ali@uod.edu.ly", title: "إعلان — جدول الامتحانات النهائية", body: "تم نشر جدول الامتحانات النهائية للفصل الثاني عبر البوابة الإلكترونية", isRead: false },
      { role: "student", email: "fatima.omar@uod.edu.ly", title: "إعلان — جدول الامتحانات النهائية", body: "تم نشر جدول الامتحانات النهائية للفصل الثاني عبر البوابة الإلكترونية", isRead: false },
      { role: "student", email: "ali.hassan@uod.edu.ly", title: "إعلان — جدول الامتحانات النهائية", body: "تم نشر جدول الامتحانات النهائية للفصل الثاني عبر البوابة الإلكترونية", isRead: false },
      { role: "faculty", email: "layla.hassan@uod.edu.ly", title: "إعلان — جدول الامتحانات النهائية", body: "تم نشر جدول الامتحانات النهائية للفصل الثاني عبر البوابة الإلكترونية", isRead: true },
      { role: "faculty", email: "khaled.abdallah@uod.edu.ly", title: "إعلان — جدول الامتحانات النهائية", body: "تم نشر جدول الامتحانات النهائية للفصل الثاني عبر البوابة الإلكترونية", isRead: true },
      { role: "admin", email: "admin@uod.edu.ly", title: "إعلان — جدول الامتحانات النهائية", body: "تم نشر جدول الامتحانات النهائية للفصل الثاني عبر البوابة الإلكترونية", isRead: true },
    ],
    hoursAgo: 3, // قبل 3 ساعات
  },
  // [حدث 8] إعلان عام — اجتماع مجلس القسم (للأساتذة والإدارة فقط)
  {
    id: 8,
    type: "إعلان",
    recipients: [
      { role: "faculty", email: "layla.hassan@uod.edu.ly", title: "اجتماع مجلس القسم", body: "اجتماع مجلس قسم علوم الحاسوب الأحد القادم الساعة 11 صباحاً", isRead: true },
      { role: "faculty", email: "khaled.abdallah@uod.edu.ly", title: "اجتماع مجلس القسم", body: "اجتماع مجلس قسم علوم الحاسوب الأحد القادم الساعة 11 صباحاً", isRead: true },
      { role: "admin", email: "admin@uod.edu.ly", title: "اجتماع مجلس القسم", body: "اجتماع مجلس قسم علوم الحاسوب الأحد القادم — 3 أعضاء مدعوون", isRead: true },
    ],
    hoursAgo: 2, // قبل ساعتين
  },
];

// ─────────────────────────────────────────────────────────────────────────────
// دوال مساعدة
// ─────────────────────────────────────────────────────────────────────────────

function getCreatedAtOffset(hoursAgo) {
  const now = Date.now();
  const offset = hoursAgo * 60 * 60 * 1000;
  return Timestamp.fromMillis(now - offset);
}

async function getUidByEmail(auth, email) {
  try {
    const userRecord = await auth.getUserByEmail(email);
    return userRecord.uid;
  } catch (error) {
    if (error.code === "auth/user-not-found") {
      console.log(`⚠️ المستخدم غير موجود: ${email}`);
      return null;
    }
    throw error;
  }
}

async function deleteAllNotificationsForUser(db, uid) {
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

async function seedNotificationsForUser(db, uid, notifications) {
  const batch = db.batch();
  const count = { total: 0, read: 0, unread: 0 };

  for (const notif of notifications) {
    const notifRef = db.collection("users").doc(uid).collection("notifications").doc();
    
    batch.set(notifRef, {
      userId: uid,
      title: notif.title,
      body: notif.body,
      type: notif.type,
      category: notif.type,
      isRead: notif.isRead,
      is_read: notif.isRead,
      read: notif.isRead,
      createdAt: getCreatedAtOffset(notif.hoursAgo),
    });

    count.total++;
    if (notif.isRead) count.read++;
    else count.unread++;
  }

  await batch.commit();
  return count;
}

// ─────────────────────────────────────────────────────────────────────────────
// الدالة الرئيسية
// ─────────────────────────────────────────────────────────────────────────────

async function main() {
  try {
    init();
    const db = getFirestore();
    const auth = getAuth();

    console.log("⏳ جاري حذف الإشعارات القديمة وحقن إشعارات جديدة مترابطة...");

    // جمع جميع المستخدمين
    const allUsers = [...USERS.students, ...USERS.faculty, ...USERS.admin];
    const userIds = {};

    // الحصول على UIDs
    for (const user of allUsers) {
      const uid = await getUidByEmail(auth, user.email);
      if (uid) {
        userIds[user.email] = uid;
      }
    }

    // حذف جميع الإشعارات الموجودة
    console.log("\n🗑️  جاري حذف الإشعارات القديمة...");
    let totalDeleted = 0;
    for (const [email, uid] of Object.entries(userIds)) {
      const deleted = await deleteAllNotificationsForUser(db, uid);
      totalDeleted += deleted;
      console.log(`  ✓ حذف ${deleted} إشعار من ${email}`);
    }
    console.log(`✅ تم حذف ${totalDeleted} إشعار قديم`);

    // تجميع الإشعارات لكل مستخدم
    const userNotifications = {};
    for (const user of allUsers) {
      userNotifications[user.email] = [];
    }

    // توزيع الإشعارات حسب المستلمين
    for (const event of EVENTS) {
      for (const recipient of event.recipients) {
        if (userNotifications[recipient.email]) {
          userNotifications[recipient.email].push({
            title: recipient.title,
            body: recipient.body,
            type: event.type,
            isRead: recipient.isRead,
            hoursAgo: event.hoursAgo,
          });
        }
      }
    }

    // حقن الإشعارات الجديدة
    console.log("\n📝 جاري حقن الإشعارات الجديدة...");
    const results = [];
    let totalUsers = 0;

    for (const [email, uid] of Object.entries(userIds)) {
      const notifications = userNotifications[email];
      if (notifications && notifications.length > 0) {
        const count = await seedNotificationsForUser(db, uid, notifications);
        const userName = allUsers.find(u => u.email === email)?.name || email;
        results.push({ email, name: userName, ...count });
        totalUsers++;
      }
    }

    // طباعة النتائج
    console.log("\n📊 ملخص الإشعارات المحقونة:");
    for (const result of results) {
      console.log(`  ✅ ${result.name} (${result.email}): ${result.total} إشعار (${result.read} مقروء، ${result.unread} غير مقروء)`);
    }

    console.log(`\n✅ تم حقن الإشعارات بنجاح لـ ${totalUsers} مستخدم`);
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
