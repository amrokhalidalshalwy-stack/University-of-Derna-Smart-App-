# 📖 Technical Documentation — University of Derna Smart App

**Version:** 1.0.0 | **Date:** 2026-06-11 | **Stack:** Flutter · Riverpod · GoRouter · Firebase

---

## Part 1 — Architecture

### 1.1 Application Entry Point (`lib/main.dart`)

Initialization sequence:
1. `WidgetsFlutterBinding.ensureInitialized()` + preserve native splash
2. `Firebase.initializeApp()` with 15-second timeout
3. Firestore persistence enabled (non-web) with `CACHE_SIZE_UNLIMITED`
4. `SharedPreferences.getInstance()` with 5-second timeout
5. `dotenv.load('.env')`
6. `initHive()` + `HifzhInjection.init()` (Hifzh sub-module DI)
7. Remove native splash
8. `runApp(ProviderScope(overrides: [...], child: MyApp()))`

### 1.2 Core Infrastructure

```
lib/core/
├── app_keys.dart               # rootScaffoldMessengerKey (GlobalKey)
├── colleges/college_registry.dart  # CollegeDefinition + kUodColleges list (17 colleges)
├── constants/
│   ├── app_roles.dart          # UserRole enum, RegistrationStatus enum, RejectionReasons
│   └── university_data.dart    # FacultyData, UniversityData (faculties, departments, scoring)
├── models/
│   ├── user_profile.dart       # UserProfile (Firestore + SQLite + Map serialization)
│   ├── app_notification.dart   # AppNotification
│   ├── fee_record.dart         # FeeRecord
│   ├── schedule_entry.dart     # ScheduleEntry
│   └── course_grade.dart       # CourseGrade
├── preferences/app_preferences.dart  # Theme/locale persistence via SharedPreferences
├── providers/
│   ├── app_providers.dart      # scheduleEntriesProvider, notificationListProvider, feeRecordsProvider
│   ├── user_role_provider.dart # userRoleInfoProvider (UserRoleInfo from Firestore)
│   └── student_providers.dart  # Student-specific providers
├── router/
│   ├── app_router.dart         # GoRouter config (764 lines), RouterNotifier, authStatusProvider
│   ├── auth_navigation.dart    # homePathForRole() helper
│   └── college_routes.dart     # buildCollegeRoutes() for /colleges/:slug
└── theme/app_theme.dart        # AppTheme (light/dark), AppTextStyles
```

---

## Part 2 — User Roles & Permissions

### Role Enum (`core/constants/app_roles.dart`)

```dart
enum UserRole { student, faculty, admin, guest }
enum RegistrationStatus {
  pendingFinalApproval, underReview, requiresAdditional,
  autoRejected, approved, rejected, suspended
}
```

### Role Capabilities

| Capability | Student | Faculty | Admin | Guest |
|-----------|---------|---------|-------|-------|
| View own profile | ✅ | ✅ | ✅ | ❌ |
| View grades | ✅ | ❌ | ✅ | ❌ |
| View schedule | ✅ | ✅ | ❌ | ❌ |
| Submit absence excuse | ✅ | ❌ | ❌ | ❌ |
| Enrollment renewal | ✅ | ❌ | ❌ | ❌ |
| Upload exam papers | ❌ | ✅ | ❌ | ❌ |
| Enter grades | ❌ | ✅ | ❌ | ❌ |
| View all students | ❌ | ✅ | ✅ | ❌ |
| Approve registrations | ❌ | ❌ | ✅ | ❌ |
| Manage users | ❌ | ❌ | ✅ | ❌ |
| System settings | ❌ | ❌ | ✅ | ❌ |
| View college info | ✅ | ✅ | ✅ | ✅ |

---

## Part 3 — Feature Modules

### 3.1 Authentication Module (`features/auth/`)

**Purpose:** Firebase Auth sign-in, registration, password reset.

**Key Files:**
- `data/auth_service.dart` — `AuthService` wrapping `FirebaseAuth` with Arabic error mapping
- `data/registration_service.dart` — `RegistrationService` with scoring algorithm and dual-collection write
- `presentation/pages/login_page.dart` — Portal selector login
- `presentation/pages/login_form_page.dart` — Email/password form (portal-type aware)
- `presentation/pages/sign_up_page.dart` — Multi-step registration form
- `presentation/pages/forgot_password_page.dart` — Password reset
- `presentation/pages/pending_status_page.dart` — Shows registration status to pending students

