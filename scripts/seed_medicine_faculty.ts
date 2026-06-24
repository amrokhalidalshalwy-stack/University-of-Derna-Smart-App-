/**
 * 🏥 Faculty of Medicine Data Seeder
 * 
 * Seeds realistic, interconnected data for:
 * - Faculty of Medicine (جامعة درنة)
 * - Spring 2026 Semester
 * - Medical Courses: Anatomy, Physiology, Biochemistry, Pathology
 * - Faculty: Dr. Ahmed Al-Mansouri, Dr. Fatima Al-Obaidi
 * - Students: 5 realistic medical students
 * - Complete timetable with lecture halls and labs
 * 
 * Usage: npx ts-node scripts/seed_medicine_faculty.ts --force
 */

import { readFileSync, existsSync, writeFileSync } from "fs";
import { resolve } from "path";
import * as admin from "firebase-admin";

// ===== CREDENTIALS =====
const CREDENTIALS = {
  admin: { email: "admin@uod.edu.ly", pw: "Admin@123456" },
  // Faculty (Professors)
  prof_ahmed: { email: "ahmed.mansouri@uod.edu.ly", pw: "Faculty@123" },
  prof_fatima: { email: "fatima.obaidi@uod.edu.ly", pw: "Faculty@123" },
  // Students
  student_salem: { email: "salem.omar@uod.edu.ly", pw: "Student@123" },
  student_aisha: { email: "aisha.fitouri@uod.edu.ly", pw: "Student@123" },
  student_mohanned: { email: "mohanned.ali@uod.edu.ly", pw: "Student@123" },
  student_layla: { email: "layla.abdallah@uod.edu.ly", pw: "Student@123" },
  student_mahmoud: { email: "mahmoud.hassan@uod.edu.ly", pw: "Student@123" },
};

// ===== ACADEMIC STRUCTURE =====
const FACULTY_ID = "faculty_medicine_derna";
const FACULTY_NAME_AR = "كلية الطب";
const FACULTY_NAME_EN = "Faculty of Medicine";
const DEPARTMENT_ID = "dept_medicine_gen";
const DEPARTMENT_NAME_AR = "قسم الطب العام";
const DEPARTMENT_NAME_EN = "General Medicine Department";
const SEMESTER = "الفصل الربيعي 2026";
const SEMESTER_EN = "Spring 2026";
const ACADEMIC_YEAR = "2025-2026";

// ===== COURSES =====
const COURSES = [
  {
    id: "MED_ANA101",
    code: "ANA101",
    nameAr: "تشريح 1",
    nameEn: "Anatomy I",
    credits: 3,
    instructor_key: "prof_ahmed",
    instructorNameAr: "أ.د. أحمد المنصوري",
    instructorNameEn: "Prof. Dr. Ahmed Al-Mansouri",
  },
  {
    id: "MED_PHY101",
    code: "PHY101",
    nameAr: "علم وظائف الأعضاء 1",
    nameEn: "Physiology I",
    credits: 3,
    instructor_key: "prof_fatima",
    instructorNameAr: "د. فاطمة العبيدي",
    instructorNameEn: "Dr. Fatima Al-Obaidi",
  },
  {
    id: "MED_BIO102",
    code: "BIO102",
    nameAr: "الكيمياء الحيوية",
    nameEn: "Biochemistry",
    credits: 3,
    instructor_key: "prof_fatima",
    instructorNameAr: "د. فاطمة العبيدي",
    instructorNameEn: "Dr. Fatima Al-Obaidi",
  },
  {
    id: "MED_PAT201",
    code: "PAT201",
    nameAr: "علم الأمراض",
    nameEn: "Pathology",
    credits: 4,
    instructor_key: "prof_ahmed",
    instructorNameAr: "أ.د. أحمد المنصوري",
    instructorNameEn: "Prof. Dr. Ahmed Al-Mansouri",
  },
];

