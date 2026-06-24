"""
seed_firestore.py
=================
Firestore Data Seeding Script for UOD Student Forum
(ساحة النقاش الطلابية - جامعة درنة)

Usage:
  1. Install dependencies:
       pip install firebase-admin

  2. Download your Firebase service account key:
       Firebase Console → Project Settings → Service Accounts → Generate new private key
       Save as "serviceAccountKey.json" in the same folder as this script.

  3. Run:
       python seed_firestore.py

  NOTE: The script is idempotent — running it multiple times will only
        UPDATE existing documents, never duplicate them, because we use
        document IDs derived from the data itself.
"""

import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timezone

# ─────────────────────────────────────────────
# 1. INITIALIZE FIREBASE
# ─────────────────────────────────────────────
SERVICE_ACCOUNT_PATH = "serviceAccountKey.json"   # ← change if needed

cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
firebase_admin.initialize_app(cred)
db = firestore.client()

print("✅ Firebase connected successfully.\n")


# ─────────────────────────────────────────────
# 2. DATA: MAJORS (التخصصات)
# ─────────────────────────────────────────────
MAJORS = [
    {
        "id": "cs",
        "nameAr": "علوم الحاسوب",
        "nameEn": "Computer Science",
        "code": "CS",
        "order": 1,
    },
    {
        "id": "eng",
        "nameAr": "الهندسة",
        "nameEn": "Engineering",
        "code": "ENG",
        "order": 2,
    },
    {
        "id": "med",
        "nameAr": "الطب",
        "nameEn": "Medicine",
        "code": "MED",
        "order": 3,
    },
    {
        "id": "law",
        "nameAr": "القانون",
        "nameEn": "Law",
        "code": "LAW",
        "order": 4,
    },
    {
        "id": "econ",
        "nameAr": "الاقتصاد والإدارة",
        "nameEn": "Economics & Business Administration",
        "code": "ECON",
        "order": 5,
    },
    {
        "id": "edu",
        "nameAr": "التربية",
        "nameEn": "Education",
        "code": "EDU",
        "order": 6,
    },
    {
        "id": "sci",
        "nameAr": "العلوم",
        "nameEn": "Science",
        "code": "SCI",
        "order": 7,
    },
    {
        "id": "arts",
        "nameAr": "الآداب واللغات",
        "nameEn": "Arts & Languages",
        "code": "ARTS",
        "order": 8,
    },
]


