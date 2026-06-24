/**
 * syncAcademicRecords — Callable middleware: UOD PHP results portal → Firestore.
 *
 * Deploy (Blaze plan required):
 *   firebase deploy --only functions:syncAcademicRecords
 *
 * Optional secret (portal session cookie):
 *   firebase functions:secrets:set UOD_PORTAL_SESSION
 */

import { createHash } from "crypto";
import { mkdirSync, writeFileSync } from "fs";
import { join } from "path";
import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import { parseResultHtml, PhpGradeRow } from "./parseResultPortal";

const uodPortalSession = defineSecret("UOD_PORTAL_SESSION");

const PORTAL_URL =
  process.env.UOD_RESULT_PORTAL_URL ??
  "https://uod.edu.ly/Result_College.php";

/** Verified from Result_College.php — `coll` is the Arabic college name. */
export const COLLEGE_MAP: Record<string, string> = {
  "كلية الهندسة": "كلية الهندسة",
  "كلية القانون": "كلية القانون",
  "كلية العلوم": "كلية العلوم",
  "كلية الاقتصاد": "كلية الاقتصاد",
  "كلية التربية": "كلية التربية",
  "كلية الآداب": "كلية الآداب",
  "كلية الطب": "كلية الطب",
  "كلية الصيدلة": "كلية الصيدلة",
};

interface UserProfile {
  role?: string;
  universityId?: string;
  student_number?: string;
  college_id?: string;
  faculty?: string;
}

interface SyncResponse {
  synced: number;
  status: "ok" | "partial" | "stale";
  semester?: string;
}

function rowHash(row: PhpGradeRow, uid: string): string {
  return createHash("sha256")
    .update(`${uid}|${row.semester}|${row.courseCode}|${row.grade}`)
    .digest("hex");
}

function resolveStudentNumber(profile: UserProfile): string | null {
  const id = profile.student_number?.trim() || profile.universityId?.trim();
  return id && id.length > 0 ? id : null;
}

/** Resolves portal `coll` from Firestore `faculty` (Arabic college name). */
export function resolvePortalColl(faculty: string | undefined): string | null {
  const trimmed = faculty?.trim();
  if (!trimmed) return null;
  return COLLEGE_MAP[trimmed] ?? null;
}

function isDebugPortalHtmlEnabled(): boolean {
  return process.env.DEBUG_PORTAL_HTML === "1";
}

/** Saves raw portal HTML when parser returns zero rows (local sync debugging). */
export function savePortalDebugHtml(uid: string, html: string): string {
  const dir =
    process.env.DEBUG_PORTAL_DIR?.trim() ||
    join(process.cwd(), "scripts", "debug");
  mkdirSync(dir, { recursive: true });
  const filePath = join(dir, `${uid}.html`);
  writeFileSync(filePath, html, "utf8");
  return filePath;
}

/**
 * Fetches and parses grades from the legacy PHP portal (server-side only).
 *
 * @param debugUid — when `DEBUG_PORTAL_HTML=1` and parser returns 0 rows, saves HTML to `scripts/debug/{uid}.html`
 */
export async function fetchGradesFromPortal(
  studentNumber: string,
  coll: string,
  sessionCookie?: string,
  semester?: string,
  debugUid?: string,
): Promise<PhpGradeRow[]> {
  const headers: Record<string, string> = {
    "Content-Type": "application/x-www-form-urlencoded",
    "User-Agent": "UOD-Portal-Sync/1.0",
  };

  if (sessionCookie?.trim()) {
    headers.Cookie = sessionCookie.trim();
  }

  const response = await fetch(PORTAL_URL, {
    method: "POST",
    headers,
    body: new URLSearchParams({
      id_Student: studentNumber,
      coll,
      Send: "1",
    }),
    signal: AbortSignal.timeout(25_000),
  });

  if (!response.ok) {
    throw new HttpsError(
      "unavailable",
      `Results portal returned HTTP ${response.status}`,
    );
  }

  const html = await response.text();

  if (html.includes("login") && html.toLowerCase().includes("password")) {
    throw new HttpsError(
      "failed-precondition",
      "Portal session expired — configure UOD_PORTAL_SESSION secret",
    );
  }

  const rows = parseResultHtml(html, semester);
  if (rows.length === 0) {
    if (isDebugPortalHtmlEnabled() && debugUid?.trim()) {
      savePortalDebugHtml(debugUid.trim(), html);
      console.log(
        `[DEBUG] HTML saved → scripts/debug/${debugUid.trim()}.html`,
      );
    }
    throw new HttpsError(
      "not-found",
      "No grades parsed — verify student number or portal HTML structure",
    );
  }

  return rows;
}

/**
 * Upserts parsed rows into `academic_records` (Admin SDK bypasses client write deny).
 */
export async function upsertAcademicRecords(
  db: admin.firestore.Firestore,
  uid: string,
  studentNumber: string,
  rows: PhpGradeRow[],
  collegeId: string | null,
): Promise<number> {
  const batch = db.batch();
  const now = admin.firestore.FieldValue.serverTimestamp();

  for (const row of rows) {
    const recordId = `${uid}_${row.semester}_${row.courseCode}`;
    const ref = db.collection("academic_records").doc(recordId);

    batch.set(
      ref,
      {
        student_uid: uid,
        student_number: studentNumber,
        course_id: row.courseCode,
        course_name_ar: row.courseName,
        grade: row.grade,
        semester: row.semester,
        college_id: collegeId,
        source_hash: rowHash(row, uid),
        synced_at: now,
        sync_status: "ok",
      },
      { merge: true },
    );
  }

  await batch.commit();
  return rows.length;
}

export const syncAcademicRecords = onCall(
  {
    region: "europe-west1",
    secrets: [uodPortalSession],
    timeoutSeconds: 60,
    memory: "256MiB",
  },
  async (request): Promise<SyncResponse> => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required");
    }

    const uid = request.auth.uid;
    const db = admin.firestore();
    const userSnap = await db.doc(`users/${uid}`).get();

    if (!userSnap.exists) {
      throw new HttpsError("not-found", "User profile not found");
    }

    const profile = userSnap.data() as UserProfile;
    const role = profile.role ?? "student";

    if (role !== "student" && role !== "admin") {
      throw new HttpsError(
        "permission-denied",
        "Only students and admins may sync academic records",
      );
    }

    const studentNumber = resolveStudentNumber(profile);
    if (!studentNumber) {
      throw new HttpsError(
        "failed-precondition",
        "Missing universityId / student_number on user profile",
      );
    }

    const coll = resolvePortalColl(profile.faculty);
    if (!coll) {
      throw new HttpsError(
        "failed-precondition",
        "Missing or unsupported faculty — must match a portal college name",
      );
    }

    const semester =
      typeof request.data?.semester === "string"
        ? request.data.semester
        : undefined;

    let rows: PhpGradeRow[];
    try {
      rows = await fetchGradesFromPortal(
        studentNumber,
        coll,
        uodPortalSession.value(),
        semester,
      );
    } catch (err) {
      if (err instanceof HttpsError) throw err;
      throw new HttpsError(
        "unavailable",
        err instanceof Error ? err.message : "Portal fetch failed",
      );
    }

    const collegeId =
      profile.college_id?.trim() || profile.faculty?.trim() || null;
    const synced = await upsertAcademicRecords(
      db,
      uid,
      studentNumber,
      rows,
      collegeId,
    );

    return {
      synced,
      status: "ok",
      semester: rows[0]?.semester,
    };
  },
);
