// ═══════════════════════════════════════════════════════════════════════════
// university_data.dart
// Complete static data for all 8 Derna University faculties and departments.
// Used by: Registration dropdowns, Guest portal explorer, Admin reports.
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// ─── Faculty Model ────────────────────────────────────────────────────────────
class FacultyData {
  final String nameAr;
  final String nameEn;
  final String emoji;
  final Color color;
  final List<String> departments;

  const FacultyData({
    required this.nameAr,
    required this.nameEn,
    required this.emoji,
    required this.color,
    required this.departments,
  });

  Color get bgColor => color.withValues(alpha: 0.1);
}

// ─── University Structure ─────────────────────────────────────────────────────
class UniversityData {
  UniversityData._();

  static const List<FacultyData> faculties = [
    FacultyData(
      nameAr: 'كلية الطب',
      nameEn: 'Faculty of Medicine',
      emoji: '🏥',
      color: Color(0xFF003366),
      departments: [
        'الطب العام',
        'الجراحة',
        'طب الأطفال',
        'الطب الباطني',
        'أمراض النساء والتوليد',
        'علم الأمراض',
        'الصيدلة',
      ],
    ),
    FacultyData(
      nameAr: 'كلية الهندسة',
      nameEn: 'Faculty of Engineering',
      emoji: '⚙️',
      color: Color(0xFF00A694),
      departments: [
        'الهندسة المدنية',
        'الهندسة الكهربائية',
        'الهندسة الميكانيكية',
        'الهندسة الكيميائية',
        'العمارة',
      ],
    ),
    FacultyData(
      nameAr: 'كلية القانون',
      nameEn: 'Faculty of Law',
      emoji: '⚖️',
      color: Color(0xFF8B0000),
      departments: [
        'القانون الدستوري والإداري',
        'القانون الجنائي',
        'القانون المدني',
        'القانون التجاري والبحري',
        'القانون الدولي',
      ],
    ),
    FacultyData(
      nameAr: 'كلية الآداب',
      nameEn: 'Faculty of Arts',
      emoji: '📚',
      color: Color(0xFF6B4226),
      departments: [
        'اللغة العربية وآدابها',
        'اللغة الإنجليزية وآدابها',
        'التاريخ',
        'الفلسفة',
        'علم الاجتماع',
      ],
    ),
    FacultyData(
      nameAr: 'كلية الاقتصاد',
      nameEn: 'Faculty of Economics',
      emoji: '📈',
      color: Color(0xFF1B5E20),
      departments: [
        'إدارة الأعمال',
        'المحاسبة',
        'الاقتصاد',
        'المالية',
        'التسويق',
      ],
    ),
    FacultyData(
      nameAr: 'كلية العلوم',
      nameEn: 'Faculty of Science',
      emoji: '🔬',
      color: Color(0xFF1A237E),
      departments: [
        'الفيزياء',
        'الكيمياء',
        'الأحياء',
        'الرياضيات',
        'الجيولوجيا',
      ],
    ),
    FacultyData(
      nameAr: 'كلية الصيدلة',
      nameEn: 'Faculty of Pharmacy',
      emoji: '💊',
      color: Color(0xFF4A148C),
      departments: [
        'العلوم الصيدلانية',
        'الصيدلة',
        'الكيمياء الصيدلانية',
        'الصيدلة الإكلينيكية',
      ],
    ),
    FacultyData(
      nameAr: 'كلية الموارد الطبيعية',
      nameEn: 'Faculty of Natural Resources',
      emoji: '🌿',
      color: Color(0xFF2E7D32),
      departments: [
        'العلوم البيئية',
        'الجيولوجيا والهندسة الجيوتقنية',
        'الزراعة وعلم التربة',
        'إدارة الموارد الطبيعية',
      ],
    ),
  ];

  /// Returns departments list for a given faculty Arabic name.
  static List<String> departmentsFor(String facultyNameAr) {
    final faculty = faculties.firstWhere(
      (f) => f.nameAr == facultyNameAr,
      orElse: () => faculties.first,
    );
    return faculty.departments;
  }

  /// Returns FacultyData for a given Arabic faculty name.
  static FacultyData? facultyByName(String nameAr) {
    try {
      return faculties.firstWhere((f) => f.nameAr == nameAr);
    } catch (_) {
      return null;
    }
  }

  static const List<String> semesters = [
    'الفصل الأول',
    'الفصل الثاني',
    'الفصل الصيفي',
  ];

  static const List<String> certificateTypes = [
    'شهادة ثانوية ليبية',
    'البكالوريا الدولية (IB)',
    'شهادات عربية أخرى',
  ];

  /// Stored in Firestore as `male` / `female`.
  static const List<String> genderValues = ['male', 'female'];

  static String genderLabel(String value, {required bool isArabic}) {
    switch (value) {
      case 'male':
        return isArabic ? 'ذكر' : 'Male';
      case 'female':
        return isArabic ? 'أنثى' : 'Female';
      default:
        return ''; // Always return empty string, never the raw value to prevent null issues
    }
  }

  /// Faculty-specific specializations keyed by college Arabic name.
  static const Map<String, List<String>> collegeSpecializations = {
    'كلية القانون': [
      'القانون العام',
      'القانون الخاص',
      'القانون الجنائي',
      'القانون الدولي',
    ],
    'كلية الطب': [
      'الطب البشري',
      'طب الأسنان',
      'الصيدلة',
      'التمريض',
    ],
    'كلية الهندسة': [
      'الهندسة المدنية',
      'الهندسة الكهربائية',
      'الهندسة الميكانيكية',
      'هندسة الحاسوب',
    ],
    'كلية العلوم': [
      'الرياضيات',
      'الفيزياء',
      'الكيمياء',
      'الأحياء',
    ],
    'كلية الآداب': [
      'اللغة العربية وآدابها',
      'اللغة الإنجليزية وآدابها',
      'التاريخ',
      'الفلسفة',
    ],
    'كلية الاقتصاد': [
      'إدارة الأعمال',
      'المحاسبة',
      'الاقتصاد',
      'التسويق',
    ],
    'كلية الصيدلة': [
      'العلوم الصيدلانية',
      'الصيدلة',
      'الكيمياء الصيدلانية',
      'الصيدلة الإكلينيكية',
    ],
    'كلية الموارد الطبيعية': [
      'العلوم البيئية',
      'الجيولوجيا',
      'الزراعة',
      'إدارة الموارد الطبيعية',
    ],
  };

  /// Departments for students; specializations for faculty (strict per college).
  static List<String> specializationsFor(String collegeNameAr) {
    return collegeSpecializations[collegeNameAr] ??
        departmentsFor(collegeNameAr);
  }

  static bool isValidSpecializationForCollege(
    String collegeNameAr,
    String specialization,
  ) {
    if (collegeNameAr.isEmpty || specialization.isEmpty) return false;
    return specializationsFor(collegeNameAr).contains(specialization);
  }

  /// High-demand faculties for scoring algorithm.
  static const List<String> highDemandFaculties = ['كلية الطب', 'كلية الهندسة'];
  static const List<String> mediumDemandFaculties = [
    'كلية القانون',
    'كلية الاقتصاد',
  ];
}
