import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/constants/app_roles.dart';
import 'package:flutter_project/core/constants/university_data.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';

final registrationServiceProvider = Provider<RegistrationService>((ref) {
  return RegistrationService(
    ref.read(firebaseAuthProvider),
    ref.read(firestoreProvider),
  );
});

class RegistrationInput {
  final String fullNameAr;
  final String fullNameEn;
  final String email;
  final String phone;
  final DateTime dateOfBirth;
  final String nationalId;
  final String gender;
  final String faculty;
  final String department;
  final String semester;
  final int graduationYear;
  final double secondaryGpa;
  final String certificateType;
  final String academicDegree;
  final String academicTitle;
  final String specialization;
  final String college;
  final DateTime? employmentDate;
  final double studentPassRate;
  final String password;
  final String role;
  final bool agreedToTerms;
  final bool agreedToPrivacy;

  const RegistrationInput({
    required this.fullNameAr,
    required this.fullNameEn,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.nationalId,
    required this.gender,
    required this.faculty,
    required this.department,
    required this.semester,
    required this.graduationYear,
    required this.secondaryGpa,
    required this.certificateType,
    required this.password,
    required this.role,
    required this.agreedToTerms,
    required this.agreedToPrivacy,
    this.academicDegree = '',
    this.academicTitle = '',
    this.specialization = '',
    this.college = '',
    this.employmentDate,
    this.studentPassRate = 0.0,
  });
}

class RegistrationResult {
  final String uid;
  final int preliminaryScore;
  final RegistrationStatus status;

  const RegistrationResult({
    required this.uid,
    required this.preliminaryScore,
    required this.status,
  });
}

