import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";

export const checkEmailExists = onCall(
  { region: "europe-west1" },
  async (request) => {
    const email = request.data.email as string | undefined;

    if (!email) {
      throw new HttpsError("invalid-argument", "email is required");
    }

    const snapshot = await admin
      .firestore()
      .collection("registrations")
      .where("email", "==", email)
      .limit(1)
      .get();

    return { exists: !snapshot.empty };
  }
);
