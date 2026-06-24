import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_project/features/student/data/academic_year_service.dart';

/// Provider for academic year settings from Firestore.
/// This allows the administration to update fees, deadlines, and other
/// academic year settings without requiring an app update.
final academicYearSettingsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return AcademicYearService.getAcademicYearSettings();
});

/// Stream provider for real-time updates to academic year settings.
final academicYearSettingsStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return AcademicYearService.watchAcademicYearSettings();
});

/// Individual value providers for convenience
final academicYearProvider = Provider<String>((ref) {
  final settings = ref.watch(academicYearSettingsProvider);
  return settings.when(
    data: (data) => data['academicYear'] as String? ?? '2026/2027',
    loading: () => '2026/2027',
    error: (_, _) => '2026/2027',
  );
});

final feesAmountProvider = Provider<String>((ref) {
  final settings = ref.watch(academicYearSettingsProvider);
  return settings.when(
    data: (data) => data['feesAmount'] as String? ?? '150 LYD',
    loading: () => '150 LYD',
    error: (_, _) => '150 LYD',
  );
});

final deadlineProvider = Provider<String>((ref) {
  final settings = ref.watch(academicYearSettingsProvider);
  return settings.when(
    data: (data) => data['deadline'] as String? ?? '15 سبتمبر 2026',
    loading: () => '15 سبتمبر 2026',
    error: (_, _) => '15 سبتمبر 2026',
  );
});

final isEnrollmentOpenProvider = Provider<bool>((ref) {
  final settings = ref.watch(academicYearSettingsProvider);
  return settings.when(
    data: (data) => data['isOpen'] as bool? ?? true,
    loading: () => true,
    error: (_, _) => true,
  );
});
