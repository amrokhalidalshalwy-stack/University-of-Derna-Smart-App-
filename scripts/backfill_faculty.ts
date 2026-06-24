/**
 * One-time backfill: copy `faculty` from registrations → users for students.
 *
 * Run:
 *   set GOOGLE_APPLICATION_CREDENTIALS=..\serviceAccountKey.json
 *   cd scripts && npm run backfill-faculty
 */

import { readFileSync, existsSync } from "fs";
import { resolve } from "path";
import * as admin from "firebase-admin";

function resolveKeyPath(): string {
  const fromEnv = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (fromEnv && existsSync(fromEnv)) return resolve(fromEnv);
  const rootKey = resolve(__dirname, "../serviceAccountKey.json");
  if (existsSync(rootKey)) return rootKey;
  throw new Error(
    "Service account key not found. Set GOOGLE_APPLICATION_CREDENTIALS or place serviceAccountKey.json at project root.",
  );
}

function hasFaculty(data: Record<string, unknown> | undefined): boolean {
  const f = data?.faculty;
  return typeof f === "string" && f.trim().length > 0;
}

async function main(): Promise<void> {
  const keyPath = resolveKeyPath();
  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert(
        JSON.parse(readFileSync(keyPath, "utf8")) as admin.ServiceAccount,
      ),
    });
  }

  const db = admin.firestore();

  console.log("═".repeat(60));
  console.log("UOD — Backfill faculty on users/{uid}");
  console.log(`Key: ${keyPath}`);
  console.log("═".repeat(60));

  const studentsSnap = await db
    .collection("users")
    .where("role", "==", "student")
    .get();

  let alreadyHad = 0;
  let updated = 0;
  let skippedNoReg = 0;
  let skippedNoFacultyInReg = 0;
  let errors = 0;

  for (const userDoc of studentsSnap.docs) {
    const uid = userDoc.id;
    const userData = userDoc.data();

    if (hasFaculty(userData)) {
      alreadyHad++;
      continue;
    }

    try {
      const regSnap = await db.collection("registrations").doc(uid).get();
      if (!regSnap.exists) {
        skippedNoReg++;
        console.log(`  ${uid} — SKIP (no registrations doc)`);
        continue;
      }

      const faculty = regSnap.data()?.faculty;
      if (typeof faculty !== "string" || !faculty.trim()) {
        skippedNoFacultyInReg++;
        console.log(`  ${uid} — SKIP (registration has no faculty)`);
        continue;
      }

      await db.collection("users").doc(uid).update({ faculty: faculty.trim() });
      updated++;
      console.log(`  ${uid} — OK → "${faculty.trim()}"`);
    } catch (err) {
      errors++;
      console.log(
        `  ${uid} — ERROR ${err instanceof Error ? err.message : String(err)}`,
      );
    }
  }

  console.log("\n" + "═".repeat(60));
  console.log("SUMMARY");
  console.log(`  Total students      : ${studentsSnap.size}`);
  console.log(`  Already had faculty : ${alreadyHad}`);
  console.log(`  Updated             : ${updated}`);
  console.log(`  Skip (no reg doc)   : ${skippedNoReg}`);
  console.log(`  Skip (no faculty)   : ${skippedNoFacultyInReg}`);
  console.log(`  Errors              : ${errors}`);
  console.log(`  With faculty now    : ${alreadyHad + updated} / ${studentsSnap.size}`);
  console.log("═".repeat(60));

  process.exit(errors > 0 ? 1 : 0);
}

main().catch((err) => {
  console.error("Fatal:", err);
  process.exit(1);
});