# ─────────────────────────────────────────────
# 3. DATA: COURSES (المواد الدراسية)
# ─────────────────────────────────────────────
COURSES = [
    # ── Computer Science (cs) ──────────────────────────────────
    {
        "id": "cs101",
        "majorId": "cs",
        "code": "CS101",
        "nameAr": "مقدمة في البرمجة",
        "nameEn": "Introduction to Programming",
        "creditHours": 3,
        "semester": 1,
    },
    {
        "id": "cs201",
        "majorId": "cs",
        "code": "CS201",
        "nameAr": "هياكل البيانات والخوارزميات",
        "nameEn": "Data Structures & Algorithms",
        "creditHours": 3,
        "semester": 3,
    },
    {
        "id": "cs302",
        "majorId": "cs",
        "code": "CS302",
        "nameAr": "قواعد البيانات",
        "nameEn": "Database Systems",
        "creditHours": 3,
        "semester": 4,
    },
    {
        "id": "cs310",
        "majorId": "cs",
        "code": "CS310",
        "nameAr": "الشبكات والاتصالات",
        "nameEn": "Computer Networks",
        "creditHours": 3,
        "semester": 5,
    },
    {
        "id": "cs401",
        "majorId": "cs",
        "code": "CS401",
        "nameAr": "الذكاء الاصطناعي",
        "nameEn": "Artificial Intelligence",
        "creditHours": 3,
        "semester": 7,
    },
    {
        "id": "cs420",
        "majorId": "cs",
        "code": "CS420",
        "nameAr": "أمن المعلومات",
        "nameEn": "Information Security",
        "creditHours": 3,
        "semester": 7,
    },
    {
        "id": "cs430",
        "majorId": "cs",
        "code": "CS430",
        "nameAr": "تطوير تطبيقات الهاتف المحمول",
        "nameEn": "Mobile Application Development",
        "creditHours": 3,
        "semester": 8,
    },
    {
        "id": "cs450",
        "majorId": "cs",
        "code": "CS450",
        "nameAr": "الحوسبة السحابية",
        "nameEn": "Cloud Computing",
        "creditHours": 3,
        "semester": 8,
    },

    # ── Engineering (eng) ─────────────────────────────────────
    {
        "id": "eng101",
        "majorId": "eng",
        "code": "ENG101",
        "nameAr": "مقدمة في الهندسة",
        "nameEn": "Introduction to Engineering",
        "creditHours": 2,
        "semester": 1,
    },
    {
        "id": "eng210",
        "majorId": "eng",
        "code": "ENG210",
        "nameAr": "ميكانيكا المواد",
        "nameEn": "Mechanics of Materials",
        "creditHours": 3,
        "semester": 3,
    },
    {
        "id": "eng305",
        "majorId": "eng",
        "code": "ENG305",
        "nameAr": "الدوائر الكهربائية",
        "nameEn": "Electric Circuits",
        "creditHours": 4,
        "semester": 5,
    },
    {
        "id": "eng410",
        "majorId": "eng",
        "code": "ENG410",
        "nameAr": "نظم التحكم الآلي",
        "nameEn": "Control Systems",
        "creditHours": 3,
        "semester": 7,
    },

    # ── Medicine (med) ────────────────────────────────────────
    {
        "id": "med101",
        "majorId": "med",
        "code": "MED101",
        "nameAr": "التشريح البشري",
        "nameEn": "Human Anatomy",
        "creditHours": 4,
        "semester": 1,
    },
    {
        "id": "med201",
        "majorId": "med",
        "code": "MED201",
        "nameAr": "علم وظائف الأعضاء",
        "nameEn": "Physiology",
        "creditHours": 4,
        "semester": 3,
    },
    {
        "id": "med310",
        "majorId": "med",
        "code": "MED310",
        "nameAr": "الأمراض الداخلية",
        "nameEn": "Internal Medicine",
        "creditHours": 5,
        "semester": 5,
    },

    # ── Law (law) ─────────────────────────────────────────────
    {
        "id": "law101",
        "majorId": "law",
        "code": "LAW101",
        "nameAr": "مبادئ القانون المدني",
        "nameEn": "Principles of Civil Law",
        "creditHours": 3,
        "semester": 1,
    },
    {
        "id": "law202",
        "majorId": "law",
        "code": "LAW202",
        "nameAr": "القانون الدستوري",
        "nameEn": "Constitutional Law",
        "creditHours": 3,
        "semester": 3,
    },
    {
        "id": "law310",
        "majorId": "law",
        "code": "LAW310",
        "nameAr": "القانون التجاري",
        "nameEn": "Commercial Law",
        "creditHours": 3,
        "semester": 5,
    },

    # ── Economics & Business (econ) ───────────────────────────
    {
        "id": "econ101",
        "majorId": "econ",
        "code": "ECON101",
        "nameAr": "مبادئ الاقتصاد الجزئي",
        "nameEn": "Principles of Microeconomics",
        "creditHours": 3,
        "semester": 1,
    },
    {
        "id": "econ205",
        "majorId": "econ",
        "code": "ECON205",
        "nameAr": "إدارة الأعمال",
        "nameEn": "Business Administration",
        "creditHours": 3,
        "semester": 3,
    },
    {
        "id": "econ301",
        "majorId": "econ",
        "code": "ECON301",
        "nameAr": "المحاسبة المالية",
        "nameEn": "Financial Accounting",
        "creditHours": 3,
        "semester": 5,
    },

    # ── Education (edu) ───────────────────────────────────────
    {
        "id": "edu101",
        "majorId": "edu",
        "code": "EDU101",
        "nameAr": "أسس التربية",
        "nameEn": "Foundations of Education",
        "creditHours": 3,
        "semester": 1,
    },
    {
        "id": "edu210",
        "majorId": "edu",
        "code": "EDU210",
        "nameAr": "علم النفس التربوي",
        "nameEn": "Educational Psychology",
        "creditHours": 3,
        "semester": 3,
    },

    # ── Science (sci) ─────────────────────────────────────────
    {
        "id": "sci101",
        "majorId": "sci",
        "code": "SCI101",
        "nameAr": "الكيمياء العامة",
        "nameEn": "General Chemistry",
        "creditHours": 4,
        "semester": 1,
    },
    {
        "id": "sci102",
        "majorId": "sci",
        "code": "SCI102",
        "nameAr": "الفيزياء العامة",
        "nameEn": "General Physics",
        "creditHours": 4,
        "semester": 1,
    },
    {
        "id": "sci201",
        "majorId": "sci",
        "code": "SCI201",
        "nameAr": "الرياضيات المتقدمة",
        "nameEn": "Advanced Mathematics",
        "creditHours": 3,
        "semester": 3,
    },

    # ── Arts & Languages (arts) ───────────────────────────────
    {
        "id": "arts101",
        "majorId": "arts",
        "code": "ARTS101",
        "nameAr": "اللغة العربية وآدابها",
        "nameEn": "Arabic Language & Literature",
        "creditHours": 3,
        "semester": 1,
    },
    {
        "id": "arts102",
        "majorId": "arts",
        "code": "ARTS102",
        "nameAr": "اللغة الإنجليزية",
        "nameEn": "English Language",
        "creditHours": 3,
        "semester": 1,
    },
    {
        "id": "arts210",
        "majorId": "arts",
        "code": "ARTS210",
        "nameAr": "تاريخ الحضارات",
        "nameEn": "History of Civilizations",
        "creditHours": 3,
        "semester": 3,
    },
]


