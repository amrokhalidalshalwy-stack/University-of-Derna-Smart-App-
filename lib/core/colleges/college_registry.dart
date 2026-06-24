// ═══════════════════════════════════════════════════════════════════════════
// college_registry.dart
// Single source of truth for all 17 UOD academic colleges (faculties).
// Used by: go_router college routes, theming, guest portal, registration.
// Add a new college = one entry in [kUodColleges] only.
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// Immutable definition of one UOD college (faculty).
@immutable
class CollegeDefinition {
  const CollegeDefinition({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.primaryColor,
    required this.icon,
    this.routeSegment,
    this.departments = const [],
    this.campusAr,
  });

  /// Stable machine id (Firestore `college_id`, route key).
  final String id;

  final String nameAr;
  final String nameEn;
  final Color primaryColor;
  final IconData icon;

  /// URL segment under `/colleges/:slug`. Defaults to [id] when null.
  final String? routeSegment;

  /// Academic departments (for dropdowns / college home).
  final List<String> departments;

  /// Campus label when distributed across Derna / Al-Qubbah.
  final String? campusAr;

  String get slug => routeSegment ?? id;

  Color get backgroundColor => primaryColor.withValues(alpha: 0.1);
}

/// All 17 academic colleges — جامعة درنة (uod.edu.ly).
const List<CollegeDefinition> kUodColleges = [
  CollegeDefinition(
    id: 'medicine',
    nameAr: 'كلية الطب',
    nameEn: 'Faculty of Medicine',
    primaryColor: Color(0xFF003366),
    icon: Icons.medical_services_outlined,
    campusAr: 'درنة',
    departments: [
      'الطب العام',
      'الجراحة',
      'طب الأطفال',
      'الطب الباطني',
      'أمراض النساء والتوليد',
      'علم الأمراض',
    ],
  ),
  CollegeDefinition(
    id: 'dentistry',
    nameAr: 'كلية طب وجراحة الفم والأسنان',
    nameEn: 'Faculty of Dentistry',
    primaryColor: Color(0xFF00838F),
    icon: Icons.health_and_safety_outlined,
    campusAr: 'درنة',
    departments: ['طب الأسنان', 'جراحة الفم والفكين', 'أمراض الفم'],
  ),
  CollegeDefinition(
    id: 'pharmacy',
    nameAr: 'كلية الصيدلة',
    nameEn: 'Faculty of Pharmacy',
    primaryColor: Color(0xFF4A148C),
    icon: Icons.vaccines_outlined,
    campusAr: 'درنة',
    departments: [
      'العلوم الصيدلانية',
      'الصيدلة',
      'الكيمياء الصيدلانية',
      'الصيدلة الإكلينيكية',
    ],
  ),
  CollegeDefinition(
    id: 'nursing',
    nameAr: 'كلية التمريض',
    nameEn: 'Faculty of Nursing',
    primaryColor: Color(0xFFC2185B),
    icon: Icons.local_hospital_outlined,
    campusAr: 'درنة',
    departments: ['التمريض', 'تمريض الأطفال', 'تمريض صحة المجتمع'],
  ),
  CollegeDefinition(
    id: 'public_health',
    nameAr: 'كلية الصحة العامة',
    nameEn: 'Faculty of Public Health',
    primaryColor: Color(0xFF00695C),
    icon: Icons.coronavirus_outlined,
    campusAr: 'درنة',
    departments: ['الصحة العامة', 'علم الأوبئة', 'التغذية'],
  ),
  CollegeDefinition(
    id: 'engineering',
    nameAr: 'كلية الهندسة',
    nameEn: 'Faculty of Engineering',
    primaryColor: Color(0xFF00A694),
    icon: Icons.engineering_outlined,
    campusAr: 'درنة',
    departments: [
      'الهندسة المدنية',
      'الهندسة الكهربائية',
      'الهندسة الميكانيكية',
      'الهندسة الكيميائية',
    ],
  ),
  CollegeDefinition(
    id: 'arts_architecture',
    nameAr: 'كلية الفنون والعمارة',
    nameEn: 'Faculty of Arts and Architecture',
    primaryColor: Color(0xFF5D4037),
    icon: Icons.architecture_outlined,
    campusAr: 'درنة',
    departments: ['العمارة', 'التصميم الداخلي', 'الفنون الجميلة'],
  ),
  CollegeDefinition(
    id: 'information_technology',
    nameAr: 'كلية تكنولوجيا المعلومات',
    nameEn: 'Faculty of Information Technology',
    primaryColor: Color(0xFF1565C0),
    icon: Icons.computer_outlined,
    campusAr: 'درنة',
    departments: [
      'هندسة البرمجيات',
      'علوم الحاسوب',
      'نظم المعلومات',
      'الأمن السيبراني',
    ],
  ),
  CollegeDefinition(
    id: 'science',
    nameAr: 'كلية العلوم',
    nameEn: 'Faculty of Science',
    primaryColor: Color(0xFF1A237E),
    icon: Icons.science_outlined,
    campusAr: 'درنة',
    departments: ['الفيزياء', 'الكيمياء', 'الأحياء', 'الرياضيات', 'الجيولوجيا'],
  ),
  CollegeDefinition(
    id: 'natural_resources',
    nameAr: 'كلية الموارد الطبيعية',
    nameEn: 'Faculty of Natural Resources',
    primaryColor: Color(0xFF2E7D32),
    icon: Icons.eco_outlined,
    campusAr: 'القبة',
    departments: [
      'العلوم البيئية',
      'الجيولوجيا والهندسة الجيوتقنية',
      'الزراعة وعلم التربة',
      'إدارة الموارد الطبيعية',
    ],
  ),
  CollegeDefinition(
    id: 'veterinary',
    nameAr: 'كلية الطب البيطري',
    nameEn: 'Faculty of Veterinary Medicine',
    primaryColor: Color(0xFF558B2F),
    icon: Icons.pets_outlined,
    campusAr: 'القبة',
    departments: ['الطب البيطري', 'الإنتاج الحيواني'],
  ),
  CollegeDefinition(
    id: 'economics',
    nameAr: 'كلية الاقتصاد',
    nameEn: 'Faculty of Economics',
    primaryColor: Color(0xFF1B5E20),
    icon: Icons.trending_up_outlined,
    campusAr: 'درنة',
    departments: [
      'إدارة الأعمال',
      'المحاسبة',
      'الاقتصاد',
      'المالية',
      'التسويق',
    ],
  ),
  CollegeDefinition(
    id: 'law',
    nameAr: 'كلية القانون',
    nameEn: 'Faculty of Law',
    primaryColor: Color(0xFF8B0000),
    icon: Icons.gavel_outlined,
    campusAr: 'درنة',
    departments: [
      'القانون الدستوري والإداري',
      'القانون الجنائي',
      'القانون المدني',
      'القانون التجاري والبحري',
      'القانون الدولي',
    ],
  ),
  CollegeDefinition(
    id: 'sharia',
    nameAr: 'كلية الشريعة',
    nameEn: 'Faculty of Sharia',
    primaryColor: Color(0xFF4E342E),
    icon: Icons.menu_book_outlined,
    campusAr: 'درنة',
    departments: ['الفقه', 'أصول الفقه', 'التفسير والحديث'],
  ),
  CollegeDefinition(
    id: 'arts',
    nameAr: 'كلية الآداب',
    nameEn: 'Faculty of Arts',
    primaryColor: Color(0xFF6B4226),
    icon: Icons.auto_stories_outlined,
    campusAr: 'درنة',
    departments: [
      'اللغة العربية وآدابها',
      'اللغة الإنجليزية وآدابها',
      'التاريخ',
      'الفلسفة',
      'علم الاجتماع',
    ],
  ),
  CollegeDefinition(
    id: 'education',
    nameAr: 'كلية التربية',
    nameEn: 'Faculty of Education',
    primaryColor: Color(0xFFF57C00),
    icon: Icons.school_outlined,
    campusAr: 'القبة',
    departments: ['التربية', 'علم النفس التربوي', 'المناهج وطرق التدريس'],
  ),
  CollegeDefinition(
    id: 'media',
    nameAr: 'كلية الإعلام',
    nameEn: 'Faculty of Media',
    primaryColor: Color(0xFF6A1B9A),
    icon: Icons.campaign_outlined,
    campusAr: 'درنة',
    departments: ['الإعلام', 'العلاقات العامة', 'الإعلان'],
  ),
  CollegeDefinition(
    id: 'languages',
    nameAr: 'كلية اللغات',
    nameEn: 'Faculty of Languages',
    primaryColor: Color(0xFF0277BD),
    icon: Icons.translate_outlined,
    campusAr: 'درنة',
    departments: ['اللغة العربية', 'اللغة الإنجليزية', 'الترجمة'],
  ),
];

/// Official count shown on uod.edu.ly homepage.
const int kUodCollegeCount = 17;

/// Lookup by URL slug (`/colleges/:slug`). Returns null if unknown.
CollegeDefinition? collegeBySlug(String slug) {
  final normalized = slug.trim().toLowerCase();
  for (final college in kUodColleges) {
    if (college.slug == normalized) return college;
  }
  return null;
}

/// Lookup by stable [CollegeDefinition.id].
CollegeDefinition? collegeById(String id) {
  final normalized = id.trim().toLowerCase();
  for (final college in kUodColleges) {
    if (college.id == normalized) return college;
  }
  return null;
}

/// Lookup by Arabic display name (e.g. registration `faculty` field).
CollegeDefinition? collegeByNameAr(String nameAr) {
  final trimmed = nameAr.trim();
  for (final college in kUodColleges) {
    if (college.nameAr == trimmed) return college;
  }
  return null;
}

/// Departments for a college id; empty when id is unknown.
List<String> departmentsForCollegeId(String collegeId) {
  return collegeById(collegeId)?.departments ?? const [];
}