**Registration Flow:**
1. User completes multi-step form (personal → academic → confirmation)
2. `RegistrationService.register()` validates inputs (national ID format, phone format, faculty email domain)
3. Checks for duplicate national ID and phone in Firestore
4. Calculates preliminary score (0–100) based on GPA, age, completeness, faculty demand
5. Maps score to `RegistrationStatus`
6. Writes to `/users/{uid}` and `/registrations/{uid}` atomically
7. Queues notification email in `/emailQueue`
8. Returns `RegistrationResult` with score and status

**Scoring Algorithm:**
- GPA ≥85: +40pts | GPA ≥75: +30pts | GPA ≥65: +20pts | else: +10pts
- Age ≤25: +20pts | else: +15pts
- All fields filled: +20pts | else: +15pts
- High-demand faculty (Medicine, Engineering): +20pts | Medium demand: +15pts | else: +10pts
- Score ≥75 → `pending_final_approval` | ≥50 → `under_review` | else → `requires_additional`
- Score = -1 (age <17 or GPA <40 for competitive faculty) → `auto_rejected`

---

### 3.2 Admin Module (`features/admin/`)

**Purpose:** Full administrative control of the university system.

**Key Pages:**
- `admin_dashboard_page.dart` (21 KB) — Overview statistics, quick actions
- `verification_queue_page.dart` (21 KB) — Review and approve/reject registrations
- `manage_users.dart` (18 KB) — Search, view, modify user accounts
- `manage_courses.dart` (22 KB) — Course catalog management
- `manage_departments.dart` (19 KB) — Department management
- `manage_schedules.dart` (18 KB) — Schedule management
- `reports_page.dart` (12 KB) — Statistical reports
- `system_logs_page.dart` (12 KB) — System audit logs
- `system_settings.dart` (30 KB) — Comprehensive system configuration

**Routes:** `/admin/dashboard`, `/admin/verifications`, `/admin/users`, `/admin/courses`, `/admin/settings`, `/admin/reports`, `/admin/logs`

---

### 3.3 Faculty Module (`features/faculty/`)

**Purpose:** Teaching and academic management tools for faculty members.

**Key Pages:**
- `faculty_dashboard_page.dart` (69 KB) — Main faculty hub with statistics, quick actions, student management
- `faculty_students_page.dart` (33 KB) — Full student roster with search and filters
- `class_detail_page.dart` (31 KB) — Detailed class view with attendance and grades
- `faculty_assignments_page.dart` (22 KB) — Assignment management
- `faculty_attendance_sheet_page.dart` (20 KB) — Attendance recording
- `faculty_schedule_page.dart` (20 KB) — Teaching schedule
- `faculty_profile_page.dart` (21 KB) — Faculty profile management
- `faculty_reports_page.dart` (14 KB) — Teaching and performance reports
- `faculty_settings_page.dart` (15 KB) — Settings page
- `exam_paper_upload_page.dart` (10 KB) — Exam paper upload to Firebase Storage

**Routes:** `/faculty/dashboard`, `/faculty/profile`, `/faculty/schedule`, `/faculty/students`, `/faculty/attendance`, `/faculty/attendance-sheet`, `/faculty/grades-entry`, `/faculty/assignments`, `/faculty/reports`, `/faculty/exam-paper-upload`, `/faculty/settings`, `/faculty/class/:courseId`

---

### 3.4 Student Module (`features/student/`)

**Purpose:** Student-specific academic actions.

**Key Pages:**
- `absence_excuse_page.dart` (16 KB) — Submit absence excuse requests
- `enrollment_renewal_page.dart` (20 KB) — Renewal of academic enrollment
- `exam_paper_view_page.dart` (6 KB) — View exam papers (PDF viewer via Syncfusion)

---

### 3.5 Colleges Module (`features/colleges/` + `core/colleges/`)

**Purpose:** Public-facing college information portal, accessible without authentication.

