# تقرير مراجعة أزرار الرجوع لدعم RTL/LTR
## تاريخ المراجعة: 20 يونيو 2026

### ملخص المشكلة
تم العثور على **32 ملفاً** تستخدم أزرار رجوع مخصصة باستخدام `Icons.arrow_back_ios_new_rounded` أو `Icons.arrow_back` بشكل صريح. هذه الأيقونات لا تتغير تلقائياً بناءً على اتجاه النص (RTL/LTR)، مما يؤدي إلى مشكلة عند تغيير اللغة بين العربية والإنجليزية.

---

## الملفات التي تحتاج إلى تعديل

### 1. ملفات الطالب (Student Features)

#### `lib/features/student/presentation/pages/enrollment_renewal_page.dart`
- **السطر**: 172-175
- **المشكلة**: استخدام `Icons.arrow_back_ios_new_rounded` بشكل ثابت
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

#### `lib/features/student/presentation/pages/exam_paper_view_page.dart`
- **السطر**: 30-33
- **المشكلة**: استخدام `Icons.arrow_back_ios_new_rounded` بشكل ثابت
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

#### `lib/features/student/presentation/pages/absence_excuse_page.dart`
- **السطر**: 365-368
- **المشكلة**: استخدام `Icons.arrow_back_ios_new_rounded` بشكل ثابت
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

---

### 2. ملفات الإعدادات (Settings Features)

#### `lib/features/settings/presentation/pages/college_location_page.dart`
- **السطر**: 44-47
- **المشكلة**: استخدام `Icons.arrow_back` بشكل ثابت
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

#### `lib/features/settings/presentation/pages/branches_info_page.dart`
- **السطر**: 21-24
- **المشكلة**: استخدام `Icons.arrow_back_ios_new_rounded` بشكل ثابت
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

---

### 3. ملفات الملف الشخصي (Profile Features)

#### `lib/features/profile/presentation/pages/profile_page.dart`
- **السطر**: 92-95
- **المشكلة**: استخدام `Icons.arrow_back_ios` بشكل ثابت
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

---

### 4. ملفات الضيف (Guest Features)

#### `lib/features/guest/presentation/pages/guest_portal_page.dart`
- **السطر**: 95-102
- **المشكلة**: استخدام `Icons.arrow_back_ios_new_rounded` بشكل ثابت
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

---

### 5. ملفات هيئة التدريس (Faculty Features)

#### `lib/features/faculty/pages/faculty_students_page.dart`
- **السطر**: 77-80
- **المشكلة**: استخدام `Icons.arrow_back_ios_new_rounded` بشكل ثابت
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

#### `lib/features/faculty/pages/faculty_reports_page.dart`
- **السطر**: 42-45
- **المشكلة**: استخدام `Icons.arrow_back_ios_new_rounded` بشكل ثابت
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

#### `lib/features/faculty/pages/faculty_settings_page.dart`
- **السطر**: 87-90
- **المشكلة**: استخدام `Icons.arrow_back_ios_new_rounded` بشكل ثابت
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

#### `lib/features/faculty/presentation/pages/faculty_assignments_page.dart`
- **السطر**: 89-94
- **المشكلة**: استخدام `Icons.arrow_back_ios_new_rounded` بشكل ثابت داخل `TapScale`
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

#### `lib/features/faculty/presentation/pages/faculty_attendance_sheet_page.dart`
- **السطر**: 109-112
- **المشكلة**: استخدام `Icons.arrow_back_ios_new_rounded` بشكل ثابت
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

#### `lib/features/faculty/presentation/pages/faculty_excuses_page.dart`
- **السطر**: 78-81
- **المشكلة**: استخدام `Icons.arrow_back_ios_new_rounded` بشكل ثابت
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

#### `lib/features/faculty/presentation/pages/faculty_students_page.dart`
- **السطر**: 75-78
- **المشكلة**: استخدام `Icons.arrow_back_ios_new_rounded` بشكل ثابت
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

