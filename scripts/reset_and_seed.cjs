const fs = require("fs");
const path = require("path");
const admin = require("firebase-admin");

// الحسابات المعتمدة وكلمات المرور الجاهزة
const CRED = {
  admin: { email: "admin@uod.edu.ly", pw: "Admin@123456" },
  student: { email: "ahmed.ali@uod.edu.ly", pw: "Student@123" },
  student2: { email: "fatima.omar@uod.edu.ly", pw: "Student@123" },
  student3: { email: "ali.hassan@uod.edu.ly", pw: "Student@123" },
  faculty: { email: "layla.hassan@uod.edu.ly", pw: "Faculty@123" },
  faculty2: { email: "khaled.abdallah@uod.edu.ly", pw: "Faculty@123" }
};

const COL = "كلية الهندسة", DEP = "هندسة الحاسوب", FID = "faculty_eng", DID = "dept_cs", SEM = "الفصل الثاني 2025-2026";

// 5 مواد دراسية مترابطة مع الأساتذة
const CRS = [
  { id: "course_adv_prog", code: "CS401", ar: "برمجة متقدمة", en: "Advanced Programming", cr: 3, teacher: "faculty", teacherName: "د. ليلى خالد الحسن" },
  { id: "course_db", code: "CS302", ar: "قواعد بيانات", en: "Database Systems", cr: 3, teacher: "faculty", teacherName: "د. ليلى خالد الحسن" },
  { id: "course_networks", code: "CS303", ar: "شبكات حاسوب", en: "Computer Networks", cr: 3, teacher: "faculty", teacherName: "د. ليلى خالد الحسن" },
  { id: "course_ai", code: "CS405", ar: "الذكاء الاصطناعي", en: "Artificial Intelligence", cr: 3, teacher: "faculty2", teacherName: "د. خالد عبد الله" },
  { id: "course_security", code: "CS408", ar: "الأمن السيبراني", en: "Cybersecurity", cr: 3, teacher: "faculty2", teacherName: "د. خالد عبد الله" }
];

const DATES = ["2026-03-03", "2026-03-10", "2026-03-17", "2026-03-24", "2026-03-31"];

// درجات الطلاب التجريبية لكل مادة لضمان التنوع والواقعية
const STUDENT_GRADES = {
  student: { course_adv_prog: 85.5, course_db: 92, course_networks: 78, course_ai: 88, course_security: 90 },
  student2: { course_adv_prog: 91, course_db: 84, course_networks: 89, course_ai: 95, course_security: 82 },
  student3: { course_adv_prog: 72, course_db: 68, course_networks: 75, course_ai: 64, course_security: 70 }
};

function key() {
  const e = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  const r = path.resolve(__dirname, "../serviceAccountKey.json");
  if (e && fs.existsSync(e)) return e;
  if (fs.existsSync(r)) return r;
  throw new Error("serviceAccountKey.json missing");
}

function init() {
  if (!admin.apps.length) admin.initializeApp({ credential: admin.credential.cert(JSON.parse(fs.readFileSync(key(), "utf8"))) });
}

async function wipeAuth() {
  const a = admin.auth(); let n = 0, t;
  do {
    const r = await a.listUsers(1000, t);
    await Promise.all(r.users.map(u => a.deleteUser(u.uid)));
    n += r.users.length; t = r.pageToken;
  } while (t);
  return n;
}

async function wipeDb(db) {
  const c = {};
  for (const col of await db.listCollections()) {
    let n = 0;
    while (true) {
      const s = await db.collection(col.id).limit(200).get();
      if (s.empty) break;
      for (const d of s.docs) { await db.recursiveDelete(d.ref); n++; }
    }
    c[col.id] = n;
  }
  return c;
}

async function mkUser(a, e, p, d, cl) {
  try { const x = await a.getUserByEmail(e); await a.deleteUser(x.uid); } catch (err) { if (err.code !== "auth/user-not-found") throw err; }
  const u = await a.createUser({ email: e, password: p, displayName: d, emailVerified: true });
  if (cl) await a.setCustomUserClaims(u.uid, cl);
  return u.uid;
}

