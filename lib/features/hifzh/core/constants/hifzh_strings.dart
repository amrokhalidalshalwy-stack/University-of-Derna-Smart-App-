/// All user-facing strings for the HifdhTracker feature.
///
/// No hardcoded strings should appear in widget files — always reference
/// this class. Supports Arabic (primary) and English (secondary).
library;

/// Application-wide string constants for HifdhTracker.
abstract final class HifzhStrings {
  // ── App Identity ────────────────────────────────────────────────────────
  /// Application name.
  static const String appName = 'حافظ | HifdhTracker';

  /// Application tagline.
  static const String tagline = 'مرافقك الشخصي في حفظ القرآن الكريم';

  // ── Auth Screen ─────────────────────────────────────────────────────────
  static const String loginTitle = 'تسجيل الدخول';
  static const String registerTitle = 'إنشاء حساب جديد';
  static const String emailLabel = 'البريد الإلكتروني';
  static const String emailHint = 'example@email.com';
  static const String passwordLabel = 'كلمة المرور';
  static const String passwordHint = '••••••••';
  static const String confirmPasswordLabel = 'تأكيد كلمة المرور';
  static const String forgotPassword = 'نسيت كلمة المرور؟';
  static const String loginButton = 'دخول';
  static const String registerButton = 'إنشاء الحساب';
  static const String noAccount = 'ليس لديك حساب؟ ';
  static const String hasAccount = 'لديك حساب بالفعل؟ ';
  static const String signUpLink = 'سجّل الآن';
  static const String signInLink = 'سجّل الدخول';
  static const String continueWithGoogle = 'المتابعة بحساب Google';
  static const String orDivider = 'أو';

  // ── Validation Messages ──────────────────────────────────────────────────
  static const String emailRequired = 'البريد الإلكتروني مطلوب';
  static const String emailInvalid = 'تنسيق البريد الإلكتروني غير صحيح';
  static const String passwordRequired = 'كلمة المرور مطلوبة';
  static const String passwordTooShort =
      'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
  static const String passwordsDoNotMatch = 'كلمتا المرور غير متطابقتين';
  static const String fieldRequired = 'هذا الحقل مطلوب';

  // ── Today Tab ────────────────────────────────────────────────────────────
  static const String todayTab = 'اليوم';
  static const String mushafTab = 'المصحف';
  static const String halaqahTab = 'حلقتي';
  static const String profileTab = 'الملف';

  static const String todayGreeting = 'أهلاً بك، حافظ!';
  static const String todaySubtitle = 'هل أنت مستعد لمراجعة حفظك اليوم؟';
  static const String dueTodayTitle = 'مقرر مراجعته اليوم';
  static const String startReview = 'ابدأ المراجعة';
  static const String noReviewsDue =
      'ما شاء الله! لا توجد مراجعات مستحقة اليوم.';
  static const String streakLabel = 'أيام متتالية';
  static const String pagesMemorized = 'صفحات محفوظة';
  static const String weeklyGoal = 'هدف الأسبوع';
  static const String weeklyProgress = 'التقدم الأسبوعي';
  static const String recentActivity = 'النشاط الأخير';

  // ── Mushaf Tab ───────────────────────────────────────────────────────────
  static const String allSurahs = 'جميع السور';
  static const String searchSurah = 'ابحث عن سورة...';
  static const String meccan = 'مكية';
  static const String medinan = 'مدنية';
  static const String ayahs = 'آية';
  static const String page = 'صفحة';
  static const String juz = 'جزء';

  // ── Memorization Status Labels ───────────────────────────────────────────
  static const String statusNotStarted = 'لم تبدأ';
  static const String statusInProgress = 'قيد الحفظ';
  static const String statusMemorized = 'محفوظ';
  static const String statusMastered = 'مُتقَن';

  // ── Halaqah Tab ──────────────────────────────────────────────────────────
  static const String myHalaqah = 'حلقتي';
  static const String createHalaqah = 'إنشاء حلقة جديدة';
  static const String joinHalaqah = 'الانضمام لحلقة';
  static const String enterInviteCode = 'أدخل رمز الدعوة';
  static const String leaderboard = 'لوحة المتصدرين';
  static const String memberCount = 'عدد الأعضاء';
  static const String pagesThisWeek = 'صفحات هذا الأسبوع';
  static const String currentStreak = 'الأيام المتتالية';

  // ── Profile Tab ──────────────────────────────────────────────────────────
  static const String myProfile = 'ملفي الشخصي';
  static const String settings = 'الإعدادات';
  static const String achievements = 'الإنجازات';
  static const String editProfile = 'تعديل الملف';
  static const String signOut = 'تسجيل الخروج';
  static const String signOutConfirm = 'هل أنت متأكد أنك تريد تسجيل الخروج؟';
  static const String cancel = 'إلغاء';
  static const String confirm = 'تأكيد';

  // ── Errors & Connectivity ────────────────────────────────────────────────
  static const String offlineBanner =
      'لا يوجد اتصال بالإنترنت — وضع عدم الاتصال';
  static const String retryButton = 'إعادة المحاولة';
  static const String genericError =
      'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
  static const String loadingLabel = 'جاري التحميل...';
  static const String noDataAvailable = 'لا توجد بيانات متاحة';

  // ── Onboarding ──────────────────────────────────────────────────────────
  static const String onboarding1Title = 'خطط حفظك بذكاء';
  static const String onboarding1Body =
      'نظام المراجعة المتباعدة يضمن أن تحتفظ بما حفظته إلى الأبد.';
  static const String onboarding2Title = 'تتبع تقدمك لحظة بلحظة';
  static const String onboarding2Body =
      'خريطة حرارية للمصحف كاملاً تُظهر كل صفحة حفظتها وكل ما تحتاج مراجعته.';
  static const String onboarding3Title = 'تواصل مع حلقتك';
  static const String onboarding3Body =
      'شارك تقدمك مع أستاذك وأصدقائك واستمر في التحفيز اليومي.';
  static const String getStarted = 'ابدأ الآن';
  static const String skip = 'تخطي';
}