**College Registry (`core/colleges/college_registry.dart`):**
- 17 `CollegeDefinition` entries covering all UOD faculties
- Each has: `id`, `nameAr`, `nameEn`, `primaryColor`, `icon`, `departments[]`, `campusAr`
- Per-college dynamic theming via `ColorScheme.fromSeed(seedColor: college.primaryColor)`
- Campus support: Derna (درنة) and Al-Qubbah (القبة)

**Pages:**
- `college_shell_page.dart` — Bottom nav shell with Home/News/Departments tabs
- `college_home_page.dart` — College header card with name, campus chip, welcome text
- `college_news_page.dart` — College news feed (placeholder)
- `college_departments_page.dart` — Department listing

**Routes:** `/colleges/:slug`, `/colleges/:slug/overview`, `/colleges/:slug/news`, `/colleges/:slug/departments`

---

### 3.6 Hifzh Module (`features/hifzh/`)

**Purpose:** Standalone Quran Hifzh (memorization) tracker — a complete sub-application embedded within the main app.

**Architecture:** Clean Architecture with:
- `domain/models/` — `SurahModel`, `HalaqahModel`, `RevisionSessionModel`, `UserModel` (Hive-backed)
- `domain/usecases/` — Use cases for Hifzh operations
- `data/repositories/` — Repository implementations
- `data/impl/` — Data source implementations
- `presentation/bloc/` — BLoC state management
- `presentation/` — 8 sub-modules: `auth/`, `halaqah/`, `home/`, `mushaf/`, `profile/`, `shell/`, `splash/`
- `core/di/` — Dependency injection (`HifzhInjection.init()`, `initHive()`)

**Storage:** Hive local database for offline Hifzh tracking; audio playback via `audioplayers`.

---

### 3.7 Transcript Module (`features/transcript/`)

**Purpose:** Academic transcript generation and viewing.

**Architecture:** `data/`, `di/`, `presentation/` sub-layers.  
**Integration:** Planned n8n webhook (`N8N_TRANSCRIPT_WEBHOOK_URL` in `.env`) for PDF generation.

---

### 3.8 Settings Module (`features/settings/`)

**Pages:**
- `settings_page.dart` — Main settings hub
- `about_page.dart` — App version and university info
- `change_password_page.dart` — Firebase Auth password update
- `edit_email_page.dart` — Email change
- `edit_profile_image_page.dart` — Profile photo via ImagePicker
- `privacy_policy_page.dart` — Privacy policy
- `support_page.dart` — Support contact
- `college_location_page.dart` — Google Maps campus location
- `developer_profile_page.dart` — Developer information

---

### 3.9 Timetable Module (`features/timetable/`)

**Current Status:** ⚠️ Mock data only.

Displays a weekly/monthly tab view with hardcoded `_sampleSessions`. No Firestore integration.  
Needs connection to `scheduleEntriesProvider` (already implemented in `core/providers/app_providers.dart`).

---

### 3.10 Other Feature Modules

| Module | Status | Description |
|--------|--------|-------------|
| `gateway` | ✅ | Portal selector page — entry point for all user types |
| `guest` | ✅ | Guest portal redirect hub |
| `grades` | ✅ | Student grade viewing |
| `fees` | ✅ | Fee records display |
| `schedule` | ✅ | Schedule overview (Firestore-connected via provider) |
| `notifications` | ⚠️ | Shows mock notifications when Firestore is empty |
| `profile` | ✅ | User profile display and edit |
| `attendance` | ✅ | Attendance records view |
| `chat` | ⚠️ | UI scaffold only |
| `inbox` | ⚠️ | UI scaffold only |
| `messages` | ⚠️ | UI scaffold only |
| `study` | ✅ | College/department info pages |
| `support` | ✅ | Support hub, report issue |
| `faq` | ✅ | FAQ page |
| `help` | ✅ | Help center |
| `contact` | ✅ | Contact form |

---

## Part 4 — Data Models

### UserProfile
```dart
class UserProfile {
  final String uid, fullName, universityId, email, gpa, completedHours, major;
  final String? profilePhotoUrl;
  final String role;    // 'student' | 'faculty' | 'admin' | 'guest'
  final String status;  // RegistrationStatus.value
  final String phone, fullNameAr, fullNameEn;
  final int? createdAtMs, updatedAtMs, syncedAtMs;
  // Supports: fromFirestore(), fromFirestoreMap(), toFirestore(),
  //           fromSqliteMap(), toSqliteMap(), toUserDataMap()
}
```