// ===== TIMETABLE SLOTS (Realistic Medical Schedule) =====
// Days: 0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday
const SCHEDULE_SLOTS = [
  // Sunday
  {
    dayOfWeek: 0,
    startTime: "09:00",
    endTime: "11:00",
    courseId: "MED_ANA101",
    courseName: "تشريح 1",
    room: "المدرج الرئيسي بكلية الطب",
    roomEn: "Main Medical Lecture Hall",
    instructorName: "أ.د. أحمد المنصوري",
  },
  // Monday
  {
    dayOfWeek: 1,
    startTime: "10:00",
    endTime: "12:00",
    courseId: "MED_PHY101",
    courseName: "علم وظائف الأعضاء 1",
    room: "معمل الفسيولوجيا 1",
    roomEn: "Physiology Lab 1",
    instructorName: "د. فاطمة العبيدي",
  },
  // Tuesday
  {
    dayOfWeek: 2,
    startTime: "11:00",
    endTime: "13:00",
    courseId: "MED_BIO102",
    courseName: "الكيمياء الحيوية",
    room: "معمل الكيمياء الحيوية",
    roomEn: "Biochemistry Lab",
    instructorName: "د. فاطمة العبيدي",
  },
  // Wednesday
  {
    dayOfWeek: 3,
    startTime: "10:00",
    endTime: "12:00",
    courseId: "MED_PAT201",
    courseName: "علم الأمراض",
    room: "المدرج الرئيسي بكلية الطب",
    roomEn: "Main Medical Lecture Hall",
    instructorName: "أ.د. أحمد المنصوري",
  },
  // Thursday
  {
    dayOfWeek: 4,
    startTime: "09:00",
    endTime: "11:00",
    courseId: "MED_ANA101",
    courseName: "تشريح 1",
    room: "معمل التشريح",
    roomEn: "Anatomy Lab",
    instructorName: "أ.د. أحمد المنصوري",
  },
];

// ===== STUDENT DATA =====
const STUDENTS = [
  {
    key: "student_salem",
    nameAr: "سالم عمر البدري",
    nameEn: "Salem Omar Al-Badri",
    universityId: "20240101",
    gpa: "3.65",
  },
  {
    key: "student_aisha",
    nameAr: "عائشة الفيتوري",
    nameEn: "Aisha Al-Fitouri",
    universityId: "20240102",
    gpa: "3.92",
  },
  {
    key: "student_mohanned",
    nameAr: "مهند علي الشليمي",
    nameEn: "Mohanned Ali Al-Shulaim",
    universityId: "20240103",
    gpa: "3.45",
  },
  {
    key: "student_layla",
    nameAr: "ليلى حسن القاضي",
    nameEn: "Layla Hassan Al-Qadhi",
    universityId: "20240104",
    gpa: "3.78",
  },
  {
    key: "student_mahmoud",
    nameAr: "محمود خالد الحويش",
    nameEn: "Mahmoud Khaled Al-Huwaish",
    universityId: "20240105",
    gpa: "2.95",
  },
];

// ===== FACULTY DATA =====
const FACULTY = [
  {
    key: "prof_ahmed",
    nameAr: "أ.د. أحمد المنصوري",
    nameEn: "Prof. Dr. Ahmed Al-Mansouri",
    specialization: "تشريح و علم الأمراض",
    title: "أستاذ",
  },
  {
    key: "prof_fatima",
    nameAr: "د. فاطمة العبيدي",
    nameEn: "Dr. Fatima Al-Obaidi",
    specialization: "الفسيولوجيا و الكيمياء الحيوية",
    title: "أستاذة مشاركة",
  },
];