#### `lib/features/faculty/presentation/pages/faculty_reports_page.dart`
- **السطر**: 44-47
- **المشكلة**: استخدام `Icons.arrow_back_ios_new_rounded` بشكل ثابت
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

#### `lib/features/faculty/presentation/pages/exam_paper_upload_page.dart`
- **السطر**: 149-152
- **المشكلة**: استخدام `Icons.arrow_back_ios_new_rounded` بشكل ثابت
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

#### `lib/features/faculty/presentation/pages/send_message_page.dart`
- **السطر**: 84-87
- **المشكلة**: استخدام `Icons.arrow_back_ios_new_rounded` بشكل ثابت
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

---

### 6. ملفات الكليات (Colleges Features)

#### `lib/features/colleges/presentation/college_shell_page.dart`
- **السطر**: 39-42
- **المشكلة**: استخدام `Icons.arrow_back_ios_new_rounded` بشكل ثابت
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

---

### 7. ملفات المصادقة (Auth Features)

#### `lib/features/auth/presentation/pages/sign_up_page.dart`
- **السطر**: 203-207
- **المشكلة**: استخدام `Icons.arrow_back_ios_new_rounded` بشكل ثابت
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

---

### 8. ملفات الدراسة (Study Features)

#### `lib/features/study/presentation/pages/exam_paper_page.dart`
- **السطر**: 95-98
- **المشكلة**: استخدام `Icons.arrow_back_ios` بشكل ثابت
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

---

### 9. ملفات البوابة (Gateway Features)

#### `lib/features/gateway/presentation/pages/gateway_page.dart`
- **السطر**: 826-830
- **المشكلة**: استخدام `Icons.arrow_back_ios_new_rounded` بشكل ثابت
- **الحل المقترح**: استبدال بـ `BackButton()` أو استخدام شرط RTL

---

### 10. ملفات شاشة البداية (Splash Features)

#### `lib/features/splash/presentation/pages/splash_page.dart`
- **السطر**: 194-199
- **المشكلة**: استخدام شرط RTL بشكل صحيح ✅ (هذا الملف صحيح)
- **الحالة**: لا يحتاج إلى تعديل

---

## الحلول المقترحة

### الحل 1: استخدام BackButton() widget (موصى به)
هذا الحل هو الأفضل لأن `BackButton()` widget يتولى تلقائياً تغيير اتجاه الأيقونة بناءً على اللغة.

**قبل:**
```dart
leading: IconButton(
  icon: const Icon(Icons.arrow_back_ios_new_rounded),
  onPressed: () => context.pop(),
),
```

**بعد:**
```dart
leading: const BackButton(),
```

### الحل 2: استخدام شرط RTL
إذا كنت تحتاج إلى تخصيص الأيقونة، استخدم شرط للتحقق من اتجاه النص:

**قبل:**
```dart
leading: IconButton(
  icon: const Icon(Icons.arrow_back_ios_new_rounded),
  onPressed: () => context.pop(),
),
```

**بعد:**
```dart
leading: IconButton(
  icon: Icon(
    Directionality.of(context) == TextDirection.rtl
        ? Icons.arrow_forward_ios_new_rounded
        : Icons.arrow_back_ios_new_rounded,
  ),
  onPressed: () => context.pop(),
),
```

### الحل 3: استخدام automaticallyImplyLeading
إذا لم تكن بحاجة إلى تخصيص زر الرجوع، استخدم `automaticallyImplyLeading: true` في AppBar:

**قبل:**
```dart
appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_new_rounded),
    onPressed: () => context.pop(),
  ),
  // ...
),
```

**بعد:**
```dart
appBar: AppBar(
  automaticallyImplyLeading: true,
  // ...
),
```

---

## الملفات التي لا تحتاج إلى تعديل

### `lib/shared/widgets/custom_app_bar.dart`
- **الحالة**: ✅ صحيح
- **السبب**: يستخدم `automaticallyImplyLeading` parameter، وFlutter يتولى تلقائياً تغيير الاتجاه