### RegistrationInput (for new registrations)
Captures: personal info (fullNameAr/En, email, phone, DoB, nationalId, gender), academic info (faculty, department, semester, graduationYear, secondaryGpa, certificateType), faculty-specific (academicDegree, academicTitle, specialization, college, employmentDate, studentPassRate), credentials (password, role, agreedToTerms, agreedToPrivacy).

### Firestore Collections

| Collection | Purpose | Access |
|-----------|---------|--------|
| `/users/{uid}` | User profile + role + status | Owner + Admin |
| `/users/{uid}/notifications/{id}` | User notifications | Owner only |
| `/users/{uid}/schedule/{id}` | Schedule entries | Owner only |
| `/users/{uid}/fees/{id}` | Fee records | Owner only |
| `/registrations/{uid}` | Registration application | Owner + Admin |
| `/faculty/{uid}` | Faculty profile | Owner + Admin |
| `/admins/{id}` | Admin records | Server-side only |
| `/emailQueue/{id}` | Email sending queue | Write-only (Functions reads) |
| `/colleges/{id}` | College data | Public read |

---

## Part 5 — Navigation Structure

### Route Tree (GoRouter)

```
/ (splash)
├── /terms
├── /login?role=
├── /login-form?portalType=
├── /signup?portalType=
├── /forgot-password
├── /gateway
├── /guest
├── /pending
├── /unauthorized
│
├── /admin/dashboard       [admin only]
├── /admin/verifications   [admin only]
├── /admin/users           [admin only]
├── /admin/courses         [admin only]
├── /admin/settings        [admin only]
├── /admin/reports         [admin only]
├── /admin/logs            [admin only]
│
├── /faculty/dashboard     [faculty only]
├── /faculty/profile       [faculty only]
├── /faculty/schedule      [faculty only]
├── /faculty/students      [faculty only]
├── /faculty/attendance    [faculty only]
├── /faculty/attendance-sheet [faculty only]
├── /faculty/grades-entry  [faculty only]
├── /faculty/assignments   [faculty only]
├── /faculty/reports       [faculty only]
├── /faculty/exam-paper-upload [faculty only]
├── /faculty/settings      [faculty only]
├── /faculty/class/:courseId [faculty only]
│
├── StatefulShellRoute (MainShell — student navigation)
│   ├── /home
│   ├── /schedule
│   ├── /notifications
│   ├── /semester
│   └── /settings
│
├── /fees, /profile, /grades, /enrollment-renewal
├── /absence-excuse, /exam-paper-view, /transcript
├── /messages, /inbox, /chat, /attendance
├── /department, /college, /timetable
├── /about, /privacy-policy, /help, /faq
├── /support, /support-hub, /contact, /report-issue
├── /college-location, /developer
├── /change-password, /edit-email, /edit-profile-image
│
└── /colleges/:slug (StatefulShellRoute — college portal)
    ├── /colleges/:slug/overview
    ├── /colleges/:slug/news
    └── /colleges/:slug/departments
```

### Redirect Logic
1. Not terms-accepted + not college path → `/terms`
2. Unauthenticated + protected path → `/gateway`
3. Authenticated + public path → role home (via `homePathForRole()`)
4. Role mismatch → `/unauthorized`
5. Pending student → `/pending`

---

## Part 6 — Providers

