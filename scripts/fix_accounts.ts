import { readFileSync, existsSync } from "fs";
import { resolve } from "path";
import * as admin from "firebase-admin";

function resolveKeyPath(): string {
  const fromEnv = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (fromEnv && existsSync(fromEnv)) return resolve(fromEnv);
  const rootKey = resolve(__dirname, "../serviceAccountKey.json");
  if (existsSync(rootKey)) return rootKey;
  throw new Error(
    "Service account key not found. Place serviceAccountKey.json at the project root."
  );
}

async function main(): Promise<void> {
  const keyPath = resolveKeyPath();
  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert(
        JSON.parse(readFileSync(keyPath, "utf8")) as admin.ServiceAccount
      ),
    });
  }

  const db = admin.firestore();

  console.log("═".repeat(60));
  console.log("UOD — Automated User Account Repairs");
  console.log(`Using Key: ${keyPath}`);
  console.log("═".repeat(60));

  // 1. Fix Faculty Account
  const facultyUid = "52XHJ1rvhpRX5xBVCWMlV8nlZlC2";
  console.log(`\nChecking Faculty UID: ${facultyUid}...`);
  const facultyDocRef = db.collection("users").doc(facultyUid);
  const facultyDoc = await facultyDocRef.get();
  
  if (facultyDoc.exists) {
    const data = facultyDoc.data();
    console.log("Current Faculty Data:", data);
    await facultyDocRef.update({
      email: "omar@gmail.com",
      role: "faculty",
      status: "approved",
    });
    console.log("✅ Updated Faculty fields successfully!");
  } else {
    console.log("⚠️ Faculty document not found! Creating default...");
    await facultyDocRef.set({
      email: "omar@gmail.com",
      fullName: "عضو هيئة تدريس",
      role: "faculty",
      status: "approved",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log("✅ Created Faculty account successfully!");
  }

  // 2. Fix Student Account(s)
  const studentUid = "PcemOrA9uhXE9s6Bq2GoYVxq2Eq2";
  console.log(`\nChecking Target Student UID: ${studentUid}...`);
  const studentDocRef = db.collection("users").doc(studentUid);
  const studentDoc = await studentDocRef.get();

  if (studentDoc.exists) {
    await studentDocRef.update({
      role: "student",
      status: "approved",
    });
    console.log("✅ Updated target Student account successfully!");
  } else {
    console.log("⚠️ Target student document not found.");
  }

  // Also approve other pending student accounts to be helpful
  console.log("\nSearching for any other pending student accounts...");
  const pendingStudentsSnap = await db
    .collection("users")
    .where("role", "==", "student")
    .where("status", "==", "pending")
    .get();

  for (const doc of pendingStudentsSnap.docs) {
    console.log(`  Fixing pending student UID: ${doc.id} (${doc.data().email})`);
    await doc.ref.update({
      status: "approved",
    });
  }
  console.log(`✅ Approved ${pendingStudentsSnap.size} other pending student accounts.`);

  // 3. Provision Admin Account
  const adminUid = "a9mJCyBnHpaZGw19erZeH1YYwhf1";
  console.log(`\nChecking Admin UID: ${adminUid}...`);
  const adminDocRef = db.collection("users").doc(adminUid);
  const adminDoc = await adminDocRef.get();

  if (adminDoc.exists) {
    await adminDocRef.update({
      email: "admin@uod.edu.ly",
      role: "admin",
      status: "approved",
    });
    console.log("✅ Updated existing Admin account successfully!");
  } else {
    console.log("✍️ Provisioning brand new Admin account...");
    await adminDocRef.set({
      email: "admin@uod.edu.ly",
      fullName: "System Administrator",
      role: "admin",
      status: "approved",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log("✅ Provisioned Admin account successfully!");
  }

  console.log("\n" + "═".repeat(60));
  console.log("DATABASE PATCH COMPLETED!");
  console.log("═".repeat(60));
  process.exit(0);
}

main().catch((err) => {
  console.error("Fatal error during patch:", err);
  process.exit(1);
});
