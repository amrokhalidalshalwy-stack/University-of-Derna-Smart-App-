// ═══════════════════════════════════════════════════════════════════════════
// registration_provider.dart (المحدث والآمن بالكامل لبوابة هيئة التدريس والطلاب)
// Riverpod StateNotifier managing the 4-step registration form state.
// Supports both 'student' and 'faculty' portal types.
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/constants/university_data.dart';
import 'package:flutter_project/features/auth/data/registration_service.dart';
import 'package:flutter_project/shared/validators/name_validators.dart';

// ─── State ────────────────────────────────────────────────────────────────────
class RegistrationFormState {
  final int currentStep; // 0–3

  // Step 1 — Personal (shared)
  final String fullNameAr;
  final String fullNameEn;
  final String email;
  final String phone;
  final DateTime? dateOfBirth;
  final String nationalId;
  final String gender;

  // Step 2 — Student Academic
  final String faculty;
  final String department;
  final String semester;
  final int graduationYear;
  final double secondaryGpa;
  final String certificateType;

  // Step 2 — Faculty Academic
  final String academicDegree; // PhD / Master's / Bachelor's
  final String academicTitle; // Professor / Associate Professor / ...
  final String specialization;
  final String college; // College / Department (faculty)
  final DateTime? employmentDate;
  final double studentPassRate;

  // Step 3 — Credentials
  final String password;

  // Step 4 — Agreements
  final bool agreedToTerms;
  final bool agreedToPrivacy;

  // Operation result
  final bool isLoading;
  final String? errorMessage;
  final RegistrationResult? result;

  final String portalType; // 'student' | 'faculty' | 'admin'

  const RegistrationFormState({
    this.currentStep = 0,
    this.fullNameAr = '',
    this.fullNameEn = '',
    this.email = '',
    this.phone = '',
    this.dateOfBirth,
    this.nationalId = '',
    this.gender = '',
    // Student
    this.faculty = '',
    this.department = '',
    this.semester = '',
    this.graduationYear = 2026,
    this.secondaryGpa = 0.0,
    this.certificateType = '',
    // Faculty
    this.academicDegree = '',
    this.academicTitle = '',
    this.specialization = '',
    this.college = '',
    this.employmentDate,
    this.studentPassRate = 0.0,
    // Credentials
    this.password = '',
    this.agreedToTerms = false,
    this.agreedToPrivacy = false,
    this.isLoading = false,
    this.errorMessage,
    this.result,
    this.portalType = 'student',
  });

  bool get isFaculty => portalType == 'faculty';

  RegistrationFormState copyWith({
    int? currentStep,
    String? fullNameAr,
    String? fullNameEn,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? nationalId,
    String? gender,
    String? faculty,
    String? department,
    String? semester,
    int? graduationYear,
    double? secondaryGpa,
    String? certificateType,
    String? academicDegree,
    String? academicTitle,
    String? specialization,
    String? college,
    DateTime? employmentDate,
    double? studentPassRate,
    String? password,
    bool? agreedToTerms,
    bool? agreedToPrivacy,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    RegistrationResult? result,
    String? portalType,
  }) {
    return RegistrationFormState(
      currentStep: currentStep ?? this.currentStep,
      fullNameAr: fullNameAr ?? this.fullNameAr,
      fullNameEn: fullNameEn ?? this.fullNameEn,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationalId: nationalId ?? this.nationalId,
      gender: gender ?? this.gender,
      faculty: faculty ?? this.faculty,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      graduationYear: graduationYear ?? this.graduationYear,
      secondaryGpa: secondaryGpa ?? this.secondaryGpa,
      certificateType: certificateType ?? this.certificateType,
      academicDegree: academicDegree ?? this.academicDegree,
      academicTitle: academicTitle ?? this.academicTitle,
      specialization: specialization ?? this.specialization,
      college: college ?? this.college,
      employmentDate: employmentDate ?? this.employmentDate,
      studentPassRate: studentPassRate ?? this.studentPassRate,
      password: password ?? this.password,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      agreedToPrivacy: agreedToPrivacy ?? this.agreedToPrivacy,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: result ?? this.result,
      portalType: portalType ?? this.portalType,
    );
  }

  bool get isSubmitEnabled => agreedToTerms && agreedToPrivacy && !isLoading;
  bool get isSuccess => result != null;
}

// ─── Notifier ─────────────────────────────────────────────────────────────────
class RegistrationNotifier extends Notifier<RegistrationFormState> {
  @override
  RegistrationFormState build() => const RegistrationFormState();

  // ── Step navigation ───────────────────────────────────────────────────────
  void goToStep(int step) {
    state = state.copyWith(currentStep: step, clearError: true);
  }

