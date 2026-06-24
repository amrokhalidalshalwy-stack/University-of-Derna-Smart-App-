// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'University of Derna';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get homeTitle => 'Home';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Dark Mode';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get notifications => 'Alerts';

  @override
  String get privacy => 'Privacy';

  @override
  String get twoFactor => 'Two-Factor Auth';

  @override
  String get comingSoonTitle => 'Coming Soon';

  @override
  String get comingSoonBody =>
      'This feature will be available in a future update.';

  @override
  String get ok => 'OK';

  @override
  String get academicRecord => 'Academic Record';

  @override
  String get appWelcomeTag => 'Welcome to the Academic Sanctuary';

  @override
  String get resultsGrades => 'Results & Grades';

  @override
  String get digitalLibrary => 'Digital Library';

  @override
  String get universityEmail => 'University Email';

  @override
  String get documentRequest => 'Document Request';

  @override
  String get appMotto => 'University of Derna: One Platform, Integrated Future';

  @override
  String get appWelcomeBody =>
      'Start your educational journey now and discover a world of knowledge and opportunities waiting for you at our leading university.';

  @override
  String get openHorizons => 'Open Your Horizons Now';

  @override
  String get termsContinue => 'Continue';

  @override
  String get universityStats => 'University Statistics';

  @override
  String get viewAndTrackAcademicPlan => 'View and Track Academic Plan';

  @override
  String get studentsCount => 'Students';

  @override
  String get collegesCount => 'Academic Colleges';

  @override
  String get facultyCount => 'Faculty Members';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get rightsReserved =>
      '© 2026 University of Derna. All Rights Reserved.';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get loginSubtitle =>
      'Enter your credentials to access your university account';

  @override
  String get email => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get agreeToTerms => 'I agree to the terms and access permissions';

  @override
  String get loginButton => 'Sign In';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get createAccount => 'Create New Account';

  @override
  String get secureSystem =>
      'University management system is fully protected and encrypted';

  @override
  String get smartCollege => 'Smart College';

  @override
  String welcomeBack(Object name) {
    return 'Welcome, $name';
  }

  @override
  String get unspecifiedMajor => 'Unspecified Major';

  @override
  String get cumulativeGpa => 'Cumulative GPA';

  @override
  String get completedHours => 'Completed Hours';

  @override
  String get academicServices => 'Academic Services';

  @override
  String get grades => 'Grades';

  @override
  String get gradesTitle => 'Results & Grades';

  @override
  String get attendance => 'Attendance';

  @override
  String get noAttendanceData => 'No attendance data yet';

  @override
  String get error => 'Error';

  @override
  String get errorLoadingGrades => 'Error loading grades';

  @override
  String get searchCourse => 'Search for a course...';

  @override
  String get all => 'All';

  @override
  String get undefinedSemester => 'Undefined semester';

  @override
  String get hoursEarned => 'hours earned';

  @override
  String coursesCount(Object count) {
    return '$count Courses';
  }

  @override
  String get gpaLabel => 'Cumulative GPA';

  @override
  String get noSearchResults => 'No search results';

  @override
  String get noGradesRecorded => 'No grades recorded yet';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get finalExam => 'Final Exam';

  @override
  String get midtermExam => 'Midterm';

  @override
  String get hours => 'hours';

  @override
  String get excellent => 'Excellent';

  @override
  String get veryGood => 'Very Good';

  @override
  String get good => 'Good';

  @override
  String get acceptable => 'Acceptable';

  @override
  String get failed => 'Failed';

  @override
  String get schedule => 'Schedule';

  @override
  String get latestNotifications => 'Latest Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get loadingError => 'Loading error';

  @override
  String get pleaseLogin => 'Please sign in';

  @override
  String get dataUnavailable => 'Data unavailable';

  @override
  String get myStudy => 'My Study';

  @override
  String get appPreferences => 'App Preferences';

  @override
  String get notificationsEnabled => 'Enabled';

  @override
  String get notificationsDisabled => 'Disabled';

  @override
  String get showNotificationCenter => 'Show Notification Center';

  @override
  String get accountAndSecurity => 'Account & Security';

  @override
  String get changePassword => 'Change Password';

  @override
  String get aboutUniversity => 'About University';

  @override
  String get aboutApp => 'About App';

  @override
  String get technicalSupport => 'Technical Support';

  @override
  String get faqs => 'FAQs';

  @override
  String get signOut => 'Sign Out';

  @override
  String get languageAuto => 'Auto (System)';

  @override
  String get languageAr => 'Arabic';

  @override
  String get languageEn => 'English';

  @override
  String get agreeToTermsLabel => 'I agree to terms and permissions';

  @override
  String get loading => 'Loading...';

  @override
  String get invalidEmail => 'Invalid email format';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get usernameTooShort =>
      'Please enter your name as registered in the college';

  @override
  String get registrationNumberRequired => 'Registration number is required';

  @override
  String get invalidRegistrationNumber =>
      'Registration number must be 8 or 9 digits';

  @override
  String get confirmPasswordRequired => 'Please confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get signUpTitle => 'Create New Account';

  @override
  String get signUpSubtitle => 'Start your academic journey with us';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get fullNameHint => 'Enter your full name as registered';

  @override
  String get registrationNumberLabel => 'Student ID (Registration Number)';

  @override
  String get registrationNumberHint => 'Example: 202100000';

  @override
  String get passwordHint => 'At least 6 characters';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter password';

  @override
  String get signUpButton => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get legalAgreement =>
      'By clicking \"Create Account\", you agree to the Terms of Service and Privacy Policy of the University of Derna.';

  @override
  String get signUpSuccess =>
      'Account created successfully! Welcome to the University of Derna.';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email to reset your password';

  @override
  String get sendButton => 'Send';

  @override
  String get resetEmailSent => 'Password reset link sent to your email';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get userNotFound => 'Email address not found';

  @override
  String get defaultStudentName => 'Student';

  @override
  String get defaultStudentEmail => 'student@uod.edu.ly';

  @override
  String get supportSubject =>
      'Technical Support Request - University of Derna App';

  @override
  String get profileTitle => 'Profile';

  @override
  String get userNotFoundMsg => 'User data not found';

  @override
  String get editProfilePhoto => 'Edit Profile Photo';

  @override
  String get registrationNumberPrefix => 'ID: ';

  @override
  String get academicInfo => 'Academic Information';

  @override
  String get contactInfo => 'Contact Information';

  @override
  String get majorLabel => 'Major';

  @override
  String get emailLabel => 'Email';

  @override
  String get errorPrefix => 'Error: ';

  @override
  String get earnedHours => 'Earned Hours';

  @override
  String get noGradesMsg => 'No grades recorded yet';

  @override
  String get semesterFallback => 'Unspecified Semester';

  @override
  String get hoursSuffix => 'Hours';

  @override
  String get finalExamLabel => 'Final';

  @override
  String get midtermLabel => 'Midterm';

  @override
  String get totalLabel => 'Total';

  @override
  String get pass => 'Pass';

  @override
  String get fail => 'Fail';

  @override
  String get gradesError => 'Error loading grades';

  @override
  String get attendanceTitle => 'Attendance & Absences';

  @override
  String get attendanceError => 'Error loading attendance data';

  @override
  String get noAttendanceMsg => 'No attendance records yet';

  @override
  String get totalAbsences => 'Total Absences';

  @override
  String get totalAttendancePct => 'Overall Attendance Rate';

  @override
  String atRiskWarning(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'courses',
      one: 'course',
    );
    return 'Warning: $count $_temp0 at risk (attendance rate below 75%)';
  }

  @override
  String get atRiskBadge => '⚠️ At Risk';

  @override
  String totalLecturesLabel(Object count) {
    return '$count Total';
  }

  @override
  String attendedLecturesLabel(Object count) {
    return '$count Attended';
  }

  @override
  String absencesLabel(Object count) {
    return '$count Absent';
  }

  @override
  String get scheduleTitle => 'Academic Schedule';

  @override
  String get noLecturesTitle => 'No lectures for today';

  @override
  String get noLecturesSubtitle => 'Data from local storage. Pull to refresh.';

  @override
  String get refreshAction => 'Refresh';

  @override
  String get daySaturday => 'Saturday';

  @override
  String get daySunday => 'Sunday';

  @override
  String get dayMonday => 'Monday';

  @override
  String get dayTuesday => 'Tuesday';

  @override
  String get dayWednesday => 'Wednesday';

  @override
  String get dayThursday => 'Thursday';

  @override
  String get currentSemesterTitle => 'Current Semester';

  @override
  String get currentGpaLabel => 'Current GPA';

  @override
  String get nextClassTitle => 'Next Lecture';

  @override
  String get quickAccessTitle => 'Quick Access';

  @override
  String get fullScheduleLink => 'Full Schedule';

  @override
  String get attendanceRecordLink => 'Attendance Record';

  @override
  String get gradesReportLink => 'Grades Report';

  @override
  String get departmentScientific => 'Academic Department';

  @override
  String get majorAndTrack => 'Major & Track';

  @override
  String get collegeAffairs => 'University Affairs';

  @override
  String get branchMainName => 'Main Campus (Al-Fataih)';

  @override
  String get branchMainAddress =>
      'Derna University - Al-Fataih District, Derna, Libya';

  @override
  String get deanMainName => 'Dr. Salem Mostafa Al-Osta';

  @override
  String get deanMainTitle => 'Dean of the Faculty of Engineering';

  @override
  String get branchShihaName => 'Derna University (Shiha Branch)';

  @override
  String get branchShihaAddress => 'Shiha District - Derna, Libya';

  @override
  String get deanShihaName => 'Dr. Abdulsalam Al-Haddad';

  @override
  String get deanShihaTitle => 'Dean of the Faculty of Economics and Law';

  @override
  String get branchBabTobrukName => 'Faculty of Medicine (Bab Tobruk)';

  @override
  String get branchBabTobrukAddress => 'Bab Tobruk District - Derna, Libya';

  @override
  String get deanBabTobrukName => 'Prof. Dr. Jamal Abdul Hamid Al-Hassadi';

  @override
  String get deanBabTobrukTitle => 'Dean of the Faculty of Human Medicine';

  @override
  String get branchAlqubaName => 'Derna University (Al-Quba)';

  @override
  String get branchAlqubaAddress => 'Al-Quba - Libya';

  @override
  String get deanAlqubaName => 'Mr. Zuhair Abdullah Gadallah';

  @override
  String get deanAlqubaTitle =>
      'Dean of the Faculty of Engineering - Al-Quba Branch';

  @override
  String get announcementsAndLocation => 'Announcements & Location';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotificationsSaved => 'No saved notifications';

  @override
  String get pullToRefreshSync =>
      'Pull down to refresh and sync with the server.';

  @override
  String get notificationDefault => 'Notification';

  @override
  String get majorSoftwareEngineering => 'Software Engineering';

  @override
  String get collegeNews => 'News';

  @override
  String get collegeDepartments => 'Departments';

  @override
  String get departmentInfoTitle => 'Academic Department';

  @override
  String get academicAdvisorTitle => 'Academic Advisor';

  @override
  String get departmentNewsTitle => 'Department News & Events';

  @override
  String get collegeItSubtitle =>
      'Faculty of Information Technology — University of Derna';

  @override
  String get advisorNameSample => 'Dr. Ahmed Al-Obaidi';

  @override
  String get advisorRoleSample => 'Level 3 Academic Advisor';

  @override
  String get newsResearchTitle => 'Research project registration is open';

  @override
  String get newsResearchDate => '2 days ago';

  @override
  String get newsResearchDescription =>
      'Registration for research projects is now open for the current semester. Interested students are requested to submit their proposals before the deadline set by the department.';

  @override
  String get newsAiSeminarTitle => 'Seminar: AI in education';

  @override
  String get newsAiSeminarDate => '4 days ago';

  @override
  String get newsAiSeminarDescription =>
      'The college is organizing a scientific seminar on the latest applications of artificial intelligence in the education field, with the attendance of a group of experts and specialized academics.';

  @override
  String get newsExamsTitle => 'Final exam schedule updated';

  @override
  String get newsExamsDate => '1 week ago';

  @override
  String get newsExamsDescription =>
      'The final exam schedule for the current semester has been updated. Please review the new schedule and ensure your exam dates in all subjects.';

  @override
  String get collegeAnnouncementsTitle => 'College Announcements';

  @override
  String get collegeLocationTitle => 'College Location';

  @override
  String get deanOfficeTitle => 'Dean\'s Office';

  @override
  String get graduationAlertTitle => 'Important: upcoming graduation ceremony';

  @override
  String get graduationAlertBody =>
      'The graduation ceremony will be held at the end of this month in the main university auditorium.';

  @override
  String get openInteractiveMap => 'Open interactive map';

  @override
  String get deanNameSample => 'Dr. Zuhair Abdullah';

  @override
  String get deanTitleSample => 'Dean, Faculty of Engineering – Al-Quba Branch';

  @override
  String get contactCall => 'Call';

  @override
  String get contactMessage => 'Message';

  @override
  String get contactEmail => 'Email';

  @override
  String get authError => 'Authentication error';

  @override
  String get studentPortal => 'Student Portal';

  @override
  String get facultyPortal => 'Faculty Portal';

  @override
  String get adminPortal => 'Admin Portal';

  @override
  String get studentPortalDesc =>
      'Courses, grades, schedules, and academic services';

  @override
  String get facultyPortalDesc =>
      'Lectures, assessment, attendance, and assignments';

  @override
  String get adminPortalDesc => 'Settings, users, security, and reports';

  @override
  String get gatewayUniversityBadge => 'University of Derna';

  @override
  String get gatewayMainTitle => 'UOD Smart Portal';

  @override
  String get gatewaySubtitle =>
      'An integrated digital platform for the university community';

  @override
  String get portalEnterStudent => 'Enter';

  @override
  String get portalEnterFaculty => 'Sign in';

  @override
  String get portalEnterAdmin => 'Connect';

  @override
  String get guestPortalDivider => 'or';

  @override
  String get guestPortalEnter => 'Continue as guest';

  @override
  String get softwareEngineering => 'Software Engineering';

  @override
  String get adminControlCenter => 'Command & Control Center';

  @override
  String get adminVerifyAccounts => 'Account verification queue';

  @override
  String get userManagementTitle => 'User management';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get roleLabel => 'Role';

  @override
  String get facultyPortalTitle => 'Faculty Portal';

  @override
  String get appName => 'University of Derna App';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get home => 'Home';

  @override
  String get fullName => 'Full Name';

  @override
  String errorRequired(String field) {
    return '$field is required';
  }

  @override
  String get errorInvalidEmail => 'Please enter a valid email address';

  @override
  String get errorPasswordLength => 'Password must be at least 8 characters';

  @override
  String get errorPasswordMatch => 'Passwords do not match';

  @override
  String get successAccountCreated => 'Account created successfully';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get noDataFound => 'No data found';

  @override
  String get smartTimetableTitle => 'Smart Timetable';

  @override
  String get advancedProgrammingSubject => 'Advanced Programming';

  @override
  String get room101Time => 'Room 101 - 8:00 AM to 10:00 AM';

  @override
  String get databaseSubject => 'Database';

  @override
  String get lab3Time => 'Lab 3 - 10:30 AM to 12:30 PM';

  @override
  String get versionLabel => 'Version';

  @override
  String get lastUpdateLabel => 'Last Update';

  @override
  String get may2024 => 'June 2026';

  @override
  String get developerLabel => 'Developer';

  @override
  String get itDepartmentDerna => 'Eng. Amro Khaled Al-Shalwi';

  @override
  String get developerEmail => 'eng.amro@uod.edu.ly';

  @override
  String get aboutAppDescription =>
      'The University of Derna app aims to facilitate student access to academic and administrative services through an integrated platform, striving towards comprehensive digital transformation.';

  @override
  String get authPasswordStrengthWeakest => 'Very Weak';

  @override
  String get authPasswordStrengthWeak => 'Weak';

  @override
  String get authPasswordStrengthFair => 'Fair';

  @override
  String get authPasswordStrengthGood => 'Good';

  @override
  String get authPasswordStrengthStrong => 'Strong ✓';

  @override
  String get authFullNameArabic => 'Full Name (Arabic)';

  @override
  String get authFullNameEnglish => 'Full Name (English)';

  @override
  String get authNationalId => 'National ID';

  @override
  String get authPhoneNumber => 'Phone Number';

  @override
  String get authDateOfBirth => 'Date of Birth';

  @override
  String get authGender => 'Gender';

  @override
  String get authGenderMale => 'Male';

  @override
  String get authGenderFemale => 'Female';

  @override
  String get authCollege => 'College';

  @override
  String get authDepartment => 'Department';

  @override
  String get authStudentId => 'Student ID';

  @override
  String get authErrorNameArabicRequired => 'Arabic name is required';

  @override
  String get authErrorNameEnglishRequired => 'English name is required';

  @override
  String get authErrorNameArabicOnly =>
      'Arabic name must contain Arabic characters only.';

  @override
  String get authErrorNameEnglishOnly =>
      'English name must contain English characters only.';

  @override
  String get authErrorNationalIdRequired => 'National ID is required';

  @override
  String get authErrorNationalIdFormat => 'National ID must be 12 digits';

  @override
  String get authErrorPhoneFormat => 'Invalid phone number';

  @override
  String get authErrorTermsRequired => 'You must agree to the terms';

  @override
  String get authErrorCollegeRequired => 'Please select a college';

  @override
  String get authTermsAndConditions => 'Terms and Conditions';

  @override
  String get authAgreeToTerms => 'I agree to the';

  @override
  String get authPrivacyPolicy => 'Privacy Policy';

  @override
  String get authStepPersonalInfo => 'Personal Information';

  @override
  String get authStepAcademicInfo => 'Academic Information';

  @override
  String get authStepAccountSetup => 'Account Setup';

  @override
  String get authStepNext => 'Next';

  @override
  String get authStepPrevious => 'Previous';

  @override
  String get authStepSubmit => 'Submit';

  @override
  String get authRegistrationSuccess => 'Registration submitted successfully';

  @override
  String get authRegistrationPending => 'Your application is under review';

  @override
  String get authVerificationSent => 'Verification email sent';

  @override
  String get authWelcomeTitle => 'UOD Smart Portal';

  @override
  String get authWelcomeSubtitle => 'Sign in to continue';

  @override
  String get authRememberMe => 'Remember me';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authLoginAdminTitle => 'Central System Administration';

  @override
  String get authLoginFacultyTitle => 'Faculty Portal';

  @override
  String get authLoginAdminSubtitle => 'Please enter authorized credentials';

  @override
  String get authLoginFacultySubtitle => 'Welcome to your academic portal';

  @override
  String get authLoginEmailHint => 'example@uod.edu.ly';

  @override
  String get authStepReview => 'Review';

  @override
  String get authErrorDateOfBirthRequired => 'Please select date of birth';

  @override
  String get authRegistrationScorePrefix => 'Preliminary score:';

  @override
  String get authRegistrationStatus => 'Status:';

  @override
  String get authRegistrationFinalDecision =>
      'You will be notified of the final decision via email within 3-5 business days.';

  @override
  String get authSubmitRequest => 'Submit Request';

  @override
  String get authHintFullNameArabic => 'Mohammed Ahmed Ali Mohammed';

  @override
  String get authHintFullNameEnglish => 'Mohammed Ahmed Ali';

  @override
  String get authHintPhone => '+218910000000';

  @override
  String get authHintNationalId => '123456789012';

  @override
  String get authSelectDateOfBirth => 'Select Date of Birth';

  @override
  String get authErrorGenderRequired => 'Please select a gender';

  @override
  String get authErrorDepartmentRequired => 'Please select a department';

  @override
  String get authHintSelectCollegeFirst => 'Select college first';

  @override
  String get authHintSelectDepartment => 'Select department';

  @override
  String get authSemester => 'Semester';

  @override
  String get authErrorSemesterRequired => 'Please select a semester';

  @override
  String get authExpectedGraduationYear => 'Expected Graduation Year';

  @override
  String get authSecondaryGpa => 'Secondary School GPA (0 - 100)';

  @override
  String get authHintSecondaryGpa => 'Example: 85.5';

  @override
  String get authErrorSecondaryGpaRequired => 'GPA is required';

  @override
  String get authErrorSecondaryGpaRange => 'Enter a number between 0 and 100';

  @override
  String get authCertificateType => 'Certificate Type';

  @override
  String get authErrorCertificateRequired => 'Please select a certificate type';

  @override
  String get authErrorPasswordLength =>
      'Password must be at least 8 characters';

  @override
  String get authConfirmPassword => 'Confirm Password';

  @override
  String get authErrorPasswordMismatch => 'Passwords do not match';

  @override
  String get authErrorInvalidCredentials => 'Incorrect email or password';

  @override
  String get authErrorAccountNotFound => 'Account data not found';

  @override
  String get authErrorPortalMismatch =>
      'You are not authorized for this portal';

  @override
  String get authErrorUserDisabled => 'This account has been disabled';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Please try again later';

  @override
  String get authErrorNetworkFailed => 'Check your internet connection';

  @override
  String get authErrorRoleMismatch => 'You are not authorized for this portal';

  @override
  String get authErrorUserNotFound => 'Account data not found';

  @override
  String get authReviewData => 'Review Data';

  @override
  String get authLabelFullNameArabic => 'Name (Arabic)';

  @override
  String get authLabelFullNameEnglish => 'Name (English)';

  @override
  String get authLabelEmail => 'Email';

  @override
  String get authLabelPhone => 'Phone';

  @override
  String get authLabelNationalId => 'National ID';

  @override
  String get authLabelGender => 'Gender';

  @override
  String get authLabelCollege => 'College';

  @override
  String get authLabelDepartment => 'Department';

  @override
  String get authLabelSemester => 'Semester';

  @override
  String get authLabelGraduationYear => 'Graduation Year';

  @override
  String get authLabelGpa => 'GPA';

  @override
  String get authLabelCertificateType => 'Certificate Type';

  @override
  String get authAgreeToTermsOfService => 'I agree to Terms of Service';

  @override
  String get authAgreeToPrivacyPolicy => 'I agree to Privacy Policy';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsDarkMode => 'Dark Night Mode';

  @override
  String get settingsLanguage => 'Application Language';

  @override
  String get settingsNotifications => 'System Notifications';

  @override
  String get settingsNotifEnabled => 'Enable Notifications';

  @override
  String get settingsNotifGrades => 'Grade Updates';

  @override
  String get settingsNotifAnnouncements => 'Announcements';

  @override
  String get settingsAccount => 'Account Settings';

  @override
  String get settingsPrivacy => 'Privacy & Policy';

  @override
  String get settingsHelp => 'Help Center & FAQs';

  @override
  String get settingsAbout => 'About University Portal';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsLogoutConfirm => 'Are you sure you want to sign out?';

  @override
  String get profileEditTitle => 'Edit Profile';

  @override
  String get profilePersonalInfo => 'Personal Information';

  @override
  String get profileAcademicInfo => 'Academic Information';

  @override
  String get profileContactInfo => 'Contact Information';

  @override
  String get profileFullName => 'Full Name';

  @override
  String get profileStudentId => 'Student ID';

  @override
  String get profileCollege => 'College';

  @override
  String get profileDepartment => 'Department';

  @override
  String get profileLevel => 'Academic Level';

  @override
  String get profileGpa => 'GPA';

  @override
  String get profilePhone => 'Phone Number';

  @override
  String get profileAddress => 'Address';

  @override
  String get profileSaveChanges => 'Save Changes';

  @override
  String get profileChangePhoto => 'Change Photo';

  @override
  String get profileUpdateSuccess => 'Profile updated successfully';

  @override
  String get profileUpdateError => 'Failed to update profile';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get changePasswordCurrent => 'Current Password';

  @override
  String get changePasswordNew => 'New Password';

  @override
  String get changePasswordConfirm => 'Confirm New Password';

  @override
  String get changePasswordSuccess => 'Password changed successfully';

  @override
  String get changePasswordErrorWrong => 'Current password is incorrect';

  @override
  String get changePasswordErrorSame => 'New password must differ from current';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicyLastUpdated => 'Last updated';

  @override
  String get privacyPolicyDataUsage => 'Data Usage';

  @override
  String get privacyPolicyContact => 'Contact Us';

  @override
  String get notificationsEmpty => 'No notifications yet';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsClearAll => 'Clear all';

  @override
  String get notificationsNew => 'New';

  @override
  String get notificationsToday => 'Today';

  @override
  String get notificationsYesterday => 'Yesterday';

  @override
  String get notificationsEarlier => 'Earlier';

  @override
  String get settingsAllFieldsRequired => 'Please fill in all fields';

  @override
  String get settingsChangePasswordError =>
      'An error occurred while changing the password';

  @override
  String get supportTitle => 'Support';

  @override
  String get supportFormSubtitle =>
      'Please fill in the form below and we will contact you soon.';

  @override
  String get supportName => 'Name';

  @override
  String get supportSubjectField => 'Subject';

  @override
  String get supportMessage => 'Message';

  @override
  String get supportMessageRequired => 'Please write the message';

  @override
  String get supportNameRequired => 'Please enter your name';

  @override
  String get supportEmailRequired => 'Please enter your email';

  @override
  String get supportEmailInvalid => 'Please enter a valid email address';

  @override
  String get supportSent => 'Message sent successfully';

  @override
  String get supportSend => 'Send';

  @override
  String get privacyPolicyHeadingInfo =>
      'Privacy Policy for College of Technical Sciences – Derna';

  @override
  String get privacyPolicyIntro =>
      'The College of Technical Sciences Derna is committed to protecting the privacy of its app users and maintaining the confidentiality of their personal data. This policy explains how information provided by students, faculty, and all users is collected, used, and protected.';

  @override
  String get privacyPolicyCollectedTitle => 'Information We Collect:';

  @override
  String get privacyPolicyCollectedBody =>
      '- Personal data such as name, registration number, email.\n- Interaction data with the app and provided services.\n- Device information and usage preferences.';

  @override
  String get privacyPolicyUsageTitle => 'How We Use Information:';

  @override
  String get privacyPolicyUsageBody =>
      'The College of Technical Sciences Derna uses this information to improve services, ensure effective communication with users, and provide technical support when needed.';

  @override
  String get privacyPolicyProtectionTitle => 'Data Protection:';

  @override
  String get privacyPolicyProtectionBody =>
      'The college is committed to taking all necessary technical and administrative measures to protect user data from unauthorized access, modification, or disclosure.';

  @override
  String get privacyPolicySharingTitle =>
      'Sharing Information with Third Parties:';

  @override
  String get privacyPolicySharingBody =>
      'The College of Technical Sciences Derna does not sell or share user data with any external party except where required by law or with the user\'s consent.';

  @override
  String get privacyPolicyAmendmentsTitle =>
      'Amendments to the Privacy Policy:';

  @override
  String get privacyPolicyAmendmentsBody =>
      'The college may update this policy from time to time. Users will be notified of any material changes through the app or via appropriate communication channels.';

  @override
  String get privacyPolicySocialTitle =>
      'To contact the college via social media, use the buttons below:';

  @override
  String get privacyPolicyEmailError =>
      'An error occurred while opening the email app';

  @override
  String get adminDashboardTitle => 'Control Center';

  @override
  String get adminDashboardWelcome => 'Welcome to the Central Control Unit';

  @override
  String get adminDashboardStatusSafe => 'System Status: Secure & Connected';

  @override
  String get adminDashboardLiveAnalysis => 'Live Data Analysis';

  @override
  String get adminDashboardTotalRecords => 'Total Records';

  @override
  String get adminDashboardPendingReqs => 'Pending Requests';

  @override
  String get adminDashboardApproved => 'Approved';

  @override
  String get adminDashboardRejected => 'Rejected';

  @override
  String get adminDashboardActiveUsers => 'Active Users';

  @override
  String get adminDashboardTotalStudents => 'Total Students';

  @override
  String get adminDashboardQuickActions => 'Quick Control Units';

  @override
  String get adminDashboardSystemLogs => 'System Logs (Logs)';

  @override
  String get adminDashboardUserMgmt => 'User Management';

  @override
  String get adminDashboardVerifQueue => 'Registration Requests';

  @override
  String get adminDashboardDrawerTitle => 'Central System Administration';

  @override
  String get adminDashboardDrawerDashboard => 'Dashboard';

  @override
  String get adminDashboardDrawerRegistrations => 'Registration Requests';

  @override
  String get adminDashboardDrawerEndSession => 'End Session';

  @override
  String get adminDashboardErrorText => 'System error occurred';

  @override
  String get verifQueueTitle => 'Verification Queue';

  @override
  String get verifQueueTabAll => 'All';

  @override
  String get verifQueueTabPending => 'Pending Approval';

  @override
  String get verifQueueTabUnderReview => 'Under Review';

  @override
  String get verifQueueTabRequiresInfo => 'Additional Review';

  @override
  String get verifQueueEmpty => 'No applications in this queue';

  @override
  String get viewAll => 'View All';

  @override
  String get verifQueueApprove => 'Approve';

  @override
  String get verifQueueReject => 'Reject';

  @override
  String get verifQueueApproveConfirm => 'Confirm Approval';

  @override
  String get verifQueueRejectConfirm => 'Confirm Rejection';

  @override
  String get verifQueueApproveMsg =>
      'Are you sure you want to approve this application?';

  @override
  String get verifQueueRejectMsg =>
      'Are you sure you want to reject this application?';

  @override
  String get verifQueueRejectReason => 'Rejection Reason';

  @override
  String get verifQueueRejectReasonHint => 'Choose the reason';

  @override
  String get verifQueueRejectCustomHint => 'Write the reason...';

  @override
  String get verifQueueOtherReason => 'Other';

  @override
  String get verifQueueScore => 'Score';

  @override
  String get verifQueueApplicantName => 'Applicant';

  @override
  String get verifQueueCollege => 'College';

  @override
  String get verifQueueSubmittedDate => 'Submitted';

  @override
  String get verifQueueApproveSuccess => 'Application approved successfully';

  @override
  String get verifQueueRejectSuccess => 'Application rejected';

  @override
  String get verifQueueErrorAction => 'Failed to process application';

  @override
  String get verifQueueYes => 'Yes';

  @override
  String get verifQueueNo => 'No';

  @override
  String get verifQueueConfirmTitle => 'Confirm';

  @override
  String get verifQueueFieldNameEn => 'Name (English)';

  @override
  String get verifQueueFieldEmail => 'Email';

  @override
  String get verifQueueFieldPhone => 'Phone';

  @override
  String get verifQueueFieldNationalId => 'National ID';

  @override
  String get verifQueueFieldGender => 'Gender';

  @override
  String get verifQueueFieldSemester => 'Semester';

  @override
  String get verifQueueFieldGpa => 'GPA';

  @override
  String get verifQueueFieldGraduationYear => 'Graduation Year';

  @override
  String get systemLogsTitle => 'System Logs';

  @override
  String get systemLogsEmpty => 'No activity logs yet';

  @override
  String get systemLogsErrorLoad => 'Failed to load logs';

  @override
  String get systemLogsActionApproved => 'Approved Account';

  @override
  String get systemLogsActionRejected => 'Rejected Account';

  @override
  String get systemLogsActionOther => 'Action';

  @override
  String get systemLogsAdmin => 'Admin';

  @override
  String get systemLogsTarget => 'Target User';

  @override
  String get systemLogsTimestamp => 'Time';

  @override
  String get systemLogsDetails => 'Details';

  @override
  String get statusPendingFinalApproval => 'Pending Final Approval';

  @override
  String get statusUnderReview => 'Under Review';

  @override
  String get statusRequiresAdditional => 'Requires Additional Info';

  @override
  String get statusAutoRejected => 'Auto Rejected';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusSuspended => 'Suspended';

  @override
  String get rejectReasonInsufficientData => 'Insufficient academic data';

  @override
  String get rejectReasonDocumentIssues => 'Document issues';

  @override
  String get rejectReasonDuplicateAccount => 'Duplicate account';

  @override
  String get rejectReasonIncompleteInfo => 'Incomplete information';

  @override
  String get rejectReasonCapacityFull => 'Capacity full in major';

  @override
  String get rejectReasonAgeRequirement => 'Age requirement not met';

  @override
  String get pendingStatusTitlePending => 'Your Application is Under Review';

  @override
  String get pendingStatusTitleRejected => 'Application Not Accepted';

  @override
  String pendingStatusBodyPending(Object status) {
    return 'Thank you for registering at the University of Derna. Your application is $status and you will be notified of the final decision via email within 3-5 business days.';
  }

  @override
  String get pendingStatusBodyRejected =>
      'Your registration has been rejected. You can contact Admissions for more information.';

  @override
  String get pendingStatusRefresh => 'Update Status';

  @override
  String get pendingStatusSignOut => 'Sign Out';

  @override
  String get pendingStatusContact => 'For inquiries: admissions@uod.edu.ly';

  @override
  String get systemLogsSystem => 'System';

  @override
  String get adminDashboardSystemOnline => 'SYSTEM ONLINE';

  @override
  String get notApplicable => 'N/A';

  @override
  String get gradesSyncTooltip => 'Sync from University Portal';

  @override
  String gradesSyncSuccess(int count) {
    return 'Sync complete — $count records';
  }

  @override
  String get gradesSyncFailed => 'Sync failed';

  @override
  String get gradesGpSuffix => 'GP';

  @override
  String get feesTitle => 'Fees';

  @override
  String get feesSavedRecords => 'Saved Fee Records';

  @override
  String get feesItems => 'Items';

  @override
  String get feesLocalRecord => 'Fee Records (Local)';

  @override
  String get feesEmpty => 'No local fee data available';

  @override
  String get feesDefaultTitle => 'Fee';

  @override
  String get feesPayButton => 'Pay Outstanding Fees';

  @override
  String get feesPaid => 'Paid';

  @override
  String get feesUnpaid => 'Unpaid';

  @override
  String get facultyMyClasses => 'My Classes';

  @override
  String get facultyWelcome => 'Welcome, Doctor';

  @override
  String get facultyWelcomeSubtitle =>
      'Wishing you a productive and distinguished semester.';

  @override
  String get facultyAcademicOverview => 'Quick Academic Overview';

  @override
  String get facultyEnrolledStudents => 'Enrolled Students';

  @override
  String get facultyCourses => 'Courses';

  @override
  String get facultyWeeklyAttendance => 'Weekly Course Attendance Rate';

  @override
  String get facultyNoCourses => 'No courses available currently';

  @override
  String facultyClassSub(String dept, String sem) {
    return 'Dept. $dept | Semester $sem';
  }

  @override
  String get facultySelectCourse => 'Select Course';

  @override
  String get facultyErrorLoadingCourses => 'Error loading courses';

  @override
  String get facultySelectCourseForStudents =>
      'Please select a course to view students list';

  @override
  String get facultyNoStudents => 'No students found';

  @override
  String get facultyGradesTitle => 'Record Academic Grades';

  @override
  String get facultySelectCourseForGrades =>
      'Please select a course to open grades sheet';

  @override
  String facultyTotalScorePrefix(double score) {
    return 'Total: $score';
  }

  @override
  String get facultyMidtermLabel => 'Midterm (40)';

  @override
  String get facultyFinalLabel => 'Final (40)';

  @override
  String get facultyAssignmentsLabel => 'Assignments (20)';

  @override
  String get eRequestsTitle => 'E-Requests Portal';

  @override
  String get myRequests => 'My Requests';

  @override
  String get noRequestsYet => 'No requests submitted yet';

  @override
  String get noRequestsDescription =>
      'You can submit your electronic requests from the sections below';

  @override
  String get requestTypeGraduationCertificate => 'Graduation Certificate';

  @override
  String get requestTypeOfficialTranscript => 'Official Transcript';

  @override
  String get requestTypeSemesterDeferral => 'Semester Deferral';

  @override
  String get requestTypeMajorChange => 'Major Change';

  @override
  String get requestStatusPending => 'Under Review';

  @override
  String get requestStatusApproved => 'Approved';

  @override
  String get requestStatusRejected => 'Rejected';

  @override
  String get requestStatusReadyForPickup => 'Ready for Pickup';

  @override
  String get submitRequest => 'Submit Request';

  @override
  String get cancelRequest => 'Cancel Request';

  @override
  String get cancelRequestConfirm =>
      'Are you sure you want to cancel this request?';

  @override
  String get cancelRequestWarning => 'This action cannot be undone';

  @override
  String get requestSubmitted => 'Request submitted successfully';

  @override
  String get requestCancelled => 'Request cancelled';

  @override
  String get requestDetails => 'Request Details';

  @override
  String get requestTimeline => 'Request Timeline';

  @override
  String get timelineSubmitted => 'Submitted';

  @override
  String get timelineReview => 'Under Review';

  @override
  String get timelineDecision => 'Decision Made';

  @override
  String get timelineReady => 'Ready for Pickup';

  @override
  String get adminNote => 'Admin Note';

  @override
  String get optionalNotes => 'Notes (optional)';

  @override
  String get numberOfCopies => 'Number of Copies';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageEnglish => 'English';

  @override
  String get semesterToDefer => 'Semester to Defer';

  @override
  String get reasonForRequest => 'Reason for Request';

  @override
  String get reasonRequired => 'Reason is required';

  @override
  String get newMajor => 'Requested New Major';

  @override
  String get selectSemester => 'Select Semester';

  @override
  String get selectMajor => 'Select Major';

  @override
  String get validationError =>
      'Please fill all fields and attach the exam paper';

  @override
  String get requestFailed => 'Request submission failed';

  @override
  String get pleaseTryAgain => 'Please try again';

  @override
  String get eRequests => 'E-Requests';

  @override
  String collegeCampusLabel(String name) {
    return 'Campus: $name';
  }

  @override
  String get campusDerna => 'Derna';

  @override
  String get campusQubbah => 'Al-Qubbah';

  @override
  String collegeWelcomeTitle(String name) {
    return 'Welcome to $name';
  }

  @override
  String get collegeWelcomeSubtitle =>
      'College content, announcements, and departments are available from the tabs below.';

  @override
  String get collegeNoDepartments =>
      'No registered departments for this college yet.';

  @override
  String collegeNewsTitle(String name) {
    return '$name News';
  }

  @override
  String get collegeNewsAnnouncement => 'Academic Announcement';

  @override
  String get collegeNewsLabel => 'College News';

  @override
  String get collegeNewsPlaceholder =>
      'News will be connected to Firestore later.';

  @override
  String get universityName => 'University of Derna';

  @override
  String get guestViewList => 'List View';

  @override
  String get guestViewGrid => 'Grid View';

  @override
  String get guestSearchHint => 'Search for college or department...';

  @override
  String guestCollegesCount(int count) {
    return '$count Colleges';
  }

  @override
  String get guestPortalTitle => 'Guest Portal';

  @override
  String guestNoResultsFor(String search) {
    return 'No results found for \"$search\"';
  }

  @override
  String get guestSignUpCTA => 'Register Now at University of Derna';

  @override
  String guestDepartmentsCount(int count) {
    return '$count Departments';
  }

  @override
  String get guestAcademicDepartments => 'Academic Departments';

  @override
  String get guestRegisterInCollege => 'Register in this College';

  @override
  String get collegesTitle => 'Colleges';

  @override
  String get searchCollegesHint => 'Search colleges...';

  @override
  String get noCollegesFoundMessage => 'No colleges found';

  @override
  String departmentsCount(int count) {
    return '$count departments';
  }

  @override
  String get viewDetailsButton => 'View Details';

  @override
  String get timetableTitle => 'Timetable';

  @override
  String get weekTabLabel => 'Week';

  @override
  String get monthTabLabel => 'Month';

  @override
  String get noSessionsMessage => 'No sessions scheduled';

  @override
  String sessionTimeFormat(String startTime, String endTime) {
    return '$startTime - $endTime';
  }

  @override
  String get guestContinueButton => 'Continue as Guest';

  @override
  String get guestWarningMessage => 'Your data won\'t be saved across devices';

  @override
  String get proceedButton => 'Proceed';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get transcriptTitle => 'Semester Transcript';

  @override
  String transcriptSemesterLabel(String semester) {
    return 'Semester: $semester';
  }

  @override
  String transcriptStudentIdLabel(String id) {
    return 'Student ID: $id';
  }

  @override
  String transcriptGpaLabel(String gpa) {
    return 'GPA: $gpa';
  }

  @override
  String get transcriptLoadingMessage => 'Loading transcript...';

  @override
  String get transcriptGeneratingMessage => 'Generating PDF...';

  @override
  String get transcriptNoDataMessage => 'No transcript data available';

  @override
  String get transcriptRetryButton => 'Retry';

  @override
  String get transcriptOfflineBanner => 'Using cached version - offline mode';

  @override
  String get transcriptNoCacheMessage =>
      'No cached transcript available offline';

  @override
  String get transcriptRefreshButton => 'Refresh from server';

  @override
  String transcriptLastUpdatedLabel(String date) {
    return 'Last updated: $date';
  }

  @override
  String get transcriptOpenPdfButton => 'Open PDF';

  @override
  String get transcriptDownloadButton => 'Download';

  @override
  String get notificationsEmptyMessage => 'No notifications yet';

  @override
  String get notificationsMarkAllReadButton => 'Mark all as read';

  @override
  String get notificationNewBadge => 'New';

  @override
  String notificationTimeAgo(String time) {
    return '$time ago';
  }

  @override
  String get notificationDeleteButton => 'Delete';

  @override
  String get alertsTitle => 'Alerts';

  @override
  String get announcementsTitle => 'Announcements';

  @override
  String get notificationSettingsButton => 'Notification Settings';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get inboxTitle => 'Inbox';

  @override
  String get chatTitle => 'Chat';

  @override
  String get messagesEmptyMessage => 'No messages yet';

  @override
  String get messageSearchHint => 'Type your message here...';

  @override
  String get messageComposeButton => 'New Message';

  @override
  String get messageReplyButton => 'Reply';

  @override
  String get absenceExcuseTitle => 'Submit Absence Excuse';

  @override
  String get subjectLabel => 'Subject';

  @override
  String get absencePeriodLabel => 'Absence Period';

  @override
  String get selectDatesHint => 'Tap to select dates';

  @override
  String get excuseTypeLabel => 'Excuse Type';

  @override
  String get excuseTypeSick => 'Sick Leave';

  @override
  String get excuseTypeEmergency => 'Emergency';

  @override
  String get excuseTypeFamily => 'Family Reasons';

  @override
  String get excuseTypeOther => 'Other';

  @override
  String get descriptionLabel => 'Description and Reason';

  @override
  String get descriptionHint => 'Write excuse details here...';

  @override
  String get attachmentsLabel =>
      'Attachments (Optional, required for sick leave)';

  @override
  String get tapToAttach => 'Tap to attach file or image';

  @override
  String get maxFileSize => 'Maximum: 5 MB';

  @override
  String get removeAttachment => 'Remove';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get choosePdf => 'Choose PDF File';

  @override
  String get fileSizeError => 'File size must not exceed 5 MB';

  @override
  String get selectDateError => 'Please select absence period';

  @override
  String get medicalAttachmentRequired =>
      'Medical attachment required for sick leave';

  @override
  String get userNotLoggedIn => 'User is not logged in';

  @override
  String get excuseAlreadySubmitted =>
      'An excuse for this subject has already been submitted for the same date';

  @override
  String get uploadingRequest => 'Uploading request...';

  @override
  String get excuseSubmittedSuccess =>
      'Excuse submitted successfully and will be reviewed by college administration';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get selectSubjectError => 'Please select subject';

  @override
  String get selectExcuseTypeError => 'Please select excuse type';

  @override
  String get writeReasonError => 'Please write the reason';

  @override
  String get enrollmentRenewalTitle => 'Enrollment Renewal';

  @override
  String get selectPaymentMethodError => 'Please select payment method first';

  @override
  String submissionError(String error) {
    return 'Error during submission: $error';
  }

  @override
  String get startRenewalProcess => 'Start Renewal Process';

  @override
  String get confirmPayment => 'Confirm Payment and Submit';

  @override
  String get back => 'Back';

  @override
  String get reviewDataStep => 'Review Data';

  @override
  String get paymentMethodStep => 'Payment Method';

  @override
  String get requestStatusStep => 'Request Status';

  @override
  String get studentNameLabel => 'Student Name:';

  @override
  String get studentIdLabel => 'Student ID:';

  @override
  String get collegeLabel => 'College:';

  @override
  String get academicYearLabel => 'Academic Year:';

  @override
  String get deadlineLabel => 'Deadline:';

  @override
  String get feesRequiredLabel => 'Required Fees:';

  @override
  String get paymentMethodBank => 'Bank Transfer';

  @override
  String get paymentMethodLibyaBank => 'Libya Bank';

  @override
  String get paymentMethodOnline => 'Online Payment';

  @override
  String get republicBank => 'Republic Bank';

  @override
  String get bankAccountNumber => 'Account Number: 123-456789-00';

  @override
  String get beneficiary => 'Beneficiary: University of Derna';

  @override
  String get attachReceipt => 'Attach Transfer Receipt';

  @override
  String get receiptAttached => 'Payment receipt attached successfully';

  @override
  String get libyaCentralBank => 'Libya Central Bank';

  @override
  String get cardPayment => 'Payment via Bank Card';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get requestApproved => 'Your Request Approved ✓';

  @override
  String get requestApprovedMessage =>
      'Your enrollment renewal has been approved. Welcome to the new academic year.';

  @override
  String get requestRejected => 'Request Rejected';

  @override
  String get requestRejectedMessage =>
      'Your enrollment renewal request has been rejected. Please contact Admissions and Registration for inquiries.';

  @override
  String get requestPending => 'Your Request Under Review';

  @override
  String get requestPendingMessage =>
      'Your request has been received successfully. It will be reviewed by Admissions and Registration and you will be notified of the result.';

  @override
  String get referenceNumberLabel => 'Reference Number:';

  @override
  String get examPapersTitle => 'Exam Papers';

  @override
  String get quizzesCategory => 'Quizzes';

  @override
  String get midtermCategory => 'Midterm Exam';

  @override
  String get finalCategory => 'Final Exam';

  @override
  String get noPapersInSection => 'No papers in this section currently';

  @override
  String loadingPapersError(String error) {
    return 'Error loading exam papers: $error';
  }

  @override
  String get unknownDate => 'Unknown Date';

  @override
  String uploadDateLabel(String date) {
    return 'Upload Date: $date';
  }

  @override
  String get unknownSubject => 'Unknown Subject';

  @override
  String get viewPaper => 'View';

  @override
  String get fileLinkUnavailable => 'File link unavailable';

  @override
  String get mockSubject1 => 'Advanced Programming - CS301';

  @override
  String get mockSubject2 => 'Data Structures - CS202';

  @override
  String get mockSubject3 => 'Artificial Intelligence - CS405';

  @override
  String get mockSubject4 => 'Discrete Mathematics - MA104';

  @override
  String get messageForwardButton => 'Forward';

  @override
  String get forumTitle => 'Student Forum';

  @override
  String get addPost => 'Add Post';

  @override
  String get helpCenterTitle => 'Help Center';

  @override
  String get faqTitle => 'Frequently Asked Questions';

  @override
  String get contactUsTitle => 'Contact Us';

  @override
  String get faqSearchHint => 'Search FAQs...';

  @override
  String get supportTicketButton => 'Submit a Ticket';

  @override
  String get supportEmailLabel => 'Email Support';

  @override
  String get supportPhoneLabel => 'Call Support';

  @override
  String get reportProblemButton => 'Report a Problem';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search...';

  @override
  String get filterTitle => 'Filter';

  @override
  String get clearFiltersButton => 'Clear Filters';

  @override
  String get applyFiltersButton => 'Apply Filters';

  @override
  String get noSearchResultsMessage => 'No results found';

  @override
  String get networkError => 'Network connection failed. Check your internet.';

  @override
  String get timeoutError => 'Request timed out. Please try again.';

  @override
  String get serverError => 'Server error. Please try again later.';

  @override
  String get unauthorizedError => 'You are not authorized. Please login again.';

  @override
  String get databaseSeederTitle => 'Database Seeder';

  @override
  String get databaseSeederDescription =>
      'This tool creates interconnected test data for the university system (Student, Faculty, Admin).';

  @override
  String get seedDatabaseButton => 'Start Seeding';

  @override
  String get databaseSeederWarning =>
      '⚠️ Any existing test data will be deleted before seeding.';

  @override
  String get databaseSeedingSuccess => 'Database seeded successfully!';

  @override
  String get databaseSeedingError => 'Database seeding failed';

  @override
  String get notFoundError => 'Data not found.';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationInvalidEmail => 'Please enter a valid email';

  @override
  String get validationPasswordTooShort =>
      'Password must be at least 6 characters';

  @override
  String get validationPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get onboardingTitle => 'Welcome to University Portal';

  @override
  String get onboardingSkipButton => 'Skip';

  @override
  String get onboardingNextButton => 'Next';

  @override
  String get onboardingGetStartedButton => 'Get Started';

  @override
  String get tutorialCoursesTitle => 'Track Your Courses';

  @override
  String get tutorialGradesTitle => 'View Your Grades';

  @override
  String get tutorialNotificationsTitle => 'Stay Updated';

  @override
  String get unauthorizedTitle => 'Access Denied';

  @override
  String get unauthorizedMessage =>
      'You do not have permission to access this section. This attempt has been logged for security purposes.';

  @override
  String get returnToPortal => 'Return to My Portal';

  @override
  String get gradeInvalidNumber => 'Enter a valid number';

  @override
  String get gradeMaxMidterm => 'Max score is 40';

  @override
  String get gradeMaxFinal => 'Max score is 40';

  @override
  String get gradeMaxAssignments => 'Max score is 20';

  @override
  String get changeRoleTitle => 'Change Role';

  @override
  String get classDetailTitle => 'Class Details';

  @override
  String get studentsListTab => 'Students';

  @override
  String get announcementsTab => 'Announcements';

  @override
  String get searchStudent => 'Search for a student...';

  @override
  String get addAnnouncement => 'Add Announcement';

  @override
  String get addAnnouncementTitle => 'New Announcement';

  @override
  String get announcementHint => 'Write your announcement here...';

  @override
  String get announcementAdded => 'Announcement added successfully';

  @override
  String get deleteAnnouncement => 'Delete Announcement';

  @override
  String get deleteConfirmation =>
      'Are you sure you want to delete this announcement?';

  @override
  String get announcementDeleted => 'Announcement deleted successfully';

  @override
  String get noAnnouncements => 'No announcements yet';

  @override
  String get noStudents => 'No students found';

  @override
  String get profileFacultyMember => 'Distinguished Faculty Member';

  @override
  String get profileExperienceYears => 'Years of Experience';

  @override
  String get profilePublishedResearch => 'Published Research';

  @override
  String get profileJobId => 'Job ID';

  @override
  String get profileSpecialization => 'Specialization';

  @override
  String get profileEmail => 'Email Address';

  @override
  String get profileDigitalDocuments => 'Digital Documents';

  @override
  String get profileDownloadCard => 'Download Electronic Card';

  @override
  String get profileDownloadDecree => 'Download Appointment Decree';

  @override
  String get profileLogout => 'Logout';

  @override
  String get scheduleTerm => 'Fall 2024';

  @override
  String get scheduleToday => 'Today\'s Schedule';

  @override
  String get scheduleActiveNow => 'Active Now';

  @override
  String get scheduleLectureRoom => 'Room';

  @override
  String get scheduleFloor => 'Floor';

  @override
  String get scheduleStudentsRegistered => 'students registered';

  @override
  String get scheduleAttendanceButton => 'Record Attendance';

  @override
  String get scheduleUpcoming => 'Upcoming Lecture';

  @override
  String get scheduleTheoretical => 'Theoretical';

  @override
  String get schedulePractical => 'Practical';

  @override
  String get scheduleGreetingDoctor => 'Hello Dr.';

  @override
  String get settingsEditProfile => 'Edit Profile Information';

  @override
  String get settingsChangePassword => 'Change Secure Password';

  @override
  String get settingsLanguageDefault => 'Arabic (Default)';

  @override
  String get settingsSystem => 'System Preferences';

  @override
  String get settingsBiometric => 'Biometric Fingerprint Login';

  @override
  String get settingsSupport => 'Support & Information';

  @override
  String get attendanceSheetTitle => 'Attendance Registration';

  @override
  String get attendanceSheetSubtitle =>
      'Manage student attendance and upload lecture materials';

  @override
  String get attendanceCurrentLecture => 'Current Lecture';

  @override
  String get attendanceRoom => 'Room 104 - Technology Building';

  @override
  String get attendanceStudentList => 'Student List';

  @override
  String get attendanceStudentCount => 'Total students';

  @override
  String get attendancePresent => 'Present';

  @override
  String get attendanceLate => 'Late';

  @override
  String get attendanceAbsent => 'Absent';

  @override
  String get attendanceUploadSection => 'Upload Lecture Files';

  @override
  String get attendanceUploadHint => 'Tap here or drag files to upload';

  @override
  String get attendanceUploadTypes => 'PDF, PPTX, DOCX (up to 50 MB)';

  @override
  String get attendanceSaveReport => 'Save & Submit Report';

  @override
  String get attendanceSaved => 'Attendance saved successfully';

  @override
  String get studentsTitle => 'Students Directory & Communication';

  @override
  String get studentsSubtitle =>
      'Manage attendance, communication, and academic data';

  @override
  String get studentsNewAnnouncement => 'Send New Announcement';

  @override
  String get studentsTargetAll => 'All';

  @override
  String get studentsTargetGroupA => 'Group A';

  @override
  String get studentsTargetGroupB => 'Group B';

  @override
  String get studentsTargetStruggling => 'Struggling Students';

  @override
  String get studentsAnnouncementHint => 'Write your announcement here...';

  @override
  String get studentsBroadcastNow => 'Broadcast Now';

  @override
  String get studentsRegistered => 'Registered Students';

  @override
  String get studentsSearch => 'Search by name or university ID...';

  @override
  String get studentsRecentAnnouncements => 'Recent Announcements Log';

  @override
  String get studentsConfirmations => 'confirmations';

  @override
  String get studentsViews => 'views';

  @override
  String get studentsMessageSent => 'Announcement sent successfully';

  @override
  String get reportsTitle => 'Grade Distribution Reports';

  @override
  String get reportsSelectSemester => 'Academic Semester';

  @override
  String get reportsSelectCourse => 'Course';

  @override
  String get reportsSuccessRate => 'Overall Pass Rate';

  @override
  String get reportsTotalStudents => 'Total Students';

  @override
  String get reportsAverageGrade => 'Grade Average';

  @override
  String get reportsDistributionTitle => 'Grade Distribution Chart';

  @override
  String get reportsGradeA => 'Excellent';

  @override
  String get reportsGradeB => 'Very Good';

  @override
  String get reportsGradeC => 'Good';

  @override
  String get reportsGradeD => 'Pass';

  @override
  String get reportsGradeF => 'Fail';

  @override
  String get reportsExportPdf => 'Export PDF Report';

  @override
  String get reportsExportSuccess => 'Report exported successfully';

  @override
  String get assignmentsTitle => 'Assignments & Grades';

  @override
  String get assignmentsSubtitle => 'Fall 2024 Semester - IT Faculty';

  @override
  String get assignmentsWaiting => 'Waiting for grading';

  @override
  String get assignmentsStudents => 'students';

  @override
  String get assignmentsDueTomorrow => 'Due tomorrow';

  @override
  String get assignmentsGraded => 'Graded Students';

  @override
  String get assignmentsAddTitle => 'Add New Assignment';

  @override
  String get assignmentsAssignmentTitle => 'Assignment Title';

  @override
  String get assignmentsAssignmentTitleHint =>
      'e.g. Assignment 1 - Data Structures';

  @override
  String get assignmentsMaxGrade => 'Max Grade';

  @override
  String get assignmentsDueDate => 'Due Date';

  @override
  String get assignmentsPublish => 'Publish New Assignment';

  @override
  String get assignmentsCoursePrefix => 'Course:';

  @override
  String get assignmentsGradingSection => 'Grade Entry';

  @override
  String get assignmentsGradeLabel => 'Grade';

  @override
  String get assignmentsShowMore => 'Show More Students';

  @override
  String get assignmentsValidationError => 'Please check input values';

  @override
  String get facultyPortalDrawerTitle => 'Faculty Portal';

  @override
  String get academicPlanTitle => 'Academic Plan & Tracking';

  @override
  String get semesterOne => 'Semester 1';

  @override
  String get semesterTwo => 'Semester 2';

  @override
  String get semesterThree => 'Semester 3';

  @override
  String get semesterFour => 'Semester 4';

  @override
  String get noCoursesThisSemester => 'No courses listed for this semester';

  @override
  String get planProgressRate => 'Academic Plan Progress Rate';

  @override
  String planProgressDetails(int completed, int total) {
    return 'You have successfully completed $completed out of $total credit hours in your academic plan.';
  }

  @override
  String get courseStatusCompleted => 'Completed';

  @override
  String get courseStatusInProgress => 'In Progress';

  @override
  String get courseStatusRemaining => 'Remaining';

  @override
  String creditHoursLabel(int credits) {
    return '$credits credit hours';
  }

  @override
  String get lecture => 'Lecture';

  @override
  String get editProfileTooltip => 'Edit Profile';

  @override
  String get absenceExcuse => 'Absence Excuse';

  @override
  String get examPapers => 'Exam Papers';

  @override
  String get registrationRenewal => 'Registration Renewal';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get goodEveningReply => 'Good Evening';

  @override
  String get studentForum => 'Student Forum';

  @override
  String get send => 'Send';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get am => 'AM';

  @override
  String get pm => 'PM';

  @override
  String get sendMessageTitle => 'Send Announcement';

  @override
  String get sending => 'Sending...';

  @override
  String get sendMessageSuccess => 'Announcement sent successfully';

  @override
  String get selectCourseError => 'Please select a course';

  @override
  String get courseSection => 'Course / Section';

  @override
  String get announcementSubjectTitle => 'Announcement Subject';

  @override
  String get announcementSubjectPlaceholder =>
      'Write announcement subject here';

  @override
  String get announcementSubjectError => 'Please write a subject';

  @override
  String get announcementBodyTitle => 'Announcement Body';

  @override
  String get announcementBodyPlaceholder =>
      'Write your announcement or notice to students here...';

  @override
  String get announcementBodyError => 'Please write the announcement text';

  @override
  String get systemTheme => 'System Default';

  @override
  String get langAr => 'العربية';

  @override
  String get langEn => 'English';

  @override
  String get facultyMember => 'Faculty Member';

  @override
  String get associateProfessor =>
      'Associate Professor - Faculty of Engineering';

  @override
  String get distinguishedFacultyMember => 'Distinguished Faculty Member';

  @override
  String get passwordResetNote =>
      'A password reset link will be sent to your email';

  @override
  String get logoutConfirmTitle => 'Confirm Logout';

  @override
  String get logoutConfirmBody =>
      'Are you sure you want to log out of the portal?';

  @override
  String get sunday => 'Sunday';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get ahmed => 'Ahmed';

  @override
  String get hourShortcut => 'h';

  @override
  String get hall => 'Hall';

  @override
  String get student => 'Student';

  @override
  String get questionMark => '?';

  @override
  String get fileSizeLimitNote => 'File size must not exceed 10 MB';

  @override
  String get uploadSuccess => 'Exam paper uploaded successfully';

  @override
  String get uploadFailed => 'Error occurred during upload';

  @override
  String get uploadPageTitle => 'Upload Exam Paper';

  @override
  String get selectCourse => 'Select Course';

  @override
  String get selectExamType => 'Select Exam Type';

  @override
  String get pdfPlaceholder => 'Tap to select a PDF file';

  @override
  String get maxSizeLimit => 'Max: 10MB';

  @override
  String get removeFile => 'Remove File';

  @override
  String get quiz => 'Quiz';

  @override
  String get other => 'Other';

  @override
  String get targetCourse => 'Target Course';

  @override
  String get examType => 'Exam Type';

  @override
  String get examPaperPdf => 'Exam Paper (PDF)';

  @override
  String get uploading => 'Uploading...';

  @override
  String get uploadAndSave => 'Upload & Save';

  @override
  String get studentsPageSelectCourse => 'Select Course:';

  @override
  String get excusesTitle => 'Absence Excuses';

  @override
  String get excusesNoExcuses => 'No excuses submitted yet';

  @override
  String get excusesWithoutReason => 'No reason provided';

  @override
  String get excusesStatusSubmitted => 'Submitted';

  @override
  String get excusesReasonLabel => 'Reason';

  @override
  String get excusesViewAttachment => 'View Attachment';

  @override
  String get excusesApproved => '✅ Excuse approved successfully';

  @override
  String get excusesRejected => '✅ Excuse rejected successfully';

  @override
  String excusesErrorOccurred(String error) {
    return '❌ Error occurred: $error';
  }

  @override
  String get excusesFacultyMember => 'Faculty Member';

  @override
  String get classDetailTargetAudience => 'Target Audience';

  @override
  String get classDetailAffectedStudents => 'Affected';

  @override
  String get classDetailGroupA => 'Group A';

  @override
  String get classDetailGroupB => 'Group B';

  @override
  String get classDetailPostAnnouncement => 'Post Announcement Now';

  @override
  String classDetailStartChat(String name) {
    return 'Start direct chat with $name';
  }

  @override
  String classDetailUniversityId(String id) {
    return 'University ID: $id';
  }

  @override
  String classDetailLoadingError(String error) {
    return 'Loading error: $error';
  }

  @override
  String get classDetailNoTitle => 'No title';

  @override
  String get classDetailForum => 'Forum';

  @override
  String get classDetailViews => 'views';

  @override
  String get classDetailComments => 'comments';

  @override
  String classDetailDeleteError(String error) {
    return 'Error during deletion: $error';
  }

  @override
  String get profileDownloadingCard => 'Downloading university card...';

  @override
  String get profileDownloadingDecree => 'Downloading appointment decree...';

  @override
  String get settingsHelpLoading => 'Help center loading...';

  @override
  String settingsPrivacyPolicy(int year) {
    return 'University of Derna Privacy Policy $year';
  }

  @override
  String get settingsRoleFaculty =>
      'Associate Professor - College of Engineering';

  @override
  String get settingsRoleStaff => 'Honored Faculty Member';

  @override
  String get scheduleNotificationsEnabled =>
      'Schedule notifications are automatically enabled';

  @override
  String get scheduleNoLecturesToday => 'No lectures scheduled for today';

  @override
  String get dashboardWelcome => 'Welcome, Dr.';

  @override
  String get dashboardDoctorFallback => 'Doctor';

  @override
  String get dashboardCoursesTaught => 'Courses Taught';

  @override
  String get dashboardStudentCount => 'Student Count';

  @override
  String get dashboardWeeklyLectures => 'Weekly Lectures';

  @override
  String get dashboardQuickActions => 'Quick Actions';

  @override
  String get dashboardActionUploadLecture => 'Upload Lecture';

  @override
  String get dashboardActionUploadExam => 'Upload Exam';

  @override
  String get dashboardActionAddAssignment => 'Add Assignment';

  @override
  String get dashboardRecentActivity => 'Recent Activity';

  @override
  String get dashboardTodayLectures => 'Today\'s Lectures';

  @override
  String get dashboardNoLectures => 'No lectures scheduled for today';

  @override
  String get dashboardLoadError => 'Error loading lectures';

  @override
  String get dashboardGradesProgress => 'Grades Entry Progress';

  @override
  String get dashboardPeriodAM => 'AM';

  @override
  String get dashboardGradeReports => 'Grade Distribution Reports';

  @override
  String get dashboardAvgGrades => 'Average Grades';

  @override
  String get dashboardPassRate => 'Pass Rate';

  @override
  String get dashboardPendingRequests => 'Pending Requests';

  @override
  String get dashboardWeekSessions => 'Weekly Sessions';

  @override
  String get attendanceUploadMobileOnly =>
      'File upload requires the mobile app — under development';

  @override
  String get attendanceLoginRequired => 'You must be logged in first';

  @override
  String get attendanceNoPermission =>
      'You do not have permission to record attendance for this course';

  @override
  String assignmentsTotalStudents(int count) {
    return 'Total Students: $count';
  }

  @override
  String assignmentsOutOf(int total) {
    return 'of $total';
  }

  @override
  String get examTypeCourseOption => 'Course';

  @override
  String uploadFailedWithReason(String error) {
    return 'Error occurred during upload: $error';
  }

  @override
  String examUploadProgress(String progress) {
    return 'Uploading: $progress%';
  }

  @override
  String get periodMorning => 'Morning';

  @override
  String get periodAfternoon => 'Afternoon';

  @override
  String get dashboardViewAll => 'View All';

  @override
  String get imageUploadConfigMissing =>
      'Image upload configuration is missing';

  @override
  String imageUploadFailed(String error) {
    return 'Image upload failed: $error';
  }

  @override
  String get imageUploadRejected => 'Image upload rejected';

  @override
  String get imageUrlMissing => 'Image URL is missing';

  @override
  String get removeImageTitle => 'Remove Profile Photo';

  @override
  String get removeImageConfirm =>
      'Are you sure you want to remove your profile photo?';

  @override
  String get removeImageAction => 'Remove';
}