function gf(t) {
  const m = Math.round(t * 0.3 * 10) / 10, f = Math.round((t - m) * 10) / 10;
  let l = "F", g = 0;
  if (t >= 90) { l = "A"; g = 4; }
  else if (t >= 85) { l = "B+"; g = 3.5; }
  else if (t >= 80) { l = "B"; g = 3; }
  else if (t >= 75) { l = "C+"; g = 2.5; }
  else if (t >= 70) { l = "C"; g = 2; }
  else if (t >= 65) { l = "D+"; g = 1.5; }
  else if (t >= 60) { l = "D"; g = 1; }
  return { midterm: m, finalExam: f, totalScore: t, letterGrade: l, gradePoints: g };
}

async function seed(db, u) {
  const c = {}, ts = admin.firestore.FieldValue.serverTimestamp(), inc = k => { c[k] = (c[k] || 0) + 1 };
  
  await db.collection("colleges").doc(FID).set({ nameAr: COL, nameEn: "Faculty of Engineering", createdAt: ts, updatedAt: ts }); inc("colleges");
  await db.collection("departments").doc(DID).set({ nameAr: DEP, nameEn: "Computer Engineering", collegeId: FID, collegeName: COL, createdAt: ts, updatedAt: ts }); inc("departments");

  // بناء الكورسات وربطها بالأساتذة الجدد
  for (const x of CRS) {
    const teacherUid = u[x.teacher];
    await db.collection("courses").doc(x.id).set({
      code: x.code, name: x.ar, nameAr: x.ar, nameEn: x.en, credits: x.cr,
      teacherUid: teacherUid, instructorId: teacherUid, instructorName: x.teacherName,
      facultyId: FID, departmentId: DID, semester: SEM, studentCount: 3,
      schedule: [`الأحد 10:00-12:00`], room: "قاعة 201",
      enrolledStudentUids: [u.student, u.student2, u.student3], createdAt: ts, updatedAt: ts
    });
    inc("courses");
  }

  // إنشاء مستندات الإدارة والأدمن
  await db.collection("users").doc(u.admin).set({ uid: u.admin, fullName: "مدير النظام", fullNameAr: "مدير النظام", fullNameEn: "System Admin", email: CRED.admin.email, role: "admin", status: "approved", createdAt: ts, updatedAt: ts }); inc("users");

  // مصفوفة الطلاب لتسهيل التعبئة بالتكرار السريع
  const studentsList = [
    { key: "student", name: "أحمد محمد علي", en: "Ahmed Mohamed Ali", id: "20240001", gpa: "3.45" },
    { key: "student2", name: "فاطمة عمر المبروك", en: "Fatima Omar Al-Mabrouk", id: "20240002", gpa: "3.82" },
    { key: "student3", name: "علي حسن الورفلي", en: "Ali Hassan Al-Warfali", id: "20240003", gpa: "2.65" }
  ];

  for (const s of studentsList) {
    const uid = u[s.key];
    await db.collection("users").doc(uid).set({
      uid: uid, fullName: s.name, fullNameAr: s.name, fullNameEn: s.en, email: CRED[s.key].email,
      role: "student", status: "approved", faculty: COL, college: COL, major: DEP, department: DEP,
      facultyId: FID, departmentId: DID, universityId: s.id, gpa: s.gpa, completedHours: "15", createdAt: ts, updatedAt: ts
    });
    inc("users");

    await db.collection("registrations").doc(uid).set({ uid, role: "student", email: CRED[s.key].email, fullNameAr: s.name, status: "approved", faculty: COL, department: DEP, submittedAt: ts }); inc("registrations");
  }

  // مصفوفة الأساتذة (هيئة التدريس)
  const facultyList = [
    { key: "faculty", name: "د. ليلى خالد الحسن", en: "Dr. Layla Khaled Al-Hassan", spec: "علوم الحاسوب" },
    { key: "faculty2", name: "د. خالد عبد الله", en: "Dr. Khaled Abdallah", spec: "الأمن السيبراني والذكاء الاصطناعي" }
  ];

  for (const f of facultyList) {
    const uid = u[f.key];
    await db.collection("users").doc(uid).set({
      uid: uid, fullName: f.name, fullNameAr: f.name, fullNameEn: f.en, email: CRED[f.key].email,
      role: "faculty", status: "approved", college: COL, specialization: f.spec, academicTitle: "أستاذ مشارك", academicDegree: "دكتوراه", facultyId: FID, departmentId: DID, createdAt: ts, updatedAt: ts
    });
    inc("users");

    const activeCourses = CRS.filter(c => c.teacher === f.key).map(x => ({ id: x.id, name: x.ar }));
    await db.collection("faculty_records").doc(uid).set({ courses: activeCourses, updatedAt: ts }); inc("faculty_records");
    await db.collection("registrations").doc(uid).set({ uid, role: "faculty", email: CRED[f.key].email, fullNameAr: f.name, status: "approved", faculty: COL, department: DEP, submittedAt: ts }); inc("registrations");
  }

  // ربط المواد، الدرجات، الحضور والغياب لكل طالب بشكل تفصيلي ومترابط
  for (const s of studentsList) {
    const studentUid = u[s.key];
    for (const x of CRS) {
      const currentGrade = STUDENT_GRADES[s.key][x.id] || 80;
      const g = gf(currentGrade);

      await db.collection("users").doc(studentUid).collection("enrollments").doc(x.id).set({ courseName: x.ar, creditHours: x.cr, semester: SEM, year: 2026, status: "active", instructor: x.teacherName, schedule: "الأحد 10:00-12:00", updatedAt: ts }); inc("enrollments");
      await db.collection("users").doc(studentUid).collection("grades").doc(x.id).set({ courseName: x.ar, creditHours: x.cr, semester: SEM, ...g, updatedAt: ts }); inc("grades");
      await db.collection("users").doc(studentUid).collection("attendance").doc(x.id).set({ courseName: x.ar, semester: SEM, totalLectures: 5, attendedLectures: s.key === "student3" ? 3 : 4, updatedAt: ts }); inc("attendance_sum");

      // إنشاء تواريخ حضور وغياب متصلة
      for (let i = 0; i < DATES.length; i++) {
        const isPresent = s.key === "student3" ? i < 3 : i < 4; // تنويع غياب الطالب الثالث للواقعية
        await db.collection("attendance").doc(x.id).collection("records").doc(`${DATES[i]}_${studentUid}`).set({ studentUid: studentUid, studentName: s.name, courseId: x.id, date: DATES[i], isPresent: isPresent }); inc("attendance_records");
      }
      await db.collection("grades").doc(x.id).collection("students").doc(studentUid).set({ studentUid: studentUid, studentName: s.name, courseId: x.id, midterm: g.midterm, finalExam: g.finalExam, assignments: 15, total: g.totalScore }); inc("faculty_grades");
    }
  }

  // إضافة جدول المحاضرات الأسبوعي الموحد لبوابة الجداول الدراسية
  const slots = [
    { d: 0, st: "10:00", en: "12:00", cid: "course_adv_prog", rm: "201", tname: "د. ليلى خالد الحسن" },
    { d: 1, st: "12:00", en: "14:00", cid: "course_db", rm: "105", tname: "د. ليلى خالد الحسن" },
    { d: 2, st: "08:00", en: "10:00", cid: "course_ai", rm: "Lab-3", tname: "د. خالد عبد الله" },
    { d: 3, st: "08:00", en: "10:00", cid: "course_networks", rm: "Lab-2", tname: "د. ليلى خالد الحسن" },
    { d: 4, st: "14:00", en: "16:00", cid: "course_security", rm: "قاعة 102", tname: "د. خالد عبد الله" }
  ];

  for (const s of slots) {
    const x = CRS.find(c => c.id === s.cid);
    await db.collection("schedules").add({ courseId: s.cid, courseName: x.ar, courseCode: x.code, instructorName: s.tname, dayOfWeek: s.d, startTime: s.st, endTime: s.en, room: s.rm, academicYear: "2025-2026", semester: SEM, createdAt: ts }); inc("schedules");
    
    // حقن الجدول في حسابات الطلاب والأساتذة المعنيين
    for (const st of studentsList) { await db.collection("users").doc(u[st.key]).collection("schedule").add({ courseId: s.cid, courseName: x.ar, weekdayIndex: s.d, startTime: s.st, endTime: s.en, room: s.rm }); inc("user_schedule"); }
    const teacherUid = u[x.teacher];
    await db.collection("users").doc(teacherUid).collection("schedule").add({ courseId: s.cid, courseName: x.ar, weekdayIndex: s.d, startTime: s.st, endTime: s.en, room: s.rm }); inc("user_schedule");
  }

  await db.collection("notifications").add({ title: "إجازة رسمية", body: "إجازة رسمية لجميع الطلاب وأعضاء هيئة التدريس يوم السبت القادم بمناسبة الأعياد الرسمية.", targetRole: "all", read: false, isRead: false, category: "إعلان", createdAt: ts, updatedAt: ts }); inc("global_notifications");

  const studentNotifications = [
    { title: "درجة جديدة — برمجة متقدمة", body: "تم رصد درجتك في مادة برمجة متقدمة: 85.5/100.", category: "grade", read: false },
    { title: "تحذير غياب — شبكات حاسوب", body: "لقد تجاوزت 20% من نسبة الغياب المسموح بها في مادة شبكات حاسوب.", category: "تنبيه", read: false },
    { title: "إعلان — جدول الامتحانات النهائية", body: "تم نشر جدول الامتحانات النهائية للفصل الدراسي الثاني.", category: "إعلان", read: true },
    { title: "درجة جديدة — الذكاء الاصطناعي", body: "تم رصد درجة الاختبار الأول في مادة الذكاء الاصطناعي: 88/100.", category: "grade", read: true },
    { title: "إعلان — إجازة منتصف الفصل", body: "تُعلن عمادة الكلية عن إجازة منتصف الفصل الدراسي.", category: "إعلان", read: true }
  ];

  for (const s of studentsList) {
    const studentUid = u[s.key];
    for (const n of studentNotifications) {
      await db.collection("users").doc(studentUid).collection("notifications").add({
        title: n.title, body: n.body, category: n.category,
        read: n.read, isRead: n.read, createdAt: ts, updatedAt: ts
      });
      inc("user_notifications");
    }
  }
  await db.collection("_seed_meta").doc("info").set({ note: "Multi-user interconnected simulation database v2", version: 2, seededAt: ts, uids: u }); inc("_seed_meta");
  return c;
}