// ===== GRADE CALCULATOR =====
function calculateGrade(score: number) {
  let letterGrade = "F",
    gradePoints = 0;
  if (score >= 90) {
    letterGrade = "A";
    gradePoints = 4.0;
  } else if (score >= 85) {
    letterGrade = "B+";
    gradePoints = 3.5;
  } else if (score >= 80) {
    letterGrade = "B";
    gradePoints = 3.0;
  } else if (score >= 75) {
    letterGrade = "C+";
    gradePoints = 2.5;
  } else if (score >= 70) {
    letterGrade = "C";
    gradePoints = 2.0;
  } else if (score >= 65) {
    letterGrade = "D+";
    gradePoints = 1.5;
  } else if (score >= 60) {
    letterGrade = "D";
    gradePoints = 1.0;
  }

  const midterm = Math.round(score * 0.3 * 10) / 10;
  const finalExam = Math.round((score - midterm) * 10) / 10;

  return {
    midterm,
    finalExam,
    totalScore: score,
    letterGrade,
    gradePoints,
  };
}

// ===== FILE UTILITIES =====
function findServiceAccountKey() {
  const envPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  const scriptPath = resolve(__dirname, "serviceAccountKey.json");
  const rootPath = resolve(__dirname, "../serviceAccountKey.json");

  if (envPath && existsSync(envPath)) return envPath;
  if (existsSync(scriptPath)) return scriptPath;
  if (existsSync(rootPath)) return rootPath;

  throw new Error(
    "serviceAccountKey.json not found. Set GOOGLE_APPLICATION_CREDENTIALS or place it in scripts/ or project root."
  );
}

function initFirebase() {
  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert(
        JSON.parse(readFileSync(findServiceAccountKey(), "utf8"))
      ),
    });
  }
}

// ===== AUTH MANAGEMENT =====
async function createOrUpdateUser(
  auth: admin.auth.Auth,
  email: string,
  password: string,
  displayName: string,
  customClaims?: Record<string, unknown>
): Promise<string> {
  try {
    const existing = await auth.getUserByEmail(email);
    await auth.deleteUser(existing.uid);
    console.log(`  ✓ Deleted existing user: ${email}`);
  } catch (err: any) {
    if (err.code !== "auth/user-not-found") throw err;
  }

  const newUser = await auth.createUser({
    email,
    password,
    displayName,
    emailVerified: true,
  });

  if (customClaims) {
    await auth.setCustomUserClaims(newUser.uid, customClaims);
  }

  console.log(`  ✓ Created user: ${email}`);
  return newUser.uid;
}

// ===== FIRESTORE CLEANUP =====
async function wipeFirestore(db: admin.firestore.Firestore) {
  console.log("\n🗑️  Wiping Firestore...");
  const collections = await db.listCollections();
  let totalDeleted = 0;

  for (const col of collections) {
    let deleted = 0;
    while (true) {
      const snapshot = await db.collection(col.id).limit(200).get();
      if (snapshot.empty) break;

      for (const doc of snapshot.docs) {
        await doc.ref.delete();
        deleted++;
      }
    }
    console.log(`  ✓ ${col.id}: ${deleted} documents deleted`);
    totalDeleted += deleted;
  }

  return totalDeleted;
}

async function wipeAuth(auth: admin.auth.Auth) {
  console.log("\n🗑️  Wiping Authentication...");
  let deleted = 0;
  let pageToken: string | undefined;

  do {
    const result = await auth.listUsers(1000, pageToken);
    for (const user of result.users) {
      await auth.deleteUser(user.uid);
      deleted++;
    }
    pageToken = result.pageToken;
  } while (pageToken);

  console.log(`  ✓ Deleted ${deleted} users`);
  return deleted;
}

