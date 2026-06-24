# Faculty Screens Legacy Archive

نسخة قديمة من شاشات هيئة التدريس، استُبدلت بـ `lib/features/faculty/presentation/pages/`.

## الملفات المحفوظة:
- faculty_grades_entry_screen.dart
- faculty_home_screen.dart
- faculty_schedule_screen.dart
- faculty_students_screen.dart
- ملفات .bak المقابلة

## ملاحظات مهمة:
هذه الملفات تحتاج تحديث لأنظمة Theme وgo_router الحالية إن أُريد استخدامها مستقبلاً:
- تستخدم `AppTheme.primary` بدلاً من `Theme.of(context).colorScheme.primary`
- تستخدم `Navigator.pushNamedAndRemoveUntil` بدلاً من `go_router`
- قد تحتاج تحديث حقول Firestore

## تاريخ الأرشفة:
20 يونيو 2026
