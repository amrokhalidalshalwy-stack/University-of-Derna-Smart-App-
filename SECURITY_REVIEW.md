# 🔐 Security Review — University of Derna Smart App

**Date:** 2026-06-11 | **Project:** `smart-college-app-442cd`

---

## Executive Summary

**3 Critical · 4 High · 5 Medium · 3 Low** findings.

Most urgent: **live Firebase Admin Service Account private key is present in the project directory** and a **Firestore catch-all wildcard rule** bypasses all collection-specific rules.

---

## 🔴 CRITICAL Findings

### CRITICAL-1: Firebase Admin SDK Service Account Key in Repository

**File:** `serviceAccountKey.json`

Contains a full `"type": "service_account"` JSON with `private_key`, `client_email`, and `private_key_id` for the `smart-college-app-442cd` Firebase project.

**Risk:** Complete, unrestricted administrative access to all Firestore data, all Firebase Auth accounts, all Storage, and all Firebase services — bypassing every Security Rule.

**Remediation (IMMEDIATE):**
1. Revoke the key in **Google Cloud Console → IAM & Admin → Service Accounts**
2. Verify the file was never actually committed to git history (`git log --all -- serviceAccountKey.json`)
3. If committed: run `git filter-repo` or BFG Repo Cleaner to scrub history
4. Never store service account keys in the project directory; use Google Secret Manager
5. Audit Firebase Admin SDK usage logs for unauthorized access

**Severity:** 🔴 CRITICAL

---

### CRITICAL-2: Firestore Catch-All Wildcard Bypasses All Specific Rules

**File:** `firestore.rules` lines 71–73

```js
match /{document=**} {
  allow read, write: if isSignedIn();
}
```

**Risk:** Any authenticated user (including students) gets full read/write to every collection, including `/admins` (intended `if false`) and `/emailQueue` (read was blocked). All specific rules above are rendered ineffective.

**Remediation:** Remove the wildcard. Replace with explicit deny:
```js
match /{document=**} { allow read, write: if false; }
```

**Severity:** 🔴 CRITICAL

---

### CRITICAL-3: Firebase Client API Keys in Version-Controlled Source

**File:** `lib/firebase_options.dart`

Web key `AIzaSyD3DgB4P3j...` and Android key `AIzaSyCAvEza5...` are Dart compile-time constants. These are standard Flutter practice but dangerous when combined with CRITICAL-2.

**Remediation:** Fix Security Rules (CRITICAL-2) and enable **Firebase App Check** + restrict API keys to specific bundle IDs in Google Cloud Console.

**Severity:** 🔴 CRITICAL (amplified by CRITICAL-2; inherently Medium alone)

---

## 🟠 HIGH Findings

### HIGH-1: Registrations Collection — Public PII Read

```js
allow get: if true;           // Unauthenticated read of any registration (national ID, DoB, phone)
allow list: if isSignedIn();  // Any student can list ALL registrations
allow update: if isAdmin() || (isSignedIn() && request.auth.uid == uid); // Student can set status='approved'
```

**Fix:**
```js
match /registrations/{uid} {
  allow get: if isOwner(uid) || isAdmin();
  allow list: if isAdmin();
  allow create: if isSignedIn() && request.auth.uid == uid;
  allow update: if isAdmin();
}
```
**Severity:** 🟠 HIGH

---

### HIGH-2: Faculty Can Self-Modify Any Field Including Role/Status

`allow read, update, delete: if isSignedIn() && request.auth.uid == userId` — no field restriction.

**Fix:** Add `notChangingRoleOrStatus()` guard. **Severity:** 🟠 HIGH

---

### HIGH-3: `.env` File Contains Sensitive Configuration Keys

Comment: "This file contains real API keys." Contains `N8N_TRANSCRIPT_TOKEN` and `QURAN_API_KEY` fields. If populated with real values, they get bundled into the APK.

**Fix:** Use `--dart-define` compile-time flags, not bundled `.env` files for production. **Severity:** 🟠 HIGH

---

### HIGH-4: Role Read from Firestore but Security Rules Expect Auth Custom Claims

App reads `data['role']` from Firestore. Rules use `request.auth.token.role`. If custom claims are not set server-side, `isAdmin()` always returns `false` — meaning admin enforcement is non-functional.

**Fix:** Set custom claims via Cloud Functions on account approval, OR rewrite rules to read role from the Firestore document:
```js
function getRole() {
  return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
}
```
**Severity:** 🟠 HIGH

---

## 🟡 MEDIUM Findings

| # | Finding | Fix |
|---|---------|-----|
| M-1 | Colleges collection: `allow write: if isSignedIn()` — any student can delete college records | `allow write: if isAdmin()` |
| M-2 | Client-side router role guards are UX-only, bypassable without server-side rules | Fix underlying Firestore rules |
| M-3 | Student can self-approve registration via update rule (no field restriction) | Restrict updates to admin only |
| M-4 | Timetable uses hardcoded mock sessions presented as real schedule | Connect to Firestore schedule collection |
| M-5 | Notifications fallback returns hardcoded fake exam announcements | Seed real data or show empty state |

---

## 🟢 LOW Findings

| # | Finding |
|---|---------|
| L-1 | 550 MB Firebase CLI executables committed to repository root (should use npm install) |
| L-2 | `debugPrint` logs auth status, role, and route paths (stripped in release by Flutter) |
| L-3 | Registration failure cleanup silently swallows `account.delete()` errors → orphan accounts |

---

## Corrected Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() { return request.auth != null; }
    function isOwner(uid) { return isSignedIn() && request.auth.uid == uid; }
    function isAdmin() { return isSignedIn() && request.auth.token.role == 'admin'; }
    function notChangingProtected() {
      return !request.resource.data.diff(resource.data)
        .affectedKeys().hasAny(['role', 'status', 'preliminaryScore']);
    }

    match /users/{userId} {
      allow create: if isOwner(userId);
      allow read: if isOwner(userId) || isAdmin();
      allow update: if isAdmin() || (isOwner(userId) && notChangingProtected());
      allow delete: if isAdmin();
      match /notifications/{docId} { allow read, write: if isOwner(userId); }
      match /schedule/{docId} { allow read, write: if isOwner(userId); }
      match /fees/{docId} { allow read, write: if isOwner(userId); }
    }

    match /registrations/{uid} {
      allow get: if isOwner(uid) || isAdmin();
      allow list: if isAdmin();
      allow create: if isSignedIn() && request.auth.uid == uid;
      allow update: if isAdmin();
    }

    match /faculty/{userId} {
      allow create: if isSignedIn() && request.auth.uid == userId;
      allow read: if isOwner(userId) || isAdmin();
      allow update: if isAdmin() || (isOwner(userId) && notChangingProtected());
      allow delete: if isAdmin();
    }

    match /admins/{adminId} { allow read, write: if false; }
    match /emailQueue/{docId} { allow read: if false; allow create: if isSignedIn(); }
    match /colleges/{collegeId} { allow read: if true; allow write: if isAdmin(); }
    match /{document=**} { allow read, write: if false; } // Default deny
  }
}
```

---

## Security Scorecard

| Category | Score |
|---|---|
| Credentials Management | 1/10 |
| Firestore Rules | 3/10 |
| Storage Rules | 7/10 |
| Authentication | 6/10 |
| Authorization | 4/10 |
| Data Privacy (PII) | 3/10 |

**Overall Security Score: 4/10**

> ⚠️ CRITICAL-1 (service account key) and CRITICAL-2 (wildcard rule) must be resolved before any production deployment.