// ===== DATA SEEDING =====
async function seedData(
  db: admin.firestore.Firestore,
  userIds: Record<string, string>
): Promise<Record<string, number>> {
  const ts = admin.firestore.FieldValue.serverTimestamp();
  const counts: Record<string, number> = {};

  const increment = (collection: string, count: number = 1) => {
    counts[collection] = (counts[collection] || 0) + count;
  };

  console.log("\n🏫 Creating College & Department...");

  // Create College
  await db
    .collection("colleges")
    .doc(FACULTY_ID)
    .set({
      nameAr: FACULTY_NAME_AR,
      nameEn: FACULTY_NAME_EN,
      university: "جامعة درنة",
      universityEn: "Derna University",
      createdAt: ts,
      updatedAt: ts,
    });
  increment("colleges");
  console.log(`  ✓ Created college: ${FACULTY_NAME_AR}`);

  // Create Department
  await db
    .collection("departments")
    .doc(DEPARTMENT_ID)
    .set({
      nameAr: DEPARTMENT_NAME_AR,
      nameEn: DEPARTMENT_NAME_EN,
      collegeId: FACULTY_ID,
      collegeName: FACULTY_NAME_AR,
      createdAt: ts,
      updatedAt: ts,
    });
  increment("departments");
  console.log(`  ✓ Created department: ${DEPARTMENT_NAME_AR}`);

  // Create Courses
  console.log("\n📚 Creating Courses...");
  for (const course of COURSES) {
    const teacherUid = userIds[course.instructor_key];
    const courseData = {
      code: course.code,
      name: course.nameAr,
      nameAr: course.nameAr,
      nameEn: course.nameEn,
      credits: course.credits,
      creditHours: course.credits,
      teacherUid,
      instructorId: teacherUid,
      instructorName: course.instructorNameAr,
      instructorNameEn: course.instructorNameEn,
      facultyId: FACULTY_ID,
      departmentId: DEPARTMENT_ID,
      semester: SEMESTER,
      semesterEn: SEMESTER_EN,
      academicYear: ACADEMIC_YEAR,
      studentCount: STUDENTS.length,
      enrolledStudentUids: STUDENTS.map((s) => userIds[s.key]),
      schedule: ["الأحد 09:00-11:00"],
      room: "المدرج الرئيسي بكلية الطب",
      createdAt: ts,
      updatedAt: ts,
    };

    await db.collection("courses").doc(course.id).set(courseData);
    increment("courses");
    console.log(`  ✓ Created course: ${course.nameAr} (${course.code})`);
  }

  // Create Admin User
  console.log("\n👤 Creating Admin User...");
  const adminData = {
    uid: userIds.admin,
    fullName: "مدير النظام",
    fullNameAr: "مدير النظام",
    fullNameEn: "System Administrator",
    email: CREDENTIALS.admin.email,
    role: "admin",
    status: "approved",
    createdAt: ts,
    updatedAt: ts,
  };
  await db.collection("users").doc(userIds.admin).set(adminData);
  increment("users");
  console.log(`  ✓ Created admin user`);

  // Create Faculty Users
  console.log("\n👨‍🏫 Creating Faculty Members...");
  for (const faculty of FACULTY) {
    const uid = userIds[faculty.key];
    const facultyData = {
      uid,
      fullName: faculty.nameAr,
      fullNameAr: faculty.nameAr,
      fullNameEn: faculty.nameEn,
      email: CREDENTIALS[faculty.key as keyof typeof CREDENTIALS].email,
      role: "faculty",
      status: "approved",
      college: FACULTY_NAME_AR,
      collegeId: FACULTY_ID,
      department: DEPARTMENT_NAME_AR,
      departmentId: DEPARTMENT_ID,
      specialization: faculty.specialization,
      academicTitle: faculty.title,
      academicDegree: faculty.title === "أستاذ" ? "دكتوراه" : "ماجستير",
      createdAt: ts,
      updatedAt: ts,
    };

    await db.collection("users").doc(uid).set(facultyData);
    increment("users");

    // Create faculty records with assigned courses
    const assignedCourses = COURSES.filter(
      (c) => c.instructor_key === faculty.key
    ).map((c) => ({ id: c.id, name: c.nameAr }));

    await db
      .collection("faculty_records")
      .doc(uid)
      .set({
        courses: assignedCourses,
        department: DEPARTMENT_NAME_AR,
        updatedAt: ts,
      });
    increment("faculty_records");

    // Create registration record
    await db
      .collection("registrations")
      .doc(uid)
      .set({
        uid,
        role: "faculty",
        email: CREDENTIALS[faculty.key as keyof typeof CREDENTIALS].email,
        fullNameAr: faculty.nameAr,
        fullNameEn: faculty.nameEn,
        status: "approved",
        college: FACULTY_NAME_AR,
        department: DEPARTMENT_NAME_AR,
        submittedAt: ts,
      });
    increment("registrations");

    console.log(`  ✓ Created faculty: ${faculty.nameAr}`);
  }

  // Create Student Users
  console.log("\n👨‍🎓 Creating Students...");
  for (const student of STUDENTS) {
    const uid = userIds[student.key];
    const studentData = {
      uid,
      fullName: student.nameAr,
      fullNameAr: student.nameAr,
      fullNameEn: student.nameEn,
      email: CREDENTIALS[student.key as keyof typeof CREDENTIALS].email,
      role: "student",
      status: "approved",
      universityId: student.universityId,
      college: FACULTY_NAME_AR,
      collegeId: FACULTY_ID,
      department: DEPARTMENT_NAME_AR,
      departmentId: DEPARTMENT_ID,
      major: DEPARTMENT_NAME_AR,
      gpa: student.gpa,
      completedHours: "30",
      createdAt: ts,
      updatedAt: ts,
    };

    await db.collection("users").doc(uid).set(studentData);
    increment("users");

    // Create registration record
    await db
      .collection("registrations")
      .doc(uid)
      .set({
        uid,
        role: "student",
        email: CREDENTIALS[student.key as keyof typeof CREDENTIALS].email,
        fullNameAr: student.nameAr,
        status: "approved",
        college: FACULTY_NAME_AR,
        department: DEPARTMENT_NAME_AR,
        submittedAt: ts,
      });
    increment("registrations");

    console.log(`  ✓ Created student: ${student.nameAr}`);
  }

  // Create Course Enrollments, Grades, and Attendance
  console.log("\n📋 Creating Enrollments, Grades & Attendance Records...");
  for (const student of STUDENTS) {
    const studentUid = userIds[student.key];

    for (const course of COURSES) {
      // Realistic grade distribution
      let baseScore = 85;
      if (student.key === "student_aisha") baseScore = 92;
      else if (student.key === "student_mahmoud") baseScore = 68;
      else if (student.key === "student_layla") baseScore = 88;
      
      const score = baseScore + Math.random() * 10 - 5;
      const gradeInfo = calculateGrade(Math.round(score));

      // Enrollment (student side)
      const enrollmentData = {
        courseId: course.id,
        courseName: course.nameAr,
        courseNameEn: course.nameEn,
        courseCode: course.code,
        creditHours: course.credits,
        semester: SEMESTER,
        year: 2026,
        status: "active",
        instructor: course.instructorNameAr,
        instructorNameEn: course.instructorNameEn,
        schedule: "الأحد 09:00-11:00",
        updatedAt: ts,
      };

      await db
        .collection("users")
        .doc(studentUid)
        .collection("enrollments")
        .doc(course.id)
        .set(enrollmentData);
      increment("enrollments");

      // Enrollment (course side)
      await db
        .collection("courses")
        .doc(course.id)
        .collection("enrollments")
        .doc(studentUid)
        .set({
          studentUid,
          studentNameAr: student.nameAr,
          studentNameEn: student.nameEn,
          studentEmail: CREDENTIALS[student.key as keyof typeof CREDENTIALS].email,
          courseId: course.id,
          courseName: course.nameAr,
          courseCode: course.code,
          semester: SEMESTER,
          year: 2026,
          status: "active",
          instructor: course.instructorNameAr,
          instructorNameEn: course.instructorNameEn,
          schedule: "الأحد 09:00-11:00",
          enrolledAt: ts,
          updatedAt: ts,
        });
      increment("course_enrollments");

      // Grade
      await db
        .collection("users")
        .doc(studentUid)
        .collection("grades")
        .doc(course.id)
        .set({
          courseName: course.nameAr,
          courseCode: course.code,
          creditHours: course.credits,
          semester: SEMESTER,
          ...gradeInfo,
          updatedAt: ts,
        });
      increment("grades");

      // Attendance summary
      const attendanceRate =
        student.key === "student_mahmoud" ? 0.6 : 0.85 + Math.random() * 0.1;
      const attendedLectures = Math.floor(5 * attendanceRate);

      await db
        .collection("users")
        .doc(studentUid)
        .collection("attendance")
        .doc(course.id)
        .set({
          courseName: course.nameAr,
          courseCode: course.code,
          semester: SEMESTER,
          totalLectures: 5,
          attendedLectures,
          absentLectures: 5 - attendedLectures,
          attendancePercentage: (attendedLectures / 5) * 100,
          updatedAt: ts,
        });
      increment("attendance_records");
    }
  }

  // Create Global Schedule Entries
  console.log("\n⏰ Creating Timetable Schedules...");
  for (const slot of SCHEDULE_SLOTS) {
    const scheduleData = {
      courseId: slot.courseId,
      courseName: slot.courseName,
      dayOfWeek: slot.dayOfWeek,
      weekdayIndex: slot.dayOfWeek,
      startTime: slot.startTime,
      endTime: slot.endTime,
      room: slot.room,
      roomEn: slot.roomEn,
      location: slot.room,
      instructor: slot.instructorName,
      instructorName: slot.instructorName,
      semester: SEMESTER,
      academicYear: ACADEMIC_YEAR,
      createdAt: ts,
    };

    await db.collection("schedules").add(scheduleData);
    increment("schedules");

    // Add schedule entry to each student's personal timetable
    for (const student of STUDENTS) {
      const studentUid = userIds[student.key];
      await db
        .collection("users")
        .doc(studentUid)
        .collection("schedule")
        .add({
          courseId: slot.courseId,
          courseTitle: slot.courseName,
          weekdayIndex: slot.dayOfWeek,
          startTime: slot.startTime,
          endTime: slot.endTime,
          location: slot.room,
          instructor: slot.instructorName,
          status: "حضور",
          updatedAt: ts,
        });
      increment("user_schedule");
    }

    // Add schedule to instructor's timetable
    const instructorKey = COURSES.find((c) => c.id === slot.courseId)
      ?.instructor_key;
    if (instructorKey) {
      const instructorUid = userIds[instructorKey];
      await db
        .collection("users")
        .doc(instructorUid)
        .collection("schedule")
        .add({
          courseId: slot.courseId,
          courseTitle: slot.courseName,
          weekdayIndex: slot.dayOfWeek,
          startTime: slot.startTime,
          endTime: slot.endTime,
          location: slot.room,
          instructor: slot.instructorName,
          updatedAt: ts,
        });
      increment("user_schedule");
    }

    console.log(
      `  ✓ Created schedule: ${slot.courseName} on day ${slot.dayOfWeek} (${slot.startTime}-${slot.endTime})`
    );
  }

  // Create notification
  console.log("\n🔔 Creating Notifications...");
  await db.collection("notifications").add({
    title: "مرحباً بك في كلية الطب",
    titleEn: "Welcome to Faculty of Medicine",
    body: "يسعدنا استقبالك في كلية الطب بجامعة درنة. الفصل الربيعي 2026 قد بدأ الآن.",
    bodyEn:
      "Welcome to the Faculty of Medicine at Derna University. Spring 2026 semester has started.",
    targetRole: "all",
    isRead: false,
    createdAt: ts,
  });
  increment("notifications");
  console.log(`  ✓ Created welcome notification`);

  // Save metadata
  await db
    .collection("_seed_meta")
    .doc("medicine_faculty")
    .set({
      name: "Faculty of Medicine - Spring 2026",
      version: 1,
      faculty: FACULTY_NAME_AR,
      semester: SEMESTER,
      studentCount: STUDENTS.length,
      facultyCount: FACULTY.length,
      courseCount: COURSES.length,
      seededAt: ts,
      uids: userIds,
    });
  increment("_seed_meta");

  return counts;
}

