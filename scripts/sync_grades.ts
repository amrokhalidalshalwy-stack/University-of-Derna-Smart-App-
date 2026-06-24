/**
 * Local grade sync (Option C — Spark plan, no Cloud Functions deploy).
 *
 * Prerequisites:
 *   1. cd functions && npm run build
 *   2. Download service account JSON from Firebase Console → Project settings → Service accounts
 *   3. Save as project root: serviceAccountKey.json (gitignored)
 *
 * Run:
 *   cd scripts && npm install
 *   set GOOGLE_APPLICATION_CREDENTIALS=..\serviceAccountKey.json   (Windows)
 *   npm run sync-grades
 *
 * Optional env:
 *   UOD_PORTAL_SESSION — portal session cookie
 *   UOD_RESULT_PORTAL_URL — override portal URL
 *   SYNC_DELAY_MS — delay between students (default 800)
 *   SYNC_LIMIT — max students to process (default: all)
 *   DEBUG_PORTAL_HTML=1 — on 0 parsed rows, save HTML to scripts/debug/{uid}.html
 */

import { readFileSync, existsSync } from "fs";
import { resolve } from "path";
import * as admin from "firebase-admin";
import {
  COLLEGE_MAP,
  fetchGradesFromPortal,
  resolvePortalColl,
  upsertAcademicRecords,
} from "../functions/lib/syncAcademicRecords";
import { PhpGradeRow } from "../functions/lib/parseResultPortal";

interface StudentDoc {
  uid: string;
  universityId?: string;
  student_number?: string;
  college_id?: string;
  faculty?: string;
  status?: string;
}

interface SyncStats {
  students: number;
  synced: number;
  records: number;
  skipped: number;
  errors: number;
}

function resolveKeyPath(): string {
  const fromEnv = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (fromEnv && existsSync(fromEnv)) return resolve(fromEnv);
  const rootKey = resolve(__dirname, "../serviceAccountKey.json");
  if (existsSync(rootKey)) return rootKey;
  throw new Error(
    "Service account key not found. Set GOOGLE_APPLICATION_CREDENTIALS or place serviceAccountKey.json at project root.",
  );
}

function resolveStudentNumber(data: StudentDoc): string | null {
  const id = data.student_number?.trim() || data.universityId?.trim();
  return id && id.length > 0 ? id : null;
}

function sleep(ms: number): Promise<void> {
  return new Promise((r) => setTimeout(r, ms));
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
  const session = process.env.UOD_PORTAL_SESSION;
  const delayMs = Number(process.env.SYNC_DELAY_MS ?? "800");
  const limit = process.env.SYNC_LIMIT
    ? Number(process.env.SYNC_LIMIT)
    : undefined;

  console.log("═".repeat(60));
  console.log("UOD — Local academic_records sync");
  console.log(`Key: ${keyPath}`);
  console.log(`Portal session: ${session ? "configured" : "not set"}`);
  console.log(`Colleges in map : ${Object.keys(COLLEGE_MAP).length}`);
  if (process.env.DEBUG_PORTAL_HTML === "1") {
    process.env.DEBUG_PORTAL_DIR = resolve(__dirname, "debug");
    console.log("Debug HTML      : ON → scripts/debug/{uid}.html on 0 rows");
  }
  console.log("═".repeat(60));

  const snapshot = await db
    .collection("users")
    .where("role", "==", "student")
    .get();

  let students = snapshot.docs.map((doc) => ({
    uid: doc.id,
    ...(doc.data() as Omit<StudentDoc, "uid">),
  }));

  if (limit && limit > 0) {
    students = students.slice(0, limit);
  }

  const stats: SyncStats = {
    students: students.length,
    synced: 0,
    records: 0,
    skipped: 0,
    errors: 0,
  };

  const errorLog: { uid: string; reason: string }[] = [];
  const skippedLog: { uid: string; reason: string }[] = [];

  for (let i = 0; i < students.length; i++) {
    const student = students[i];
    const label = `[${i + 1}/${students.length}] ${student.uid}`;
    const studentNumber = resolveStudentNumber(student);

    if (!studentNumber) {
      stats.skipped++;
      skippedLog.push({ uid: student.uid, reason: "missing universityId / student_number" });
      console.log(`${label} — SKIPPED (no student number)`);
      continue;
    }

    if (student.status === "rejected" || student.status === "auto_rejected") {
      stats.skipped++;
      skippedLog.push({ uid: student.uid, reason: `status=${student.status}` });
      console.log(`${label} — SKIPPED (${student.status})`);
      continue;
    }

    const coll = resolvePortalColl(student.faculty);
    if (!coll) {
      stats.skipped++;
      const reason = !student.faculty?.trim()
        ? "missing faculty"
        : `faculty not in COLLEGE_MAP: ${student.faculty}`;
      skippedLog.push({ uid: student.uid, reason });
      console.log(`${label} — SKIPPED (${reason})`);
      continue;
    }

    try {
      let rows: PhpGradeRow[];
      try {
        rows = await fetchGradesFromPortal(
          studentNumber,
          coll,
          session,
          undefined,
          student.uid,
        );
      } catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        stats.errors++;
        errorLog.push({ uid: student.uid, reason: `portal: ${msg}` });
        console.log(`${label} — ERROR (portal) ${msg}`);
        await sleep(delayMs);
        continue;
      }
      const count = await upsertAcademicRecords(
        db,
        student.uid,
        studentNumber,
        rows,
        student.college_id?.trim() || student.faculty?.trim() || null,
      );

      stats.synced++;
      stats.records += count;
      console.log(`${label} — OK (${count} records, #${studentNumber})`);
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      stats.errors++;
      errorLog.push({ uid: student.uid, reason: msg });
      console.log(`${label} — ERROR ${msg}`);
    }

    if (i < students.length - 1) {
      await sleep(delayMs);
    }
  }

  console.log("\n" + "═".repeat(60));
  console.log("SUMMARY");
  console.log(`  Students queried : ${stats.students}`);
  console.log(`  Synced OK        : ${stats.synced} (${stats.records} total records)`);
  console.log(`  Skipped          : ${stats.skipped}`);
  console.log(`  Errors           : ${stats.errors}`);
  console.log("═".repeat(60));

  if (skippedLog.length > 0) {
    console.log("\nSkipped:");
    for (const s of skippedLog) {
      console.log(`  • ${s.uid}: ${s.reason}`);
    }
  }

  if (errorLog.length > 0) {
    console.log("\nErrors:");
    for (const e of errorLog) {
      console.log(`  • ${e.uid}: ${e.reason}`);
    }
  }

  process.exit(stats.errors > 0 ? 1 : 0);
}

main().catch((err) => {
  console.error("Fatal:", err);
  process.exit(1);
});