# ─────────────────────────────────────────────
# 4. SEEDING FUNCTIONS
# ─────────────────────────────────────────────

def seed_collection(collection_name: str, items: list[dict], id_key: str = "id") -> None:
    """
    Write all items to Firestore using set() with merge=True.
    This is fully idempotent — safe to run repeatedly.
    """
    collection_ref = db.collection(collection_name)
    batch = db.batch()
    count = 0

    for item in items:
        doc_id = item.pop(id_key)           # use the 'id' field as doc ID
        item["seededAt"] = datetime.now(timezone.utc)   # audit timestamp

        doc_ref = collection_ref.document(doc_id)
        batch.set(doc_ref, item, merge=True)
        count += 1

        # Firestore batches max out at 500 operations
        if count % 400 == 0:
            batch.commit()
            batch = db.batch()
            print(f"  → Committed {count} documents to '{collection_name}' so far…")

    batch.commit()
    print(f"✅ '{collection_name}' — {count} documents seeded successfully.")


def seed_sample_forum_post() -> None:
    """
    Seeds one sample approved post for the CS302 course so the forum
    is not empty on first launch.
    """
    post_data = {
        "courseId": "cs302",
        "majorId": "cs",
        "title": "سؤال عن العلاقة بين مفتاح الأساس والمفتاح الخارجي",
        "content": (
            "السلام عليكم، أنا أدرس الفصل الثالث من المادة وعندي إشكالية في "
            "فهم الفرق العملي بين PRIMARY KEY وFOREIGN KEY في سياق قاعدة "
            "بيانات علائقية. هل يمكن لأحد أن يشرح لي مع مثال عملي؟ شكراً."
        ),
        "authorUid": "sample_uid_001",
        "authorName": "طالب نموذجي",
        "authorPhotoUrl": None,
        "createdAt": firestore.SERVER_TIMESTAMP,
        "updatedAt": firestore.SERVER_TIMESTAMP,
        "references": [],
        "tags": ["قواعد البيانات", "SQL", "مفاتيح"],
        "status": "approved",
        "isPinned": False,
        "viewsCount": 0,
        "commentsCount": 0,
    }

    db.collection("forum_posts").document("sample_post_cs302_001").set(
        post_data, merge=True
    )
    print("✅ 'forum_posts' — 1 sample post seeded for CS302.")


# ─────────────────────────────────────────────
# 5. FIRESTORE SECURITY RULES (printed as a reminder)
# ─────────────────────────────────────────────

SECURITY_RULES_REMINDER = """
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 REMINDER — Add these Firestore Security Rules:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Majors & Courses — public read, admin write only
    match /majors/{majorId} {
      allow read: if true;
      allow write: if request.auth != null
                   && request.auth.token.role == 'admin';
    }
    match /courses/{courseId} {
      allow read: if true;
      allow write: if request.auth != null
                   && request.auth.token.role == 'admin';
    }

    // Forum Posts — authenticated read & create; owner or admin can edit
    match /forum_posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
                    && request.resource.data.authorUid == request.auth.uid;
      allow update: if request.auth != null
                    && (resource.data.authorUid == request.auth.uid
                        || request.auth.token.role == 'admin');
      allow delete: if request.auth != null
                    && request.auth.token.role == 'admin';

      // Comments sub-collection
      match /comments/{commentId} {
        allow read: if request.auth != null;
        allow create: if request.auth != null
                      && request.resource.data.authorUid == request.auth.uid;
        allow delete: if request.auth != null
                      && request.auth.token.role == 'admin';
      }
    }

    // Moderation Queue — admin only
    match /moderation_queue/{docId} {
      allow read, write: if request.auth != null
                         && request.auth.token.role == 'admin';
    }
  }
}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"""


# ─────────────────────────────────────────────
# 6. MAIN
# ─────────────────────────────────────────────

if __name__ == "__main__":
    print("🌱 Starting Firestore data seeding…\n")

    seed_collection("majors", MAJORS)
    seed_collection("courses", COURSES)
    seed_sample_forum_post()

    print(SECURITY_RULES_REMINDER)
    print("🎉 All done! Your Firestore database is ready.")