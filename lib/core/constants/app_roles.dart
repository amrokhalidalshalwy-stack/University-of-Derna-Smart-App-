// ═══════════════════════════════════════════════════════════════════════════
// app_roles.dart
// Enums for user roles and registration/account statuses.
// ═══════════════════════════════════════════════════════════════════════════

/// The role assigned to a user account in Firestore.
enum UserRole {
  student,
  faculty,
  admin,
  guest;

  /// Parses a Firestore string value to [UserRole].
  static UserRole fromString(String? value) {
    switch (value) {
      case 'faculty':
        return UserRole.faculty;
      case 'admin':
        return UserRole.admin;
      case 'guest':
        return UserRole.guest;
      default:
        return UserRole.student;
    }
  }

  String get value {
    switch (this) {
      case UserRole.student:
        return 'student';
      case UserRole.faculty:
        return 'faculty';
      case UserRole.admin:
        return 'admin';
      case UserRole.guest:
        return 'guest';
    }
  }
}

/// Registration / account approval status.
enum RegistrationStatus {
  /// Account created, preliminary score ≥ 75 — awaiting admin final decision.
  pendingFinalApproval,

  /// Preliminary score 50–74 — under admin review.
  underReview,

  /// Preliminary score < 50 — requires additional admin review.
  requiresAdditional,

  /// Age < 17 OR GPA < 40 for competitive faculty — auto-rejected without admin review.
  autoRejected,

  /// Admin manually approved the account. Student can log in.
  approved,

  /// Admin manually rejected the account.
  rejected,

  /// Account was suspended post-approval.
  suspended;

  static RegistrationStatus fromString(String? value) {
    switch (value) {
      case 'pending_final_approval':
        return RegistrationStatus.pendingFinalApproval;
      case 'under_review':
        return RegistrationStatus.underReview;
      case 'requires_additional':
        return RegistrationStatus.requiresAdditional;
      case 'auto_rejected':
        return RegistrationStatus.autoRejected;
      case 'approved':
        return RegistrationStatus.approved;
      case 'rejected':
        return RegistrationStatus.rejected;
      case 'suspended':
        return RegistrationStatus.suspended;
      default:
        return RegistrationStatus.pendingFinalApproval;
    }
  }

  String get value {
    switch (this) {
      case RegistrationStatus.pendingFinalApproval:
        return 'pending_final_approval';
      case RegistrationStatus.underReview:
        return 'under_review';
      case RegistrationStatus.requiresAdditional:
        return 'requires_additional';
      case RegistrationStatus.autoRejected:
        return 'auto_rejected';
      case RegistrationStatus.approved:
        return 'approved';
      case RegistrationStatus.rejected:
        return 'rejected';
      case RegistrationStatus.suspended:
        return 'suspended';
    }
  }

  /// Returns Arabic label shown to user or admin.
  String get labelAr {
    switch (this) {
      case RegistrationStatus.pendingFinalApproval:
        return 'قيد الموافقة النهائية';
      case RegistrationStatus.underReview:
        return 'قيد المراجعة';
      case RegistrationStatus.requiresAdditional:
        return 'يتطلب مراجعة إضافية';
      case RegistrationStatus.autoRejected:
        return 'مرفوض تلقائياً';
      case RegistrationStatus.approved:
        return 'مقبول';
      case RegistrationStatus.rejected:
        return 'مرفوض';
      case RegistrationStatus.suspended:
        return 'موقوف';
    }
  }

  /// Whether the student is blocked from accessing the portal.
  bool get isBlocked =>
      this == RegistrationStatus.autoRejected ||
      this == RegistrationStatus.rejected ||
      this == RegistrationStatus.suspended;

  /// Whether the account is pending any kind of admin action.
  bool get isPending =>
      this == RegistrationStatus.pendingFinalApproval ||
      this == RegistrationStatus.underReview ||
      this == RegistrationStatus.requiresAdditional;
}

/// Admin rejection reasons shown in the rejection dialog.
class RejectionReasons {
  RejectionReasons._();

  static const List<String> options = [
    'بيانات أكاديمية غير كافية',
    'مشاكل في الوثائق',
    'حساب مكرر',
    'معلومات غير مكتملة',
    'امتلاء السعة في التخصص',
    'عدم استيفاء متطلبات العمر',
    'أخرى',
  ];
}
