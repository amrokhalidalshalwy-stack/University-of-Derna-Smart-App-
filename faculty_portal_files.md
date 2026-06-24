# الملفات المسؤولة عن بوابة هيئة التدريس

## 1. بوابة تسجيل الدخول

### `lib\features\auth\presentation\pages\login_page.dart`
- **الوصف**: صفحة تسجيل الدخول الرئيسية
- **الوظيفة**: 
  - استقبال بيانات البريد الإلكتروني وكلمة المرور
  - التحقق من صحة البيانات
  - تسجيل الدخول عبر Firebase Auth
  - التحقق من دور المستخدم من Firestore
  - التوجيه حسب الدور:
    - `student` → `/home`
    - `faculty` → `/faculty/dashboard`
    - `admin` → `/admin/dashboard`

---

## 2. نظام التوجيه (Routing)

### `lib\core\router\app_router.dart`
- **الوصف**: الروتر الرئيسي للتطبيق
- **الوظيفة**:
  - تعريف جميع مسارات التطبيق
  - إدارة التوجيه بين الصفحات
  - التحقق من صلاحيات الوصول
  - إدارة حالة المصادقة
  - توجيه المستخدمين حسب أدوارهم

### `lib\core\router\faculty_routes.dart`
- **الوصف**: مسارات هيئة التدريس المخصصة
- **المسارات المعرفة**:
  - `/faculty/dashboard` - لوحة التحكم الرئيسية
  - `/faculty/profile` - الملف الشخصي
  - `/faculty/schedule` - الجدول الدراسي
  - `/faculty/exam-paper-upload` - رفع أوراق الامتحانات
  - `/faculty/settings` - الإعدادات
  - `/faculty/attendance-sheet` - ورقة الحضور
  - `/faculty/attendance` - إدخال الحضور
  - `/faculty/students` - صفحة الطلاب
  - `/faculty/reports` - التقارير
  - `/faculty/assignments` - الواجبات
  - `/faculty/grades-entry` - إدخال الدرجات
  - `/faculty/class/:courseId` - تفاصيل المادة
  - `/faculty/exam-papers` - أوراق الامتحانات
  - `/faculty/excuses` - الأعذار

### `lib\core\router\auth_navigation.dart`
- **الوصف**: دوال مساعدة للتنقل بعد تسجيل الدخول
- **الوظيفة**:
  - `homePathForRole(UserRole role)` - تحديد المسار الافتراضي لكل دور
  - `navigateAfterLogin()` - التنقل بعد تسجيل الدخول مع التحقق من الحالة

---

## 3. لوحة التحكم الرئيسية

### `lib\features\faculty\pages\faculty_dashboard_page.dart`
- **الوصف**: الملف الفعلي للوحة التحكم الرئيسية لهيئة التدريس
- **الحجم**: 68KB
- **الوظيفة**:
  - عرض الإحصائيات الرئيسية
  - عرض المواد الدراسية
  - التنقل بين التبويبات (الرئيسية، المواد، الحضور، الدرجات)
  - عرض الإشعارات
  - القائمة الجانبية (Drawer) للتنقل السريع

### `lib\features\faculty\presentation\pages\faculty_dashboard_page.dart`
- **الوصف**: ملف تصدير (export) للملف الفعلي
- **المحتوى**: `export '../../pages/faculty_dashboard_page.dart';`

---

## 4. الصفحات الداخلية لهيئة التدريس

### `lib\features\faculty\pages\faculty_schedule_page.dart`
- **الوصف**: صفحة الجدول الدراسي
- **الوظيفة**: عرض جدول المحاضرات والدروس للأستاذ

### `lib\features\faculty\pages\faculty_students_page.dart`
- **الوصف**: صفحة الطلاب
- **الحجم**: 37KB
- **الوظيفة**: عرض قائمة الطلاب المسجلين في المواد

### `lib\features\faculty\pages\faculty_attendance_sheet_page.dart`
- **الوصف**: صفحة ورقة الحضور
- **الحجم**: 25KB
- **الوظيفة**: تسجيل حضور وغياب الطلاب

