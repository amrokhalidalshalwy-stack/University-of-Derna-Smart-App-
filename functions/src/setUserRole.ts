import * as admin from "firebase-admin";
import {
  onDocumentWritten,
  Change,
  FirestoreEvent,
  DocumentSnapshot,
} from "firebase-functions/v2/firestore";

export const assignUserRole = onDocumentWritten(
  {
    document: "users/{uid}",
    region: "europe-west1",
  },
  async (
    event: FirestoreEvent<Change<DocumentSnapshot> | undefined, { uid: string }>
  ) => {
    const uid = event.params.uid;
    const afterSnap = event.data?.after;
    if (!afterSnap || !afterSnap.exists) return;

    const data = afterSnap.data();
    if (!data) return;

    const role: string = data["role"] ?? "student";
    const facultyTitle: string | null = data["faculty_title"] ?? null;
    const collegeId: string | null = data["college_id"] ?? null;

    await admin.auth().setCustomUserClaims(uid, {
      role,
      ...(facultyTitle && { faculty_title: facultyTitle }),
      ...(collegeId && { college_id: collegeId }),
    });

    console.log(`✅ Claims set for ${uid}: role=${role}`);
  }
);