  void nextStep() {
    if (state.currentStep < 3) {
      state = state.copyWith(
        currentStep: state.currentStep + 1,
        clearError: true,
      );
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        clearError: true,
      );
    }
  }

  // ── Step 1 updates (shared) ───────────────────────────────────────────────
  void updateFullNameAr(String v) => state = state.copyWith(fullNameAr: v);
  void updateFullNameEn(String v) => state = state.copyWith(fullNameEn: v);
  void updateEmail(String v) => state = state.copyWith(email: v);
  void updatePhone(String v) => state = state.copyWith(phone: v);
  void updateDateOfBirth(DateTime v) => state = state.copyWith(dateOfBirth: v);
  void updateNationalId(String v) => state = state.copyWith(nationalId: v);
  void updateGender(String v) => state = state.copyWith(gender: v);

  void setPortalType(String v) => state = state.copyWith(portalType: v);

  // ── Step 2 updates (student) ──────────────────────────────────────────────
  void updateFaculty(String v) =>
      state = state.copyWith(faculty: v, department: '');
  void updateDepartment(String v) => state = state.copyWith(department: v);
  void updateSemester(String v) => state = state.copyWith(semester: v);
  void updateGraduationYear(int v) => state = state.copyWith(graduationYear: v);
  void updateSecondaryGpa(double v) => state = state.copyWith(secondaryGpa: v);
  void updateCertificateType(String v) =>
      state = state.copyWith(certificateType: v);

  // ── Step 2 updates (faculty) ──────────────────────────────────────────────
  void updateAcademicDegree(String v) =>
      state = state.copyWith(academicDegree: v);
  void updateAcademicTitle(String v) =>
      state = state.copyWith(academicTitle: v);
  void updateSpecialization(String v) =>
      state = state.copyWith(specialization: v);
  void updateCollege(String v) =>
      state = state.copyWith(college: v, specialization: '');
  void updateEmploymentDate(DateTime v) =>
      state = state.copyWith(employmentDate: v);
  void updateStudentPassRate(double v) =>
      state = state.copyWith(studentPassRate: v);

  // ── Step 3 updates ────────────────────────────────────────────────────────
  void updatePassword(String v) => state = state.copyWith(password: v);

  // ── Step 4 updates ────────────────────────────────────────────────────────
  void toggleTerms() =>
      state = state.copyWith(agreedToTerms: !state.agreedToTerms);
  void togglePrivacy() =>
      state = state.copyWith(agreedToPrivacy: !state.agreedToPrivacy);

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> submit() async {
    // 1. شروط التحقق المبدئية للأسماء والجنس
    if (!arabicNamePattern.hasMatch(state.fullNameAr.trim())) {
      state = state.copyWith(errorMessage: 'يجب أن يحتوي الاسم العربي على أحرف عربية فقط.');
      return;
    }
    if (!englishNamePattern.hasMatch(state.fullNameEn.trim())) {
      state = state.copyWith(errorMessage: 'يجب أن يحتوي الاسم الإنجليزي على أحرف إنجليزية فقط.');
      return;
    }
    if (state.gender != 'male' && state.gender != 'female') {
      state = state.copyWith(errorMessage: 'يرجى اختيار الجنس.');
      return;
    }
    if (state.dateOfBirth == null) {
      state = state.copyWith(errorMessage: 'يرجى تحديد تاريخ الميلاد.');
      return;
    }

    // 2. 🔒 شروط التحقق الصارمة الخاصة بهيئة التدريس (Faculty) قبل الإرسال
    if (state.isFaculty) {
      if (state.academicDegree.isEmpty) {
        state = state.copyWith(errorMessage: 'الدرجة الأكاديمية مطلوبة.');
        return;
      }
      if (state.academicTitle.isEmpty) {
        state = state.copyWith(errorMessage: 'المسمى الوظيفي مطلوب.');
        return;
      }
      if (state.college.isEmpty) {
        state = state.copyWith(errorMessage: 'الكلية مطلوبة.');
        return;
      }
      if (state.specialization.isEmpty) {
        state = state.copyWith(errorMessage: 'التخصص الأكاديمي مطلوب.');
        return;
      }
      if (!UniversityData.isValidSpecializationForCollege(state.college, state.specialization)) {
        state = state.copyWith(errorMessage: 'التخصص المختار لا يتبع الكلية المحددة.');
        return;
      }
    } else {
      // 🔒 شروط التحقق الخاصة بالطلاب (Student)
      if (state.faculty.isEmpty || state.department.isEmpty) {
        state = state.copyWith(errorMessage: 'يرجى اختيار الكلية والقسم.');
        return;
      }
      if (!UniversityData.isValidSpecializationForCollege(state.faculty, state.department)) {
        state = state.copyWith(errorMessage: 'القسم المختار لا يتبع الكلية المحددة.');
        return;
      }
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // إصلاح تعبئة الحقول لمنع إرسال قيم فارغة أو متعارضة تسبب رفض السيرفر (permission-denied)
      final input = RegistrationInput(
        fullNameAr: state.fullNameAr.trim(),
        fullNameEn: state.fullNameEn.trim(),
        email: state.email.trim(),
        phone: state.phone.trim(),
        dateOfBirth: state.dateOfBirth!,
        nationalId: state.nationalId.trim(),
        gender: state.gender,
        
        // التوزيع الآمن للحقول الأكاديمية بين الطالب والدكتور
        faculty: state.isFaculty ? state.college : state.faculty,
        department: state.isFaculty ? state.specialization : state.department,
        semester: state.isFaculty ? '' : state.semester,
        graduationYear: state.isFaculty ? 0 : state.graduationYear,
        secondaryGpa: state.isFaculty ? 0.0 : state.secondaryGpa,
        certificateType: state.isFaculty ? '' : state.certificateType,
        
        // الحقول الخاصة بأعضاء هيئة التدريس
        academicDegree: state.isFaculty ? state.academicDegree : '',
        academicTitle: state.isFaculty ? state.academicTitle : '',
        specialization: state.isFaculty ? state.specialization : '',
        college: state.isFaculty ? state.college : '',
        employmentDate: state.isFaculty ? state.employmentDate : null,
        studentPassRate: state.isFaculty ? state.studentPassRate : 0.0,
        
        password: state.password,
        role: state.portalType,
        agreedToTerms: state.agreedToTerms,
        agreedToPrivacy: state.agreedToPrivacy,
      );

      final service = ref.read(registrationServiceProvider);
      final result = await service.register(input);
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Resets the entire form to initial state (e.g., after success)
  void reset() => state = const RegistrationFormState();
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final registrationProvider =
    NotifierProvider<RegistrationNotifier, RegistrationFormState>(
      RegistrationNotifier.new,
    );
  