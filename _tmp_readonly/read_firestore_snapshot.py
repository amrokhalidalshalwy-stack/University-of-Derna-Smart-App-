import json
import sys
from pathlib import Path

import firebase_admin
from firebase_admin import credentials, firestore

PROJECT_ROOT = Path(__file__).resolve().parent.parent
KEY_PATH = PROJECT_ROOT / "serviceAccountKey.json"
PROJECT_ID = "smart-college-app-442cd"

COLLECTIONS = [
    "colleges",
    "departments",
    "courses",
    "faculty_records",
    "users",
    "schedules",
    "grades",
    "attendance",
    "registrations",
]


def serialize_value(value):
    if value is None:
        return None
    if isinstance(value, (str, int, float, bool)):
        return value
    if isinstance(value, bytes):
        return value.decode("utf-8", errors="replace")
    if isinstance(value, dict):
        return {str(k): serialize_value(v) for k, v in value.items()}
    if isinstance(value, (list, tuple)):
        return [serialize_value(v) for v in value]
    if hasattr(value, "isoformat"):
        try:
            return value.isoformat()
        except Exception:
            pass
    if hasattr(value, "path"):
        return str(value.path)
    if hasattr(value, "latitude") and hasattr(value, "longitude"):
        return {"latitude": value.latitude, "longitude": value.longitude}
    return str(value)


def doc_to_json(doc):
    data = doc.to_dict() or {}
    return {"_id": doc.id, **serialize_value(data)}


def main():
    if not KEY_PATH.exists():
        print(f"ERROR: missing key at {KEY_PATH}", file=sys.stderr)
        sys.exit(1)

    if not firebase_admin._apps:
        cred = credentials.Certificate(str(KEY_PATH))
        firebase_admin.initialize_app(cred, {"projectId": PROJECT_ID})

    db = firestore.client()

    print("=" * 80)
    print(f"Firestore READ-ONLY snapshot | project={PROJECT_ID}")
    print("=" * 80)

    for name in COLLECTIONS:
        print("\n" + "=" * 80)
        print(f"COLLECTION: {name}")
        print("=" * 80)
        col_ref = db.collection(name)
        docs = list(col_ref.stream())
        count = len(docs)
        print(f"document_count: {count}")
        print("first_2_documents:")
        if count == 0:
            print("  (empty collection)")
            continue
        sample = docs[:2]
        print(json.dumps([doc_to_json(d) for d in sample], ensure_ascii=False, indent=2))

    print("\n" + "=" * 80)
    print("USERS ANALYSIS (all documents)")
    print("=" * 80)
    users = list(db.collection("users").stream())
    role_counts = {}
    status_counts = {}
    missing_role = 0
    missing_status = 0
    for doc in users:
        data = doc.to_dict() or {}
        role = data.get("role")
        status = data.get("status")
        if role is None or role == "":
            missing_role += 1
            role_key = "(missing/empty)"
        else:
            role_key = str(role)
        role_counts[role_key] = role_counts.get(role_key, 0) + 1
        if status is None or status == "":
            missing_status += 1
            status_key = "(missing/empty)"
        else:
            status_key = str(status)
        status_counts[status_key] = status_counts.get(status_key, 0) + 1

    print(f"total_users: {len(users)}")
    print("\nby_role:")
    for k in sorted(role_counts.keys()):
        print(f"  {k}: {role_counts[k]}")
    print(f"  (users with missing/empty role field: {missing_role})")
    print("\nby_status:")
    for k in sorted(status_counts.keys()):
        print(f"  {k}: {status_counts[k]}")
    print(f"  (users with missing/empty status field: {missing_status})")


if __name__ == "__main__":
    main()