### `lib\features\faculty\pages\faculty_assignments_page.dart`
- **الوصف**: صفحة الواجبات
- **الحجم**: 25KB
- **الوظيفة**: إدارة الواجبات والمشاريع

### `lib\features\faculty\pages\faculty_profile_page.dart`
- **الوصف**: صفحة الملف الشخصي
- **الحجم**: 22KB
- **الوظيفة**: عرض وتعديل معلومات الأستاذ

### `lib\features\faculty\pages\faculty_settings_page.dart`
- **الوصف**: صفحة الإعدادات
- **الحجم**: 22KB
- **الوظيفة**: إعدادات الحساب والتطبيق

### `lib\features\faculty\pages\faculty_reports_page.dart`
- **الوصف**: صفحة التقارير
- **الحجم**: 16KB
- **الوظيفة**: عرض التقارير والإحصائيات

### `lib\features\faculty\pages\faculty_excuses_page.dart`
- **الوصف**: صفحة الأعذار
- **الوظيفة**: مراجعة وقبول/رفض أعذار الطلاب

### `lib\features\faculty\pages\class_detail_page.dart`
- **الوصف**: صفحة تفاصيل المادة
- **الحجم**: 34KB
- **الوظيفة**: عرض تفاصيل مادة دراسية معينة

---

## 5. الملفات المساعدة

### `lib\features\faculty\providers\faculty_provider.dart`
- **الوصف**: Provider لهيئة التدريس
- **الوظيفة**: إدارة حالة البيانات لهيئة التدريس باستخدام Riverpod

### `lib\features\faculty\models\course_model.dart`
- **الوصف**: نموذج المادة الدراسية
- **الوظيفة**: تعريف هيكل بيانات المادة الدراسية

---

## 6. ملفات إضافية

### `lib\features\faculty\presentation\widgets\faculty_drawer.dart`
- **الوصف**: ويدجت القائمة الجانبية لهيئة التدريس
- **الوظيفة**: عرض القائمة الجانبية للتنقل السريع

### `lib\features\faculty\presentation\widgets\dashboard_home_tab.dart`
- **الوصف**: تبويب الرئيسية في لوحة التحكم

### `lib\features\faculty\presentation\widgets\dashboard_classes_tab.dart`
- **الوصف**: تبويب المواد في لوحة التحكم

### `lib\features\faculty\presentation\widgets\dashboard_attendance_tab.dart`
- **الوصف**: تبويب الحضور في لوحة التحكم

### `lib\features\faculty\presentation\widgets\dashboard_grades_tab.dart`
- **الوصف**: تبويب الدرجات في لوحة التحكم

---

## ملاحظات مهمة

1. **هيكل الملفات**: يوجد نسختان من كل صفحة:
   - واحدة في `pages/` (الملف الفعلي)
   - وأخرى في `presentation/pages/` (ملف تصدير)

2. **التوجيه**: يتم التوجيه من صفحة تسجيل الدخول إلى `/faculty/dashboard` عند نجاح تسجيل الدخول للدور 'faculty'

3. **الحماية**: جميع مسارات هيئة التدريس محمية بـ redirect checks للتأكد من أن المستخدم لديه دور 'faculty'

4. **التنقل**: يتم استخدام GoRouter لإدارة التوجيه في التطبيق

---

## تدفق العمل

1. المستخدم يفتح `/login?role=faculty`
2. يدخل البريد الإلكتروني وكلمة المرور
3. يتم التحقق من Firebase Auth
4. يتم جلب بيانات المستخدم من Firestore
5. يتم التحقق من أن الدور هو 'faculty'
6. يتم التوجيه إلى `/faculty/dashboard`
7. يفتح `FacultyDashboardPage` مع عرض التبويب الرئيسي
8. يمكن للمستخدم التنقل بين الصفحات المختلفة عبر القائمة الجانبية أو التبويبات