async function main() {
  if (!process.argv.includes("--force") && process.env.FORCE !== "1") { console.error("Use --force"); process.exit(1); }
  init(); const db = admin.firestore(), auth = admin.auth();
  console.log("Wipe Firestore..."); const wiped = await wipeDb(db);
  console.log("Wipe Auth..."); const ad = await wipeAuth();
  console.log("Create users...");
  
  const u = {
    admin: await mkUser(auth, CRED.admin.email, CRED.admin.pw, "System Admin", { role: "admin" }),
    student: await mkUser(auth, CRED.student.email, CRED.student.pw, "Ahmed Mohamed Ali"),
    student2: await mkUser(auth, CRED.student2.email, CRED.student2.pw, "Fatima Omar Al-Mabrouk"),
    student3: await mkUser(auth, CRED.student3.email, CRED.student3.pw, "Ali Hassan Al-Warfali"),
    faculty: await mkUser(auth, CRED.faculty.email, CRED.faculty.pw, "Dr. Layla Khaled Al-Hassan"),
    faculty2: await mkUser(auth, CRED.faculty2.email, CRED.faculty2.pw, "Dr. Khaled Abdallah")
  };
  
  console.log("Seed..."); const created = await seed(db, u);
  const report = { wiped, ad, created, u, credentials: CRED, at: new Date().toISOString() };
  fs.writeFileSync(path.join(__dirname, "SEED_REPORT.json"), JSON.stringify(report, null, 2));
  
  console.log("\n=== 🚀 SUCCESS: DATA SEEDED SUCCESSFULLY ===");
  console.log("Admin:", CRED.admin.email, " | Pw:", CRED.admin.pw);
  console.log("Student 1:", CRED.student.email, " | Pw:", CRED.student.pw);
  console.log("Student 2:", CRED.student2.email, " | Pw:", CRED.student2.pw);
  console.log("Student 3:", CRED.student3.email, " | Pw:", CRED.student3.pw);
  console.log("Faculty 1:", CRED.faculty.email, " | Pw:", CRED.faculty.pw);
  console.log("Faculty 2:", CRED.faculty2.email, " | Pw:", CRED.faculty2.pw);
  process.exit(0);
}

main().catch(e => { console.error(e); process.exit(1); });