| Provider | Type | Source | Purpose |
|----------|------|--------|---------|
| `firebaseAuthProvider` | `Provider<FirebaseAuth>` | Firebase | Auth singleton |
| `firestoreProvider` | `Provider<FirebaseFirestore>` | Firebase | Firestore singleton |
| `authServiceProvider` | `Provider<AuthService>` | Service | Auth operations |
| `authStateChangesProvider` | `StreamProvider<User?>` | Firebase | Auth state stream |
| `registrationServiceProvider` | `Provider<RegistrationService>` | Service | Registration operations |
| `authStatusProvider` | `Provider<AuthStatus>` | Derived | Enum: authenticated/unauthenticated/unknown |
| `userRoleInfoProvider` | `StreamProvider<UserRoleInfo?>` | Firestore | Real-time role + status |
| `routerProvider` | `Provider<GoRouter>` | GoRouter | Router instance |
| `routerNotifierProvider` | `Provider<RouterNotifier>` | ChangeNotifier | Router refresh trigger |
| `termsProvider` | State | SharedPreferences | Terms acceptance state |
| `themeModeNotifierProvider` | StateNotifier | SharedPreferences | Dark/light mode |
| `localeNotifierProvider` | StateNotifier | SharedPreferences | App locale (ar/en) |
| `scheduleEntriesProvider` | `StreamProvider.family<List<ScheduleEntry>, String>` | Firestore | User schedule |
| `notificationListProvider` | `StreamProvider.family<List<AppNotification>, String>` | Firestore | User notifications |
| `feeRecordsProvider` | `StreamProvider.family<List<FeeRecord>, String>` | Firestore | User fees |
| `sharedPreferencesProvider` | `Provider<SharedPreferences>` | SharedPreferences | Injected via ProviderScope |
| `cachedUserProfileProvider` | Provider | Firestore/Cache | Cached user profile |

---

## Part 7 — Localization System

**Implementation:** Flutter gen-l10n (`intl: ^0.20.2`)

**Files:**
- `lib/l10n/app_ar.arb` — Arabic strings (~56 KB, ~800+ keys)
- `lib/l10n/app_en.arb` — English strings (~47 KB)
- `lib/l10n/app_localizations.dart` — Generated abstract class
- `lib/l10n/app_localizations_ar.dart` — Arabic implementation
- `lib/l10n/app_localizations_en.dart` — English implementation

**Configuration (`l10n.yaml`):** Template ARB: `app_en.arb`, Output: `lib/l10n/`

**Locale Persistence:** `localeNotifierProvider` persists chosen locale to SharedPreferences. App uses `localeListResolutionCallback` to always respect user preference.

**RTL Support:** `Directionality` widgets used in timetable and other RTL-sensitive layouts. `Localizations.localeOf(context).languageCode == 'ar'` pattern used throughout.

---

## Part 8 — Theme System

**Implementation:** Material 3 (`useMaterial3: true`)

**AppTheme class:**
- `lightTheme` — Primary: `#001835` (deep navy), Secondary: `#735C00` (amber), Tertiary: `#00A694` (teal)
- `darkTheme` — Inverted palette with `#0B1524` surface, golden primary
- `AppTextStyles` — Static constants for all text styles using Cairo font
- Font: `Cairo` (local asset, `fonts/Cairo-Regular.ttf`)
- Button: pill-shaped (radius 100), 56px height, full-width
- Cards: 12px radius, 0 elevation, subtle border

**Per-College Theming:** `CollegeShellPage` overrides theme with `ColorScheme.fromSeed(seedColor: college.primaryColor)` giving each college its own branded color scheme.

---

## Part 9 — Firebase Integration Details

### Authentication
- `FirebaseAuth.instance` singleton via `firebaseAuthProvider`
- Email/password only (no social auth)
- `createUserWithEmailAndPassword()` disabled in `AuthService` (throws `UnsupportedError`) — registration goes through `RegistrationService` only
- Password reset via `sendPasswordResetEmail()`
- Error codes mapped to Arabic user-facing messages (12 error codes)

### Cloud Firestore
- Persistence enabled with `CACHE_SIZE_UNLIMITED`
- `StreamProvider.autoDispose.family` pattern for per-user sub-collections
- All writes use `FieldValue.serverTimestamp()` for consistency
- Email queue pattern: client writes to `/emailQueue`, Cloud Function (planned) reads and sends

### Firebase Storage (`storage.rules`)
- `/repository/{itemId}/{fileName}` — authenticated read, faculty/admin write
- `/repository_public/{allPaths=**}` — public read, faculty/admin write
- File size limit: 50 MB
- Allowed types: PDF, DOCX, images

---

## Part 10 — Project Assessment

### Overall Scores