// ===== MAIN EXECUTION =====
async function main() {
  const isForced =
    process.argv.includes("--force") || process.env.FORCE === "1";

  if (!isForced) {
    console.error("❌ Safety check: Use --force flag to proceed");
    console.error("   npx ts-node scripts/seed_medicine_faculty.ts --force");
    process.exit(1);
  }

  try {
    console.log("🚀 Starting Faculty of Medicine Data Seeding...\n");

    initFirebase();
    const db = admin.firestore();
    const auth = admin.auth();

    // Cleanup
    await wipeFirestore(db);
    await wipeAuth(auth);

    // Create users
    console.log("\n👥 Creating Users in Firebase Authentication...");
    const userIds: Record<string, string> = {};

    // Admin
    userIds.admin = await createOrUpdateUser(
      auth,
      CREDENTIALS.admin.email,
      CREDENTIALS.admin.pw,
      "System Administrator",
      { role: "admin" }
    );

    // Faculty
    for (const faculty of FACULTY) {
      userIds[faculty.key] = await createOrUpdateUser(
        auth,
        CREDENTIALS[faculty.key as keyof typeof CREDENTIALS].email,
        CREDENTIALS[faculty.key as keyof typeof CREDENTIALS].pw,
        faculty.nameEn,
        { role: "faculty" }
      );
    }

    // Students
    for (const student of STUDENTS) {
      userIds[student.key] = await createOrUpdateUser(
        auth,
        CREDENTIALS[student.key as keyof typeof CREDENTIALS].email,
        CREDENTIALS[student.key as keyof typeof CREDENTIALS].pw,
        student.nameEn,
        { role: "student" }
      );
    }

    // Seed Firestore
    const counts = await seedData(db, userIds);

    // Generate report
    const report = {
      success: true,
      seededAt: new Date().toISOString(),
      faculty: FACULTY_NAME_AR,
      semester: SEMESTER,
      statistics: counts,
      credentials: {
        admin: CREDENTIALS.admin,
        faculty: {
          prof_ahmed: CREDENTIALS.prof_ahmed,
          prof_fatima: CREDENTIALS.prof_fatima,
        },
        students: {
          salem: CREDENTIALS.student_salem,
          aisha: CREDENTIALS.student_aisha,
          mohanned: CREDENTIALS.student_mohanned,
          layla: CREDENTIALS.student_layla,
          mahmoud: CREDENTIALS.student_mahmoud,
        },
      },
      uids: userIds,
    };

    writeFileSync(
      resolve(__dirname, "SEED_REPORT_MEDICINE.json"),
      JSON.stringify(report, null, 2)
    );

    // Display results
    console.log("\n" + "=".repeat(70));
    console.log("✅ SUCCESS: FACULTY OF MEDICINE DATA SEEDED SUCCESSFULLY");
    console.log("=".repeat(70));

    console.log("\n📊 Seeding Statistics:");
    for (const [collection, count] of Object.entries(counts)) {
      console.log(`   ${collection}: ${count}`);
    }

    console.log("\n🔐 Login Credentials:");
    console.log(`\n   ADMIN:`);
    console.log(`   └─ Email: ${CREDENTIALS.admin.email}`);
    console.log(`   └─ Password: ${CREDENTIALS.admin.pw}`);

    console.log(`\n   FACULTY:`);
    for (const faculty of FACULTY) {
      const cred = CREDENTIALS[faculty.key as keyof typeof CREDENTIALS];
      console.log(`   ${faculty.nameAr}`);
      console.log(`   └─ Email: ${cred.email}`);
      console.log(`   └─ Password: ${cred.pw}`);
    }

    console.log(`\n   STUDENTS:`);
    for (const student of STUDENTS) {
      const cred = CREDENTIALS[student.key as keyof typeof CREDENTIALS];
      console.log(`   ${student.nameAr}`);
      console.log(`   └─ Email: ${cred.email}`);
      console.log(`   └─ Password: ${cred.pw}`);
    }

    console.log("\n📄 Full report saved to: SEED_REPORT_MEDICINE.json");
    console.log("=".repeat(70) + "\n");

    process.exit(0);
  } catch (error) {
    console.error("\n❌ Error during seeding:");
    console.error(error);
    process.exit(1);
  }
}

main();