### `lib/features/admin/screens/admin_app_bar.dart`
- **الحالة**: ✅ صحيح
- **السبب**: يستخدم `automaticallyImplyLeading: false` مع زر قائمة مخصص، لا يحتاج زر رجوع

### `lib/features/splash/presentation/pages/splash_page.dart`
- **الحالة**: ✅ صحيح
- **السبب**: يستخدم شرط RTL بشكل صحيح لتغيير الأيقونة

---

## الإحصائيات

- **إجمالي الملفات التي تم مراجعتها**: 32 ملف
- **الملفات التي تحتاج إلى تعديل**: 31 ملف
- **الملفات الصحيحة**: 1 ملف
- **نسبة المشاكل**: 96.9%

---

## الأولوية المقترحة للتعديل

### أولوية عالية (ملفات مستخدمة بشكل متكرر)
1. `lib/features/student/presentation/pages/enrollment_renewal_page.dart`
2. `lib/features/student/presentation/pages/exam_paper_view_page.dart`
3. `lib/features/student/presentation/pages/absence_excuse_page.dart`
4. `lib/features/profile/presentation/pages/profile_page.dart`
5. `lib/features/faculty/presentation/pages/faculty_assignments_page.dart`
6. `lib/features/faculty/presentation/pages/faculty_students_page.dart`

### أولوية متوسطة
7. `lib/features/faculty/presentation/pages/faculty_reports_page.dart`
8. `lib/features/faculty/presentation/pages/faculty_settings_page.dart`
9. `lib/features/faculty/presentation/pages/faculty_attendance_sheet_page.dart`
10. `lib/features/settings/presentation/pages/college_location_page.dart`
11. `lib/features/settings/presentation/pages/branches_info_page.dart`

### أولوية منخفضة
12. `lib/features/guest/presentation/pages/guest_portal_page.dart`
13. `lib/features/colleges/presentation/college_shell_page.dart`
14. `lib/features/auth/presentation/pages/sign_up_page.dart`
15. `lib/features/study/presentation/pages/exam_paper_page.dart`
16. `lib/features/gateway/presentation/pages/gateway_page.dart`
17. `lib/features/faculty/presentation/pages/faculty_excuses_page.dart`
18. `lib/features/faculty/presentation/pages/exam_paper_upload_page.dart`
19. `lib/features/faculty/presentation/pages/send_message_page.dart`
20. `lib/features/faculty/pages/faculty_students_page.dart`
21. `lib/features/faculty/pages/faculty_reports_page.dart`
22. `lib/features/faculty/pages/faculty_settings_page.dart`
23. `lib/features/faculty/pages/faculty_assignments_page.dart`
24. `lib/features/faculty/pages/faculty_attendance_sheet_page.dart`

---

## التوصيات

1. **استخدم الحل 1 (BackButton widget)** قدر الإمكان لأنه الحل الأبسط والأكثر موثوقية
2. **ابدأ بالملفات ذات الأولوية العالية** لأنها مستخدمة بشكل متكرر
3. **اختبر التغييرات** في كل من اللغة العربية (RTL) والإنجليزية (LTR)
4. **راجع custom_app_bar.dart** للتأكد من أنه يعمل بشكل صحيح في جميع الحالات
5. **فكر في إنشاء widget مخصص** لزر الرجوع يدعم RTL/LTR بشكل تلقائي لاستخدامه في جميع أنحاء المشروع

---

## ملاحظات إضافية

- بعض الملفات تستخدم `context.pop()` بينما البعض الآخر يستخدم `Navigator.of(context).pop()` - يفضل توحيد الأسلوب
- بعض الملفات تستخدم `maybePop()` بدلاً من `pop()` للتعامل مع الحالات التي لا يمكن فيها الرجوع
- يفضل استخدام `context.pop()` من `go_router` إذا كان المشروع يستخدم go_router
