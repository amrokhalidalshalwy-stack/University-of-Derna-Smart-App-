class AppValidators {
  AppValidators._();

 
  static String? sanitizeName(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final sanitized = value.replaceAll(RegExp(r'''[<>"'`;]'''), '');
    return sanitized.trim();
  }

 
  static String? validateSafeText(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }
    final dangerous = RegExp(r"""[<>"'`;]|(--)|(/\*)""");
    if (dangerous.hasMatch(value)) {
      return 'يحتوي الحقل على رموز غير مسموح بها';
    }
    return null;
  }

 
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    final phoneRegex = RegExp(r'^09[1-4][0-9]{7}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'أدخل رقم هاتف ليبي صحيح (09X-XXXXXXX)';
    }
    return null;
  }

 
  static String? validateUniversityEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@uod\.edu\.ly$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'يجب أن يكون البريد بصيغة @uod.edu.ly';
    }
    return null;
  }

 
  static String? validateNationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرقم الوطني مطلوب';
    }
    final idRegex = RegExp(r'^\d{12}$');
    if (!idRegex.hasMatch(value.trim())) {
      return 'الرقم الوطني يجب أن يكون 12 رقماً';
    }
    return null;
  }

 
  static String? validateRequired(
    String? value, {
    String fieldName = 'هذا الحقل',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

 
  static String? sanitizeAndValidateText(
    String? value, {
    String fieldName = 'الحقل',
  }) {
    return validateSafeText(value, fieldName: fieldName);
  }
}