| Dimension | Score | Justification |
|-----------|-------|---------------|
| **Repository Health** | 6/10 | Functional app with significant gaps in planned features |
| **Code Quality** | 6/10 | Good patterns in services; inconsistent in large page files |
| **Architecture** | 5/10 | Feature-first structure good; many empty planned layers; dual state mgmt |
| **Security** | 4/10 | Wildcard Firestore rule, service account key, PII exposure |
| **Scalability** | 6/10 | Firestore pattern good; monolithic files will hurt growth |
| **Maintainability** | 5.5/10 | Good l10n and theme; dead directories, giant files, mock data in prod |

**Overall Score: 5.4/10**

---

### Top 10 Strengths

1. **Complete bilingual localization** — 800+ keys in AR/EN with RTL support throughout
2. **Robust registration pipeline** — Scoring algorithm, duplicate detection, atomic writes, email queue
3. **Role-based routing** — Comprehensive GoRouter guards for all 4 user roles
4. **Material 3 design system** — Consistent `AppTheme` + `AppTextStyles` with dark mode
5. **Per-college theming** — Dynamic `ColorScheme.fromSeed` for 17 colleges
6. **Offline-first Firestore** — Persistence with unlimited cache size
7. **Arabic error messages** — User-friendly mapped errors for all auth scenarios
8. **Clean Auth service** — `createUserWithEmailAndPassword` deliberately disabled; registration uses dedicated service
9. **Hifzh sub-module** — Full clean architecture with DI, BLoC, domain models, Hive persistence
10. **Multi-platform** — Android, iOS, Web, Windows, macOS all configured

---

### Top 10 Weaknesses

1. **Live service account key** in project directory (CRITICAL security issue)
2. **Firestore wildcard rule** bypasses all security rules (CRITICAL)
3. **Dual state management** (Riverpod + BLoC + provider) creates inconsistency
4. **Empty planned layers** (`core/database/`, `core/network/`, `core/sync/`) — architecture debt
5. **Timetable uses hardcoded mock data** — not connected to Firestore
6. **Mock notifications returned by production provider** — misleads real users
7. **Role/custom claims mismatch** — `isAdmin()` in Security Rules may never be true
8. **No repository pattern** — direct Firestore access from providers, no testability
9. **Monolithic files** — `app_router.dart` 764 lines, `faculty_dashboard_page.dart` 69 KB
10. **No automated tests** — no unit, widget, or integration tests found

---

### Top 10 Recommended Improvements

1. **🔴 IMMEDIATE: Revoke service account key** and fix Firestore wildcard rule
2. **Set Firebase Auth custom claims** via Cloud Function on admin/faculty approval
3. **Replace mock timetable** with live `scheduleEntriesProvider` data
4. **Remove mock notification fallback** — show proper empty state
5. **Remove `provider` package** and complete BLoC → Riverpod migration in Hifzh
6. **Implement `core/database/`** — complete the SQLite layer already modeled in `UserProfile`
7. **Introduce repository pattern** — `UserRepository`, `RegistrationRepository` between providers and Firestore
8. **Split `app_router.dart`** into role-specific route files
9. **Add widget tests** for registration flow, role routing, and auth states
10. **Enable Firebase App Check** to protect API keys from abuse

---

### Recommended Next Development Roadmap

**Sprint 1 (Security — 1 week):**
- Revoke service account key
- Fix Firestore rules (remove wildcard, fix registrations privacy)
- Set custom claims via Cloud Function

**Sprint 2 (Live Data — 2 weeks):**
- Connect timetable to Firestore schedule data
- Replace mock notifications with real Firestore or FCM
- Implement Cloud Functions for email sending

**Sprint 3 (Architecture — 2 weeks):**
- Implement repository pattern
- Complete SQLite offline cache layer
- Remove `provider` package

**Sprint 4 (Testing — 1 week):**
- Unit tests for `RegistrationService` scoring algorithm
- Widget tests for role-based routing
- Integration tests for registration flow

**Sprint 5 (Features — 3 weeks):**
- Complete transcript generation with n8n integration
- Full messaging/chat system
- Course enrollment management
- Grade submission workflow

**Sprint 6 (Production — 1 week):**
- Firebase App Check integration
- Crashlytics setup
- Production APK release build
- Google Play Store submission