class RegistrationService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  RegistrationService(this._auth, this._firestore);

  int calculatePreliminaryScore({
    required double gpa,
    required int ageInYears,
    required bool allFieldsFilled,
    required String facultyName,
    required String role,
  }) {
    // التحقق من العمر للطلاب فقط
    if (role == 'student' && ageInYears < 17) return -1;
    
    // التحقق من GPA للطلاب فقط في الكليات التنافسية
    const competitiveFaculties = ['كلية الطب', 'كلية الهندسة'];
    if (role == 'student' && gpa < 40 && competitiveFaculties.contains(facultyName)) return -1;

    int score = 0;
    if (gpa >= 85) {
      score += 40;
    } else if (gpa >= 75) {
      score += 30;
    } else if (gpa >= 65) {
      score += 20;
    } else {
      score += 10;
    }

    if (ageInYears <= 25) {
      score += 20;
    } else {
      score += 15;
    }

    score += allFieldsFilled ? 20 : 15;

    if (UniversityData.highDemandFaculties.contains(facultyName)) {
      score += 20;
    } else if (UniversityData.mediumDemandFaculties.contains(facultyName)) {
      score += 15;
    } else {
      score += 10;
    }
    return score;
  }

  RegistrationStatus scoreToStatus(int score) {
    if (score == -1) return RegistrationStatus.autoRejected;
    if (score >= 75) return RegistrationStatus.pendingFinalApproval;
    if (score >= 50) return RegistrationStatus.underReview;
    return RegistrationStatus.requiresAdditional;
  }

  Future<bool> _isNationalIdDuplicate(String nationalId) async {
    final doc = await _firestore.collection('registrationsIndex').doc(nationalId.trim()).get();
    return doc.exists;
  }

  Future<bool> _isPhoneDuplicate(String phone) async {
    final doc = await _firestore.collection('phoneIndex').doc(_normalizedPhoneKey(phone)).get();
    return doc.exists;
  }

  String _normalizedPhoneKey(String phone) {
    var digits = phone.trim().replaceAll(RegExp(r'[\s\-]'), '');
    if (digits.startsWith('+218')) {
      digits = digits.substring(4);
    } else if (digits.startsWith('218')) {
      digits = digits.substring(3);
    } else if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return '218$digits';
  }

  bool isValidFacultyEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@uod\.edu\.ly$').hasMatch(email.trim());
  }

  bool isValidPhoneFormat(String phone) {
    return RegExp(r'^(\+218|218|0)?(91|92|93|94)\d{7}$').hasMatch(phone.trim());
  }

  bool isValidNationalId(String id) {
    return RegExp(r'^\d{12}$').hasMatch(id.trim());
  }

  Future<RegistrationResult> register(RegistrationInput input) async {
    // 1. التحقق من الشروط الأساسية
    if (!input.agreedToTerms || !input.agreedToPrivacy) {
      throw 'يجب الموافقة على الشروط والأحكام وسياسة الخصوصية';
    }
    if (!isValidNationalId(input.nationalId)) {
      throw 'رقم الهوية الوطنية يجب أن يكون مكوناً من 12 رقماً';
    }
    if (!isValidPhoneFormat(input.phone)) {
      throw 'صيغة رقم الهاتف غير صحيحة (مثال: 091XXXXXXX)';
    }

    if (input.role == 'faculty') {
      if (!isValidFacultyEmail(input.email)) {
        throw 'البريد الإلكتروني يجب أن ينتهي بـ @uod.edu.ly';
      }
      if (input.academicDegree.isEmpty || input.academicTitle.isEmpty || input.specialization.isEmpty || input.college.isEmpty) {
        throw 'يرجى استكمال الحقول الأكاديمية الإلزامية الخاصة بعضو هيئة التدريس';
      }
    }

    // 2. التحقق من التكرار (بدون البريد الإلكتروني)
    if (await _isNationalIdDuplicate(input.nationalId)) throw 'رقم الهوية الوطنية مسجل مسبقاً';
    if (await _isPhoneDuplicate(input.phone)) throw 'رقم الهاتف مسجل مسبقاً';

    UserCredential? credential;
    try {
      // 3. إنشاء حساب في Firebase Auth
      debugPrint('🔄 [Registration] Creating Firebase Auth user...');
      credential = await _auth.createUserWithEmailAndPassword(
        email: input.email.trim(),
        password: input.password,
      );
      await credential.user!.updateDisplayName(input.fullNameAr);
      await credential.user!.getIdToken(true);

      final uid = credential.user!.uid;
      debugPrint('✅ [Registration] User created with UID: $uid');

      final now = FieldValue.serverTimestamp();
      final ageInYears = _calculateAge(input.dateOfBirth);
      final allFieldsFilled = _checkCompleteness(input);

      final score = calculatePreliminaryScore(
        gpa: input.secondaryGpa,
        ageInYears: ageInYears,
        allFieldsFilled: allFieldsFilled,
        facultyName: input.role == 'student' ? input.faculty : input.college,
        role: input.role,
      );

      final status = scoreToStatus(score);
      debugPrint('✅ [Registration] Score: $score, Status: ${status.value}');

      // 4. إعداد بيانات المستندات
      final userData = {
        'uid': uid,
        'fullName': input.fullNameAr,
        'fullNameAr': input.fullNameAr,
        'fullNameEn': input.fullNameEn,
        'email': input.email.trim().toLowerCase(),
        'phone': input.phone.trim(),
        'nationalId': input.nationalId.trim(),
        'role': input.role,
        'status': status.value,
        'dateOfBirth': Timestamp.fromDate(input.dateOfBirth),
        'gender': input.gender,
        'gpa': '0.00',
        'completedHours': '0',
        'major': input.role == 'student' ? input.department : '',
        'academicDegree': input.role == 'faculty' ? input.academicDegree : '',
        'academicTitle': input.role == 'faculty' ? input.academicTitle : '',
        'specialization': input.role == 'faculty' ? input.specialization : '',
        'college': input.role == 'faculty' ? input.college : input.faculty,
        'employmentDate': input.role == 'faculty' && input.employmentDate != null ? Timestamp.fromDate(input.employmentDate!) : null,
        'studentPassRate': input.role == 'faculty' ? input.studentPassRate : 0.0,
        'terms_accepted': true,
        'accepted_at': now,
        'createdAt': now,
        'updatedAt': now,
      };

      final registrationData = {
        'uid': uid,
        'fullNameAr': input.fullNameAr,
        'fullNameEn': input.fullNameEn,
        'email': input.email.trim().toLowerCase(),
        'phone': input.phone.trim(),
        'dateOfBirth': Timestamp.fromDate(input.dateOfBirth),
        'nationalId': input.nationalId.trim(),
        'gender': input.gender,
        'role': input.role,
        'faculty': input.role == 'student' ? input.faculty : '',
        'department': input.role == 'student' ? input.department : '',
        'semester': input.role == 'student' ? input.semester : '',
        'expectedGraduationYear': input.role == 'student' ? input.graduationYear : 0,
        'secondaryGpa': input.role == 'student' ? input.secondaryGpa : 0.0,
        'certificateType': input.role == 'student' ? input.certificateType : '',
        'academicDegree': input.role == 'faculty' ? input.academicDegree : '',
        'academicTitle': input.role == 'faculty' ? input.academicTitle : '',
        'specialization': input.role == 'faculty' ? input.specialization : '',
        'college': input.role == 'faculty' ? input.college : '',
        'employmentDate': input.role == 'faculty' && input.employmentDate != null ? Timestamp.fromDate(input.employmentDate!) : null,
        'studentPassRate': input.role == 'faculty' ? input.studentPassRate : 0.0,
        'preliminaryScore': score,
        'status': status.value,
        'submittedAt': now,
        'adminNotes': '',
        'adminUid': '',
        'decisionDate': null,
        'rejectionReason': '',
        'emailSent': false,
      };

      final emailData = _buildEmailNotification(
        fullNameAr: input.fullNameAr,
        email: input.email.trim(),
        score: score,
        status: status,
      );

      // 5. تنفيذ الدفعة
      final batch = _firestore.batch();
      
      debugPrint('📦 [Registration] Preparing batch operations...');
      batch.set(_firestore.collection('users').doc(uid), userData);
      batch.set(_firestore.collection('registrations').doc(uid), registrationData);
      batch.set(_firestore.collection('registrationsIndex').doc(input.nationalId.trim()), {'uid': uid});
      batch.set(_firestore.collection('phoneIndex').doc(_normalizedPhoneKey(input.phone)), {'uid': uid});
      final emailDocRef = _firestore.collection('emailQueue').doc();
      batch.set(emailDocRef, {'uid': uid, ...emailData, 'docId': emailDocRef.id});

      debugPrint('🔄 [Registration] Committing batch...');
      await batch.commit();
      debugPrint('✅ [Registration] Batch committed successfully!');

      return RegistrationResult(uid: uid, preliminaryScore: score, status: status);
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [Registration] FirebaseAuthException: ${e.code} - ${e.message}');
      throw _mapAuthError(e);
    } on FirebaseException catch (e) {
      debugPrint('❌ [Registration] FirebaseException: ${e.code} - ${e.message}');
      if (credential?.user != null) {
        await credential!.user!.delete().catchError((_) {});
        debugPrint('🗑️ [Registration] Auth user deleted due to Firestore failure.');
      }
      throw 'حدث خطأ في قاعدة البيانات السحابية: ${e.message}';
    } catch (e, stack) {
      debugPrint('❌ [Registration] Unexpected error: $e');
      debugPrint('📚 Stack trace: $stack');
      if (credential?.user != null) {
        await credential!.user!.delete().catchError((_) {});
        debugPrint('🗑️ [Registration] Auth user deleted due to unexpected failure.');
      }
      rethrow;
    }
  }

  Map<String, dynamic> _buildEmailNotification({
    required String fullNameAr,
    required String email,
    required int score,
    required RegistrationStatus status,
  }) {
    String templateType = status == RegistrationStatus.autoRejected ? 'auto_rejected' : 'registration_received';
    String subject = status == RegistrationStatus.autoRejected ? 'تحديث حول طلب التسجيل الخاص بك' : 'تم استقبال طلب التسجيل الخاص بك';
    String body = status == RegistrationStatus.autoRejected 
        ? 'عزيزي $fullNameAr، نعتذر لعدم استيفاء الشروط الأكاديمية التلقائية.' 
        : 'عزيزي $fullNameAr، تم استلام طلبك بنجاح وجاري مراجعته من قبل عمادة القبول والتسجيل.';

    return {
      'recipientEmail': email.trim(),
      'subject': subject,
      'body': body,
      'templateType': templateType,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) age--;
    return age;
  }

  bool _checkCompleteness(RegistrationInput input) {
    return input.fullNameAr.isNotEmpty && input.fullNameEn.isNotEmpty && input.email.isNotEmpty && input.phone.isNotEmpty;
  }

  String _mapAuthError(FirebaseAuthException e) {
    if (e.code == 'email-already-in-use') return 'هذا البريد الإلكتروني مسجل مسبقاً في النظام';
    return 'حدث خطأ أثناء إنشاء الحساب: ${e.message}';
  }
}
