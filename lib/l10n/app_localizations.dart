import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'University of Derna'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @twoFactor.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Auth'**
  String get twoFactor;

  /// No description provided for @comingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'This feature will be available in a future update.'**
  String get comingSoonBody;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @academicRecord.
  ///
  /// In en, this message translates to:
  /// **'Academic Record'**
  String get academicRecord;

  /// No description provided for @appWelcomeTag.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Academic Sanctuary'**
  String get appWelcomeTag;

  /// No description provided for @resultsGrades.
  ///
  /// In en, this message translates to:
  /// **'Results & Grades'**
  String get resultsGrades;

  /// No description provided for @digitalLibrary.
  ///
  /// In en, this message translates to:
  /// **'Digital Library'**
  String get digitalLibrary;

  /// No description provided for @universityEmail.
  ///
  /// In en, this message translates to:
  /// **'University Email'**
  String get universityEmail;

  /// No description provided for @documentRequest.
  ///
  /// In en, this message translates to:
  /// **'Document Request'**
  String get documentRequest;

  /// No description provided for @appMotto.
  ///
  /// In en, this message translates to:
  /// **'University of Derna: One Platform, Integrated Future'**
  String get appMotto;

  /// No description provided for @appWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Start your educational journey now and discover a world of knowledge and opportunities waiting for you at our leading university.'**
  String get appWelcomeBody;

  /// No description provided for @openHorizons.
  ///
  /// In en, this message translates to:
  /// **'Open Your Horizons Now'**
  String get openHorizons;

  /// No description provided for @termsContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get termsContinue;

  /// No description provided for @universityStats.
  ///
  /// In en, this message translates to:
  /// **'University Statistics'**
  String get universityStats;

  /// No description provided for @viewAndTrackAcademicPlan.
  ///
  /// In en, this message translates to:
  /// **'View and Track Academic Plan'**
  String get viewAndTrackAcademicPlan;

  /// No description provided for @studentsCount.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get studentsCount;

  /// No description provided for @collegesCount.
  ///
  /// In en, this message translates to:
  /// **'Academic Colleges'**
  String get collegesCount;

  /// No description provided for @facultyCount.
  ///
  /// In en, this message translates to:
  /// **'Faculty Members'**
  String get facultyCount;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @rightsReserved.
  ///
  /// In en, this message translates to:
  /// **'© 2026 University of Derna. All Rights Reserved.'**
  String get rightsReserved;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to access your university account'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the terms and access permissions'**
  String get agreeToTerms;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get createAccount;

  /// No description provided for @secureSystem.
  ///
  /// In en, this message translates to:
  /// **'University management system is fully protected and encrypted'**
  String get secureSystem;

  /// No description provided for @smartCollege.
  ///
  /// In en, this message translates to:
  /// **'Smart College'**
  String get smartCollege;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcomeBack(Object name);

  /// No description provided for @unspecifiedMajor.
  ///
  /// In en, this message translates to:
  /// **'Unspecified Major'**
  String get unspecifiedMajor;

  /// No description provided for @cumulativeGpa.
  ///
  /// In en, this message translates to:
  /// **'Cumulative GPA'**
  String get cumulativeGpa;

  /// No description provided for @completedHours.
  ///
  /// In en, this message translates to:
  /// **'Completed Hours'**
  String get completedHours;

  /// No description provided for @academicServices.
  ///
  /// In en, this message translates to:
  /// **'Academic Services'**
  String get academicServices;

  /// No description provided for @grades.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get grades;

  /// No description provided for @gradesTitle.
  ///
  /// In en, this message translates to:
  /// **'Results & Grades'**
  String get gradesTitle;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @noAttendanceData.
  ///
  /// In en, this message translates to:
  /// **'No attendance data yet'**
  String get noAttendanceData;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorLoadingGrades.
  ///
  /// In en, this message translates to:
  /// **'Error loading grades'**
  String get errorLoadingGrades;

  /// No description provided for @searchCourse.
  ///
  /// In en, this message translates to:
  /// **'Search for a course...'**
  String get searchCourse;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @undefinedSemester.
  ///
  /// In en, this message translates to:
  /// **'Undefined semester'**
  String get undefinedSemester;

  /// No description provided for @hoursEarned.
  ///
  /// In en, this message translates to:
  /// **'hours earned'**
  String get hoursEarned;

  /// No description provided for @coursesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Courses'**
  String coursesCount(Object count);

  /// No description provided for @gpaLabel.
  ///
  /// In en, this message translates to:
  /// **'Cumulative GPA'**
  String get gpaLabel;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No search results'**
  String get noSearchResults;

  /// No description provided for @noGradesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No grades recorded yet'**
  String get noGradesRecorded;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @finalExam.
  ///
  /// In en, this message translates to:
  /// **'Final Exam'**
  String get finalExam;

  /// No description provided for @midtermExam.
  ///
  /// In en, this message translates to:
  /// **'Midterm'**
  String get midtermExam;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @veryGood.
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get veryGood;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @acceptable.
  ///
  /// In en, this message translates to:
  /// **'Acceptable'**
  String get acceptable;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @latestNotifications.
  ///
  /// In en, this message translates to:
  /// **'Latest Notifications'**
  String get latestNotifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @loadingError.
  ///
  /// In en, this message translates to:
  /// **'Loading error'**
  String get loadingError;

  /// No description provided for @pleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please sign in'**
  String get pleaseLogin;

  /// No description provided for @dataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Data unavailable'**
  String get dataUnavailable;

  /// No description provided for @myStudy.
  ///
  /// In en, this message translates to:
  /// **'My Study'**
  String get myStudy;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get notificationsDisabled;

  /// No description provided for @showNotificationCenter.
  ///
  /// In en, this message translates to:
  /// **'Show Notification Center'**
  String get showNotificationCenter;

  /// No description provided for @accountAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account & Security'**
  String get accountAndSecurity;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @aboutUniversity.
  ///
  /// In en, this message translates to:
  /// **'About University'**
  String get aboutUniversity;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @technicalSupport.
  ///
  /// In en, this message translates to:
  /// **'Technical Support'**
  String get technicalSupport;

  /// No description provided for @faqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get faqs;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @languageAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto (System)'**
  String get languageAuto;

  /// No description provided for @languageAr.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageAr;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @agreeToTermsLabel.
  ///
  /// In en, this message translates to:
  /// **'I agree to terms and permissions'**
  String get agreeToTermsLabel;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmail;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name as registered in the college'**
  String get usernameTooShort;

  /// No description provided for @registrationNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Registration number is required'**
  String get registrationNumberRequired;

  /// No description provided for @invalidRegistrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Registration number must be 8 or 9 digits'**
  String get invalidRegistrationNumber;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your academic journey with us'**
  String get signUpSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name as registered'**
  String get fullNameHint;

  /// No description provided for @registrationNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Student ID (Registration Number)'**
  String get registrationNumberLabel;

  /// No description provided for @registrationNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 202100000'**
  String get registrationNumberHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get confirmPasswordHint;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signUpButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @legalAgreement.
  ///
  /// In en, this message translates to:
  /// **'By clicking \"Create Account\", you agree to the Terms of Service and Privacy Policy of the University of Derna.'**
  String get legalAgreement;

  /// No description provided for @signUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully! Welcome to the University of Derna.'**
  String get signUpSuccess;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to reset your password'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendButton;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email'**
  String get resetEmailSent;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'Email address not found'**
  String get userNotFound;

  /// No description provided for @defaultStudentName.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get defaultStudentName;

  /// No description provided for @defaultStudentEmail.
  ///
  /// In en, this message translates to:
  /// **'student@uod.edu.ly'**
  String get defaultStudentEmail;

  /// No description provided for @supportSubject.
  ///
  /// In en, this message translates to:
  /// **'Technical Support Request - University of Derna App'**
  String get supportSubject;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @userNotFoundMsg.
  ///
  /// In en, this message translates to:
  /// **'User data not found'**
  String get userNotFoundMsg;

  /// No description provided for @editProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile Photo'**
  String get editProfilePhoto;

  /// No description provided for @registrationNumberPrefix.
  ///
  /// In en, this message translates to:
  /// **'ID: '**
  String get registrationNumberPrefix;

  /// No description provided for @academicInfo.
  ///
  /// In en, this message translates to:
  /// **'Academic Information'**
  String get academicInfo;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfo;

  /// No description provided for @majorLabel.
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get majorLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get errorPrefix;

  /// No description provided for @earnedHours.
  ///
  /// In en, this message translates to:
  /// **'Earned Hours'**
  String get earnedHours;

  /// No description provided for @noGradesMsg.
  ///
  /// In en, this message translates to:
  /// **'No grades recorded yet'**
  String get noGradesMsg;

  /// No description provided for @semesterFallback.
  ///
  /// In en, this message translates to:
  /// **'Unspecified Semester'**
  String get semesterFallback;

  /// No description provided for @hoursSuffix.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hoursSuffix;

  /// No description provided for @finalExamLabel.
  ///
  /// In en, this message translates to:
  /// **'Final'**
  String get finalExamLabel;

  /// No description provided for @midtermLabel.
  ///
  /// In en, this message translates to:
  /// **'Midterm'**
  String get midtermLabel;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @pass.
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get pass;

  /// No description provided for @fail.
  ///
  /// In en, this message translates to:
  /// **'Fail'**
  String get fail;

  /// No description provided for @gradesError.
  ///
  /// In en, this message translates to:
  /// **'Error loading grades'**
  String get gradesError;

  /// No description provided for @attendanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance & Absences'**
  String get attendanceTitle;

  /// No description provided for @attendanceError.
  ///
  /// In en, this message translates to:
  /// **'Error loading attendance data'**
  String get attendanceError;

  /// No description provided for @noAttendanceMsg.
  ///
  /// In en, this message translates to:
  /// **'No attendance records yet'**
  String get noAttendanceMsg;

  /// No description provided for @totalAbsences.
  ///
  /// In en, this message translates to:
  /// **'Total Absences'**
  String get totalAbsences;

  /// No description provided for @totalAttendancePct.
  ///
  /// In en, this message translates to:
  /// **'Overall Attendance Rate'**
  String get totalAttendancePct;

  /// No description provided for @atRiskWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: {count} {count, plural, =1{course} other{courses}} at risk (attendance rate below 75%)'**
  String atRiskWarning(num count);

  /// No description provided for @atRiskBadge.
  ///
  /// In en, this message translates to:
  /// **'⚠️ At Risk'**
  String get atRiskBadge;

  /// No description provided for @totalLecturesLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} Total'**
  String totalLecturesLabel(Object count);

  /// No description provided for @attendedLecturesLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} Attended'**
  String attendedLecturesLabel(Object count);

  /// No description provided for @absencesLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} Absent'**
  String absencesLabel(Object count);

  /// No description provided for @scheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Academic Schedule'**
  String get scheduleTitle;

  /// No description provided for @noLecturesTitle.
  ///
  /// In en, this message translates to:
  /// **'No lectures for today'**
  String get noLecturesTitle;

  /// No description provided for @noLecturesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Data from local storage. Pull to refresh.'**
  String get noLecturesSubtitle;

  /// No description provided for @refreshAction.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshAction;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySunday;

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// No description provided for @currentSemesterTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Semester'**
  String get currentSemesterTitle;

  /// No description provided for @currentGpaLabel.
  ///
  /// In en, this message translates to:
  /// **'Current GPA'**
  String get currentGpaLabel;

  /// No description provided for @nextClassTitle.
  ///
  /// In en, this message translates to:
  /// **'Next Lecture'**
  String get nextClassTitle;

  /// No description provided for @quickAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get quickAccessTitle;

  /// No description provided for @fullScheduleLink.
  ///
  /// In en, this message translates to:
  /// **'Full Schedule'**
  String get fullScheduleLink;

  /// No description provided for @attendanceRecordLink.
  ///
  /// In en, this message translates to:
  /// **'Attendance Record'**
  String get attendanceRecordLink;

  /// No description provided for @gradesReportLink.
  ///
  /// In en, this message translates to:
  /// **'Grades Report'**
  String get gradesReportLink;

  /// No description provided for @departmentScientific.
  ///
  /// In en, this message translates to:
  /// **'Academic Department'**
  String get departmentScientific;

  /// No description provided for @majorAndTrack.
  ///
  /// In en, this message translates to:
  /// **'Major & Track'**
  String get majorAndTrack;

  /// No description provided for @collegeAffairs.
  ///
  /// In en, this message translates to:
  /// **'University Affairs'**
  String get collegeAffairs;

  /// No description provided for @branchMainName.
  ///
  /// In en, this message translates to:
  /// **'Main Campus (Al-Fataih)'**
  String get branchMainName;

  /// No description provided for @branchMainAddress.
  ///
  /// In en, this message translates to:
  /// **'Derna University - Al-Fataih District, Derna, Libya'**
  String get branchMainAddress;

  /// No description provided for @deanMainName.
  ///
  /// In en, this message translates to:
  /// **'Dr. Salem Mostafa Al-Osta'**
  String get deanMainName;

  /// No description provided for @deanMainTitle.
  ///
  /// In en, this message translates to:
  /// **'Dean of the Faculty of Engineering'**
  String get deanMainTitle;

  /// No description provided for @branchShihaName.
  ///
  /// In en, this message translates to:
  /// **'Derna University (Shiha Branch)'**
  String get branchShihaName;

  /// No description provided for @branchShihaAddress.
  ///
  /// In en, this message translates to:
  /// **'Shiha District - Derna, Libya'**
  String get branchShihaAddress;

  /// No description provided for @deanShihaName.
  ///
  /// In en, this message translates to:
  /// **'Dr. Abdulsalam Al-Haddad'**
  String get deanShihaName;

  /// No description provided for @deanShihaTitle.
  ///
  /// In en, this message translates to:
  /// **'Dean of the Faculty of Economics and Law'**
  String get deanShihaTitle;

  /// No description provided for @branchBabTobrukName.
  ///
  /// In en, this message translates to:
  /// **'Faculty of Medicine (Bab Tobruk)'**
  String get branchBabTobrukName;

  /// No description provided for @branchBabTobrukAddress.
  ///
  /// In en, this message translates to:
  /// **'Bab Tobruk District - Derna, Libya'**
  String get branchBabTobrukAddress;

  /// No description provided for @deanBabTobrukName.
  ///
  /// In en, this message translates to:
  /// **'Prof. Dr. Jamal Abdul Hamid Al-Hassadi'**
  String get deanBabTobrukName;

  /// No description provided for @deanBabTobrukTitle.
  ///
  /// In en, this message translates to:
  /// **'Dean of the Faculty of Human Medicine'**
  String get deanBabTobrukTitle;

  /// No description provided for @branchAlqubaName.
  ///
  /// In en, this message translates to:
  /// **'Derna University (Al-Quba)'**
  String get branchAlqubaName;

  /// No description provided for @branchAlqubaAddress.
  ///
  /// In en, this message translates to:
  /// **'Al-Quba - Libya'**
  String get branchAlqubaAddress;

  /// No description provided for @deanAlqubaName.
  ///
  /// In en, this message translates to:
  /// **'Mr. Zuhair Abdullah Gadallah'**
  String get deanAlqubaName;

  /// No description provided for @deanAlqubaTitle.
  ///
  /// In en, this message translates to:
  /// **'Dean of the Faculty of Engineering - Al-Quba Branch'**
  String get deanAlqubaTitle;

  /// No description provided for @announcementsAndLocation.
  ///
  /// In en, this message translates to:
  /// **'Announcements & Location'**
  String get announcementsAndLocation;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @noNotificationsSaved.
  ///
  /// In en, this message translates to:
  /// **'No saved notifications'**
  String get noNotificationsSaved;

  /// No description provided for @pullToRefreshSync.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh and sync with the server.'**
  String get pullToRefreshSync;

  /// No description provided for @notificationDefault.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationDefault;

  /// No description provided for @majorSoftwareEngineering.
  ///
  /// In en, this message translates to:
  /// **'Software Engineering'**
  String get majorSoftwareEngineering;

  /// No description provided for @collegeNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get collegeNews;

  /// No description provided for @collegeDepartments.
  ///
  /// In en, this message translates to:
  /// **'Departments'**
  String get collegeDepartments;

  /// No description provided for @departmentInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Academic Department'**
  String get departmentInfoTitle;

  /// No description provided for @academicAdvisorTitle.
  ///
  /// In en, this message translates to:
  /// **'Academic Advisor'**
  String get academicAdvisorTitle;

  /// No description provided for @departmentNewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Department News & Events'**
  String get departmentNewsTitle;

  /// No description provided for @collegeItSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Faculty of Information Technology — University of Derna'**
  String get collegeItSubtitle;

  /// No description provided for @advisorNameSample.
  ///
  /// In en, this message translates to:
  /// **'Dr. Ahmed Al-Obaidi'**
  String get advisorNameSample;

  /// No description provided for @advisorRoleSample.
  ///
  /// In en, this message translates to:
  /// **'Level 3 Academic Advisor'**
  String get advisorRoleSample;

  /// No description provided for @newsResearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Research project registration is open'**
  String get newsResearchTitle;

  /// No description provided for @newsResearchDate.
  ///
  /// In en, this message translates to:
  /// **'2 days ago'**
  String get newsResearchDate;

  /// No description provided for @newsResearchDescription.
  ///
  /// In en, this message translates to:
  /// **'Registration for research projects is now open for the current semester. Interested students are requested to submit their proposals before the deadline set by the department.'**
  String get newsResearchDescription;

  /// No description provided for @newsAiSeminarTitle.
  ///
  /// In en, this message translates to:
  /// **'Seminar: AI in education'**
  String get newsAiSeminarTitle;

  /// No description provided for @newsAiSeminarDate.
  ///
  /// In en, this message translates to:
  /// **'4 days ago'**
  String get newsAiSeminarDate;

  /// No description provided for @newsAiSeminarDescription.
  ///
  /// In en, this message translates to:
  /// **'The college is organizing a scientific seminar on the latest applications of artificial intelligence in the education field, with the attendance of a group of experts and specialized academics.'**
  String get newsAiSeminarDescription;

  /// No description provided for @newsExamsTitle.
  ///
  /// In en, this message translates to:
  /// **'Final exam schedule updated'**
  String get newsExamsTitle;

  /// No description provided for @newsExamsDate.
  ///
  /// In en, this message translates to:
  /// **'1 week ago'**
  String get newsExamsDate;

  /// No description provided for @newsExamsDescription.
  ///
  /// In en, this message translates to:
  /// **'The final exam schedule for the current semester has been updated. Please review the new schedule and ensure your exam dates in all subjects.'**
  String get newsExamsDescription;

  /// No description provided for @collegeAnnouncementsTitle.
  ///
  /// In en, this message translates to:
  /// **'College Announcements'**
  String get collegeAnnouncementsTitle;

  /// No description provided for @collegeLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'College Location'**
  String get collegeLocationTitle;

  /// No description provided for @deanOfficeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dean\'s Office'**
  String get deanOfficeTitle;

  /// No description provided for @graduationAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Important: upcoming graduation ceremony'**
  String get graduationAlertTitle;

  /// No description provided for @graduationAlertBody.
  ///
  /// In en, this message translates to:
  /// **'The graduation ceremony will be held at the end of this month in the main university auditorium.'**
  String get graduationAlertBody;

  /// No description provided for @openInteractiveMap.
  ///
  /// In en, this message translates to:
  /// **'Open interactive map'**
  String get openInteractiveMap;

  /// No description provided for @deanNameSample.
  ///
  /// In en, this message translates to:
  /// **'Dr. Zuhair Abdullah'**
  String get deanNameSample;

  /// No description provided for @deanTitleSample.
  ///
  /// In en, this message translates to:
  /// **'Dean, Faculty of Engineering – Al-Quba Branch'**
  String get deanTitleSample;

  /// No description provided for @contactCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get contactCall;

  /// No description provided for @contactMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get contactMessage;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get contactEmail;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error'**
  String get authError;

  /// No description provided for @studentPortal.
  ///
  /// In en, this message translates to:
  /// **'Student Portal'**
  String get studentPortal;

  /// No description provided for @facultyPortal.
  ///
  /// In en, this message translates to:
  /// **'Faculty Portal'**
  String get facultyPortal;

  /// No description provided for @adminPortal.
  ///
  /// In en, this message translates to:
  /// **'Admin Portal'**
  String get adminPortal;

  /// No description provided for @studentPortalDesc.
  ///
  /// In en, this message translates to:
  /// **'Courses, grades, schedules, and academic services'**
  String get studentPortalDesc;

  /// No description provided for @facultyPortalDesc.
  ///
  /// In en, this message translates to:
  /// **'Lectures, assessment, attendance, and assignments'**
  String get facultyPortalDesc;

  /// No description provided for @adminPortalDesc.
  ///
  /// In en, this message translates to:
  /// **'Settings, users, security, and reports'**
  String get adminPortalDesc;

  /// No description provided for @gatewayUniversityBadge.
  ///
  /// In en, this message translates to:
  /// **'University of Derna'**
  String get gatewayUniversityBadge;

  /// No description provided for @gatewayMainTitle.
  ///
  /// In en, this message translates to:
  /// **'UOD Smart Portal'**
  String get gatewayMainTitle;

  /// No description provided for @gatewaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'An integrated digital platform for the university community'**
  String get gatewaySubtitle;

  /// No description provided for @portalEnterStudent.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get portalEnterStudent;

  /// No description provided for @portalEnterFaculty.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get portalEnterFaculty;

  /// No description provided for @portalEnterAdmin.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get portalEnterAdmin;

  /// No description provided for @guestPortalDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get guestPortalDivider;

  /// No description provided for @guestPortalEnter.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get guestPortalEnter;

  /// No description provided for @softwareEngineering.
  ///
  /// In en, this message translates to:
  /// **'Software Engineering'**
  String get softwareEngineering;

  /// No description provided for @adminControlCenter.
  ///
  /// In en, this message translates to:
  /// **'Command & Control Center'**
  String get adminControlCenter;

  /// No description provided for @adminVerifyAccounts.
  ///
  /// In en, this message translates to:
  /// **'Account verification queue'**
  String get adminVerifyAccounts;

  /// No description provided for @userManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'User management'**
  String get userManagementTitle;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @facultyPortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Faculty Portal'**
  String get facultyPortalTitle;

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'University of Derna App'**
  String get appName;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Sign in button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up button
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Arabic language option
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Validation error for required fields
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String errorRequired(String field);

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get errorInvalidEmail;

  /// Password length error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get errorPasswordLength;

  /// Password mismatch error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errorPasswordMatch;

  /// Registration success
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get successAccountCreated;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get noDataFound;

  /// No description provided for @smartTimetableTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Timetable'**
  String get smartTimetableTitle;

  /// No description provided for @advancedProgrammingSubject.
  ///
  /// In en, this message translates to:
  /// **'Advanced Programming'**
  String get advancedProgrammingSubject;

  /// No description provided for @room101Time.
  ///
  /// In en, this message translates to:
  /// **'Room 101 - 8:00 AM to 10:00 AM'**
  String get room101Time;

  /// No description provided for @databaseSubject.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get databaseSubject;

  /// No description provided for @lab3Time.
  ///
  /// In en, this message translates to:
  /// **'Lab 3 - 10:30 AM to 12:30 PM'**
  String get lab3Time;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @lastUpdateLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Update'**
  String get lastUpdateLabel;

  /// No description provided for @may2024.
  ///
  /// In en, this message translates to:
  /// **'June 2026'**
  String get may2024;

  /// No description provided for @developerLabel.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developerLabel;

  /// No description provided for @itDepartmentDerna.
  ///
  /// In en, this message translates to:
  /// **'Eng. Amro Khaled Al-Shalwi'**
  String get itDepartmentDerna;

  /// No description provided for @developerEmail.
  ///
  /// In en, this message translates to:
  /// **'eng.amro@uod.edu.ly'**
  String get developerEmail;

  /// No description provided for @aboutAppDescription.
  ///
  /// In en, this message translates to:
  /// **'The University of Derna app aims to facilitate student access to academic and administrative services through an integrated platform, striving towards comprehensive digital transformation.'**
  String get aboutAppDescription;

  /// No description provided for @authPasswordStrengthWeakest.
  ///
  /// In en, this message translates to:
  /// **'Very Weak'**
  String get authPasswordStrengthWeakest;

  /// No description provided for @authPasswordStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get authPasswordStrengthWeak;

  /// No description provided for @authPasswordStrengthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get authPasswordStrengthFair;

  /// No description provided for @authPasswordStrengthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get authPasswordStrengthGood;

  /// No description provided for @authPasswordStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong ✓'**
  String get authPasswordStrengthStrong;

  /// No description provided for @authFullNameArabic.
  ///
  /// In en, this message translates to:
  /// **'Full Name (Arabic)'**
  String get authFullNameArabic;

  /// No description provided for @authFullNameEnglish.
  ///
  /// In en, this message translates to:
  /// **'Full Name (English)'**
  String get authFullNameEnglish;

  /// No description provided for @authNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get authNationalId;

  /// No description provided for @authPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get authPhoneNumber;

  /// No description provided for @authDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get authDateOfBirth;

  /// No description provided for @authGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get authGender;

  /// No description provided for @authGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get authGenderMale;

  /// No description provided for @authGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get authGenderFemale;

  /// No description provided for @authCollege.
  ///
  /// In en, this message translates to:
  /// **'College'**
  String get authCollege;

  /// No description provided for @authDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get authDepartment;

  /// No description provided for @authStudentId.
  ///
  /// In en, this message translates to:
  /// **'Student ID'**
  String get authStudentId;

  /// No description provided for @authErrorNameArabicRequired.
  ///
  /// In en, this message translates to:
  /// **'Arabic name is required'**
  String get authErrorNameArabicRequired;

  /// No description provided for @authErrorNameEnglishRequired.
  ///
  /// In en, this message translates to:
  /// **'English name is required'**
  String get authErrorNameEnglishRequired;

  /// No description provided for @authErrorNameArabicOnly.
  ///
  /// In en, this message translates to:
  /// **'Arabic name must contain Arabic characters only.'**
  String get authErrorNameArabicOnly;

  /// No description provided for @authErrorNameEnglishOnly.
  ///
  /// In en, this message translates to:
  /// **'English name must contain English characters only.'**
  String get authErrorNameEnglishOnly;

  /// No description provided for @authErrorNationalIdRequired.
  ///
  /// In en, this message translates to:
  /// **'National ID is required'**
  String get authErrorNationalIdRequired;

  /// No description provided for @authErrorNationalIdFormat.
  ///
  /// In en, this message translates to:
  /// **'National ID must be 12 digits'**
  String get authErrorNationalIdFormat;

  /// No description provided for @authErrorPhoneFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get authErrorPhoneFormat;

  /// No description provided for @authErrorTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'You must agree to the terms'**
  String get authErrorTermsRequired;

  /// No description provided for @authErrorCollegeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a college'**
  String get authErrorCollegeRequired;

  /// No description provided for @authTermsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get authTermsAndConditions;

  /// No description provided for @authAgreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the'**
  String get authAgreeToTerms;

  /// No description provided for @authPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authPrivacyPolicy;

  /// No description provided for @authStepPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get authStepPersonalInfo;

  /// No description provided for @authStepAcademicInfo.
  ///
  /// In en, this message translates to:
  /// **'Academic Information'**
  String get authStepAcademicInfo;

  /// No description provided for @authStepAccountSetup.
  ///
  /// In en, this message translates to:
  /// **'Account Setup'**
  String get authStepAccountSetup;

  /// No description provided for @authStepNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get authStepNext;

  /// No description provided for @authStepPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get authStepPrevious;

  /// No description provided for @authStepSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get authStepSubmit;

  /// No description provided for @authRegistrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration submitted successfully'**
  String get authRegistrationSuccess;

  /// No description provided for @authRegistrationPending.
  ///
  /// In en, this message translates to:
  /// **'Your application is under review'**
  String get authRegistrationPending;

  /// No description provided for @authVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get authVerificationSent;

  /// No description provided for @authWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'UOD Smart Portal'**
  String get authWelcomeTitle;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get authWelcomeSubtitle;

  /// No description provided for @authRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get authRememberMe;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// No description provided for @authLoginAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Central System Administration'**
  String get authLoginAdminTitle;

  /// No description provided for @authLoginFacultyTitle.
  ///
  /// In en, this message translates to:
  /// **'Faculty Portal'**
  String get authLoginFacultyTitle;

  /// No description provided for @authLoginAdminSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter authorized credentials'**
  String get authLoginAdminSubtitle;

  /// No description provided for @authLoginFacultySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your academic portal'**
  String get authLoginFacultySubtitle;

  /// No description provided for @authLoginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'example@uod.edu.ly'**
  String get authLoginEmailHint;

  /// No description provided for @authStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get authStepReview;

  /// No description provided for @authErrorDateOfBirthRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select date of birth'**
  String get authErrorDateOfBirthRequired;

  /// No description provided for @authRegistrationScorePrefix.
  ///
  /// In en, this message translates to:
  /// **'Preliminary score:'**
  String get authRegistrationScorePrefix;

  /// No description provided for @authRegistrationStatus.
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get authRegistrationStatus;

  /// No description provided for @authRegistrationFinalDecision.
  ///
  /// In en, this message translates to:
  /// **'You will be notified of the final decision via email within 3-5 business days.'**
  String get authRegistrationFinalDecision;

  /// No description provided for @authSubmitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get authSubmitRequest;

  /// No description provided for @authHintFullNameArabic.
  ///
  /// In en, this message translates to:
  /// **'Mohammed Ahmed Ali Mohammed'**
  String get authHintFullNameArabic;

  /// No description provided for @authHintFullNameEnglish.
  ///
  /// In en, this message translates to:
  /// **'Mohammed Ahmed Ali'**
  String get authHintFullNameEnglish;

  /// No description provided for @authHintPhone.
  ///
  /// In en, this message translates to:
  /// **'+218910000000'**
  String get authHintPhone;

  /// No description provided for @authHintNationalId.
  ///
  /// In en, this message translates to:
  /// **'123456789012'**
  String get authHintNationalId;

  /// No description provided for @authSelectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Select Date of Birth'**
  String get authSelectDateOfBirth;

  /// No description provided for @authErrorGenderRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a gender'**
  String get authErrorGenderRequired;

  /// No description provided for @authErrorDepartmentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a department'**
  String get authErrorDepartmentRequired;

  /// No description provided for @authHintSelectCollegeFirst.
  ///
  /// In en, this message translates to:
  /// **'Select college first'**
  String get authHintSelectCollegeFirst;

  /// No description provided for @authHintSelectDepartment.
  ///
  /// In en, this message translates to:
  /// **'Select department'**
  String get authHintSelectDepartment;

  /// No description provided for @authSemester.
  ///
  /// In en, this message translates to:
  /// **'Semester'**
  String get authSemester;

  /// No description provided for @authErrorSemesterRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a semester'**
  String get authErrorSemesterRequired;

  /// No description provided for @authExpectedGraduationYear.
  ///
  /// In en, this message translates to:
  /// **'Expected Graduation Year'**
  String get authExpectedGraduationYear;

  /// No description provided for @authSecondaryGpa.
  ///
  /// In en, this message translates to:
  /// **'Secondary School GPA (0 - 100)'**
  String get authSecondaryGpa;

  /// No description provided for @authHintSecondaryGpa.
  ///
  /// In en, this message translates to:
  /// **'Example: 85.5'**
  String get authHintSecondaryGpa;

  /// No description provided for @authErrorSecondaryGpaRequired.
  ///
  /// In en, this message translates to:
  /// **'GPA is required'**
  String get authErrorSecondaryGpaRequired;

  /// No description provided for @authErrorSecondaryGpaRange.
  ///
  /// In en, this message translates to:
  /// **'Enter a number between 0 and 100'**
  String get authErrorSecondaryGpaRange;

  /// No description provided for @authCertificateType.
  ///
  /// In en, this message translates to:
  /// **'Certificate Type'**
  String get authCertificateType;

  /// No description provided for @authErrorCertificateRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a certificate type'**
  String get authErrorCertificateRequired;

  /// No description provided for @authErrorPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get authErrorPasswordLength;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPassword;

  /// No description provided for @authErrorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authErrorPasswordMismatch;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account data not found'**
  String get authErrorAccountNotFound;

  /// No description provided for @authErrorPortalMismatch.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized for this portal'**
  String get authErrorPortalMismatch;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorNetworkFailed.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection'**
  String get authErrorNetworkFailed;

  /// No description provided for @authErrorRoleMismatch.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized for this portal'**
  String get authErrorRoleMismatch;

  /// No description provided for @authErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account data not found'**
  String get authErrorUserNotFound;

  /// No description provided for @authReviewData.
  ///
  /// In en, this message translates to:
  /// **'Review Data'**
  String get authReviewData;

  /// No description provided for @authLabelFullNameArabic.
  ///
  /// In en, this message translates to:
  /// **'Name (Arabic)'**
  String get authLabelFullNameArabic;

  /// No description provided for @authLabelFullNameEnglish.
  ///
  /// In en, this message translates to:
  /// **'Name (English)'**
  String get authLabelFullNameEnglish;

  /// No description provided for @authLabelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authLabelEmail;

  /// No description provided for @authLabelPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get authLabelPhone;

  /// No description provided for @authLabelNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get authLabelNationalId;

  /// No description provided for @authLabelGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get authLabelGender;

  /// No description provided for @authLabelCollege.
  ///
  /// In en, this message translates to:
  /// **'College'**
  String get authLabelCollege;

  /// No description provided for @authLabelDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get authLabelDepartment;

  /// No description provided for @authLabelSemester.
  ///
  /// In en, this message translates to:
  /// **'Semester'**
  String get authLabelSemester;

  /// No description provided for @authLabelGraduationYear.
  ///
  /// In en, this message translates to:
  /// **'Graduation Year'**
  String get authLabelGraduationYear;

  /// No description provided for @authLabelGpa.
  ///
  /// In en, this message translates to:
  /// **'GPA'**
  String get authLabelGpa;

  /// No description provided for @authLabelCertificateType.
  ///
  /// In en, this message translates to:
  /// **'Certificate Type'**
  String get authLabelCertificateType;

  /// No description provided for @authAgreeToTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'I agree to Terms of Service'**
  String get authAgreeToTermsOfService;

  /// No description provided for @authAgreeToPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'I agree to Privacy Policy'**
  String get authAgreeToPrivacyPolicy;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Night Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Application Language'**
  String get settingsLanguage;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'System Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotifEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get settingsNotifEnabled;

  /// No description provided for @settingsNotifGrades.
  ///
  /// In en, this message translates to:
  /// **'Grade Updates'**
  String get settingsNotifGrades;

  /// No description provided for @settingsNotifAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get settingsNotifAnnouncements;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get settingsAccount;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Help Center & FAQs'**
  String get settingsHelp;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About University Portal'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get settingsLogoutConfirm;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditTitle;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profilePersonalInfo;

  /// No description provided for @profileAcademicInfo.
  ///
  /// In en, this message translates to:
  /// **'Academic Information'**
  String get profileAcademicInfo;

  /// No description provided for @profileContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get profileContactInfo;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileFullName;

  /// No description provided for @profileStudentId.
  ///
  /// In en, this message translates to:
  /// **'Student ID'**
  String get profileStudentId;

  /// No description provided for @profileCollege.
  ///
  /// In en, this message translates to:
  /// **'College'**
  String get profileCollege;

  /// No description provided for @profileDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get profileDepartment;

  /// No description provided for @profileLevel.
  ///
  /// In en, this message translates to:
  /// **'Academic Level'**
  String get profileLevel;

  /// No description provided for @profileGpa.
  ///
  /// In en, this message translates to:
  /// **'GPA'**
  String get profileGpa;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profilePhone;

  /// No description provided for @profileAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get profileAddress;

  /// No description provided for @profileSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profileSaveChanges;

  /// No description provided for @profileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get profileChangePhoto;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdateSuccess;

  /// No description provided for @profileUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get profileUpdateError;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get changePasswordCurrent;

  /// No description provided for @changePasswordNew.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get changePasswordNew;

  /// No description provided for @changePasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get changePasswordConfirm;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get changePasswordSuccess;

  /// No description provided for @changePasswordErrorWrong.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get changePasswordErrorWrong;

  /// No description provided for @changePasswordErrorSame.
  ///
  /// In en, this message translates to:
  /// **'New password must differ from current'**
  String get changePasswordErrorSame;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get privacyPolicyLastUpdated;

  /// No description provided for @privacyPolicyDataUsage.
  ///
  /// In en, this message translates to:
  /// **'Data Usage'**
  String get privacyPolicyDataUsage;

  /// No description provided for @privacyPolicyContact.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get privacyPolicyContact;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmpty;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get notificationsClearAll;

  /// No description provided for @notificationsNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get notificationsNew;

  /// No description provided for @notificationsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notificationsToday;

  /// No description provided for @notificationsYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notificationsYesterday;

  /// No description provided for @notificationsEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notificationsEarlier;

  /// No description provided for @settingsAllFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get settingsAllFieldsRequired;

  /// No description provided for @settingsChangePasswordError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while changing the password'**
  String get settingsChangePasswordError;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportTitle;

  /// No description provided for @supportFormSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the form below and we will contact you soon.'**
  String get supportFormSubtitle;

  /// No description provided for @supportName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get supportName;

  /// No description provided for @supportSubjectField.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get supportSubjectField;

  /// No description provided for @supportMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get supportMessage;

  /// No description provided for @supportMessageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please write the message'**
  String get supportMessageRequired;

  /// No description provided for @supportNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get supportNameRequired;

  /// No description provided for @supportEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get supportEmailRequired;

  /// No description provided for @supportEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get supportEmailInvalid;

  /// No description provided for @supportSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent successfully'**
  String get supportSent;

  /// No description provided for @supportSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get supportSend;

  /// No description provided for @privacyPolicyHeadingInfo.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy for College of Technical Sciences – Derna'**
  String get privacyPolicyHeadingInfo;

  /// No description provided for @privacyPolicyIntro.
  ///
  /// In en, this message translates to:
  /// **'The College of Technical Sciences Derna is committed to protecting the privacy of its app users and maintaining the confidentiality of their personal data. This policy explains how information provided by students, faculty, and all users is collected, used, and protected.'**
  String get privacyPolicyIntro;

  /// No description provided for @privacyPolicyCollectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Information We Collect:'**
  String get privacyPolicyCollectedTitle;

  /// No description provided for @privacyPolicyCollectedBody.
  ///
  /// In en, this message translates to:
  /// **'- Personal data such as name, registration number, email.\n- Interaction data with the app and provided services.\n- Device information and usage preferences.'**
  String get privacyPolicyCollectedBody;

  /// No description provided for @privacyPolicyUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'How We Use Information:'**
  String get privacyPolicyUsageTitle;

  /// No description provided for @privacyPolicyUsageBody.
  ///
  /// In en, this message translates to:
  /// **'The College of Technical Sciences Derna uses this information to improve services, ensure effective communication with users, and provide technical support when needed.'**
  String get privacyPolicyUsageBody;

  /// No description provided for @privacyPolicyProtectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Protection:'**
  String get privacyPolicyProtectionTitle;

  /// No description provided for @privacyPolicyProtectionBody.
  ///
  /// In en, this message translates to:
  /// **'The college is committed to taking all necessary technical and administrative measures to protect user data from unauthorized access, modification, or disclosure.'**
  String get privacyPolicyProtectionBody;

  /// No description provided for @privacyPolicySharingTitle.
  ///
  /// In en, this message translates to:
  /// **'Sharing Information with Third Parties:'**
  String get privacyPolicySharingTitle;

  /// No description provided for @privacyPolicySharingBody.
  ///
  /// In en, this message translates to:
  /// **'The College of Technical Sciences Derna does not sell or share user data with any external party except where required by law or with the user\'s consent.'**
  String get privacyPolicySharingBody;

  /// No description provided for @privacyPolicyAmendmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Amendments to the Privacy Policy:'**
  String get privacyPolicyAmendmentsTitle;

  /// No description provided for @privacyPolicyAmendmentsBody.
  ///
  /// In en, this message translates to:
  /// **'The college may update this policy from time to time. Users will be notified of any material changes through the app or via appropriate communication channels.'**
  String get privacyPolicyAmendmentsBody;

  /// No description provided for @privacyPolicySocialTitle.
  ///
  /// In en, this message translates to:
  /// **'To contact the college via social media, use the buttons below:'**
  String get privacyPolicySocialTitle;

  /// No description provided for @privacyPolicyEmailError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while opening the email app'**
  String get privacyPolicyEmailError;

  /// No description provided for @adminDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Control Center'**
  String get adminDashboardTitle;

  /// No description provided for @adminDashboardWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Central Control Unit'**
  String get adminDashboardWelcome;

  /// No description provided for @adminDashboardStatusSafe.
  ///
  /// In en, this message translates to:
  /// **'System Status: Secure & Connected'**
  String get adminDashboardStatusSafe;

  /// No description provided for @adminDashboardLiveAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Live Data Analysis'**
  String get adminDashboardLiveAnalysis;

  /// No description provided for @adminDashboardTotalRecords.
  ///
  /// In en, this message translates to:
  /// **'Total Records'**
  String get adminDashboardTotalRecords;

  /// No description provided for @adminDashboardPendingReqs.
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get adminDashboardPendingReqs;

  /// No description provided for @adminDashboardApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get adminDashboardApproved;

  /// No description provided for @adminDashboardRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get adminDashboardRejected;

  /// No description provided for @adminDashboardActiveUsers.
  ///
  /// In en, this message translates to:
  /// **'Active Users'**
  String get adminDashboardActiveUsers;

  /// No description provided for @adminDashboardTotalStudents.
  ///
  /// In en, this message translates to:
  /// **'Total Students'**
  String get adminDashboardTotalStudents;

  /// No description provided for @adminDashboardQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Control Units'**
  String get adminDashboardQuickActions;

  /// No description provided for @adminDashboardSystemLogs.
  ///
  /// In en, this message translates to:
  /// **'System Logs (Logs)'**
  String get adminDashboardSystemLogs;

  /// No description provided for @adminDashboardUserMgmt.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get adminDashboardUserMgmt;

  /// No description provided for @adminDashboardVerifQueue.
  ///
  /// In en, this message translates to:
  /// **'Registration Requests'**
  String get adminDashboardVerifQueue;

  /// No description provided for @adminDashboardDrawerTitle.
  ///
  /// In en, this message translates to:
  /// **'Central System Administration'**
  String get adminDashboardDrawerTitle;

  /// No description provided for @adminDashboardDrawerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get adminDashboardDrawerDashboard;

  /// No description provided for @adminDashboardDrawerRegistrations.
  ///
  /// In en, this message translates to:
  /// **'Registration Requests'**
  String get adminDashboardDrawerRegistrations;

  /// No description provided for @adminDashboardDrawerEndSession.
  ///
  /// In en, this message translates to:
  /// **'End Session'**
  String get adminDashboardDrawerEndSession;

  /// No description provided for @adminDashboardErrorText.
  ///
  /// In en, this message translates to:
  /// **'System error occurred'**
  String get adminDashboardErrorText;

  /// No description provided for @verifQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Queue'**
  String get verifQueueTitle;

  /// No description provided for @verifQueueTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get verifQueueTabAll;

  /// No description provided for @verifQueueTabPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get verifQueueTabPending;

  /// No description provided for @verifQueueTabUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get verifQueueTabUnderReview;

  /// No description provided for @verifQueueTabRequiresInfo.
  ///
  /// In en, this message translates to:
  /// **'Additional Review'**
  String get verifQueueTabRequiresInfo;

  /// No description provided for @verifQueueEmpty.
  ///
  /// In en, this message translates to:
  /// **'No applications in this queue'**
  String get verifQueueEmpty;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @verifQueueApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get verifQueueApprove;

  /// No description provided for @verifQueueReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get verifQueueReject;

  /// No description provided for @verifQueueApproveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Approval'**
  String get verifQueueApproveConfirm;

  /// No description provided for @verifQueueRejectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Rejection'**
  String get verifQueueRejectConfirm;

  /// No description provided for @verifQueueApproveMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to approve this application?'**
  String get verifQueueApproveMsg;

  /// No description provided for @verifQueueRejectMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this application?'**
  String get verifQueueRejectMsg;

  /// No description provided for @verifQueueRejectReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get verifQueueRejectReason;

  /// No description provided for @verifQueueRejectReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the reason'**
  String get verifQueueRejectReasonHint;

  /// No description provided for @verifQueueRejectCustomHint.
  ///
  /// In en, this message translates to:
  /// **'Write the reason...'**
  String get verifQueueRejectCustomHint;

  /// No description provided for @verifQueueOtherReason.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get verifQueueOtherReason;

  /// No description provided for @verifQueueScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get verifQueueScore;

  /// No description provided for @verifQueueApplicantName.
  ///
  /// In en, this message translates to:
  /// **'Applicant'**
  String get verifQueueApplicantName;

  /// No description provided for @verifQueueCollege.
  ///
  /// In en, this message translates to:
  /// **'College'**
  String get verifQueueCollege;

  /// No description provided for @verifQueueSubmittedDate.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get verifQueueSubmittedDate;

  /// No description provided for @verifQueueApproveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Application approved successfully'**
  String get verifQueueApproveSuccess;

  /// No description provided for @verifQueueRejectSuccess.
  ///
  /// In en, this message translates to:
  /// **'Application rejected'**
  String get verifQueueRejectSuccess;

  /// No description provided for @verifQueueErrorAction.
  ///
  /// In en, this message translates to:
  /// **'Failed to process application'**
  String get verifQueueErrorAction;

  /// No description provided for @verifQueueYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get verifQueueYes;

  /// No description provided for @verifQueueNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get verifQueueNo;

  /// No description provided for @verifQueueConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get verifQueueConfirmTitle;

  /// No description provided for @verifQueueFieldNameEn.
  ///
  /// In en, this message translates to:
  /// **'Name (English)'**
  String get verifQueueFieldNameEn;

  /// No description provided for @verifQueueFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get verifQueueFieldEmail;

  /// No description provided for @verifQueueFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get verifQueueFieldPhone;

  /// No description provided for @verifQueueFieldNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get verifQueueFieldNationalId;

  /// No description provided for @verifQueueFieldGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get verifQueueFieldGender;

  /// No description provided for @verifQueueFieldSemester.
  ///
  /// In en, this message translates to:
  /// **'Semester'**
  String get verifQueueFieldSemester;

  /// No description provided for @verifQueueFieldGpa.
  ///
  /// In en, this message translates to:
  /// **'GPA'**
  String get verifQueueFieldGpa;

  /// No description provided for @verifQueueFieldGraduationYear.
  ///
  /// In en, this message translates to:
  /// **'Graduation Year'**
  String get verifQueueFieldGraduationYear;

  /// No description provided for @systemLogsTitle.
  ///
  /// In en, this message translates to:
  /// **'System Logs'**
  String get systemLogsTitle;

  /// No description provided for @systemLogsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No activity logs yet'**
  String get systemLogsEmpty;

  /// No description provided for @systemLogsErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load logs'**
  String get systemLogsErrorLoad;

  /// No description provided for @systemLogsActionApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved Account'**
  String get systemLogsActionApproved;

  /// No description provided for @systemLogsActionRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected Account'**
  String get systemLogsActionRejected;

  /// No description provided for @systemLogsActionOther.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get systemLogsActionOther;

  /// No description provided for @systemLogsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get systemLogsAdmin;

  /// No description provided for @systemLogsTarget.
  ///
  /// In en, this message translates to:
  /// **'Target User'**
  String get systemLogsTarget;

  /// No description provided for @systemLogsTimestamp.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get systemLogsTimestamp;

  /// No description provided for @systemLogsDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get systemLogsDetails;

  /// No description provided for @statusPendingFinalApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending Final Approval'**
  String get statusPendingFinalApproval;

  /// No description provided for @statusUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get statusUnderReview;

  /// No description provided for @statusRequiresAdditional.
  ///
  /// In en, this message translates to:
  /// **'Requires Additional Info'**
  String get statusRequiresAdditional;

  /// No description provided for @statusAutoRejected.
  ///
  /// In en, this message translates to:
  /// **'Auto Rejected'**
  String get statusAutoRejected;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get statusSuspended;

  /// No description provided for @rejectReasonInsufficientData.
  ///
  /// In en, this message translates to:
  /// **'Insufficient academic data'**
  String get rejectReasonInsufficientData;

  /// No description provided for @rejectReasonDocumentIssues.
  ///
  /// In en, this message translates to:
  /// **'Document issues'**
  String get rejectReasonDocumentIssues;

  /// No description provided for @rejectReasonDuplicateAccount.
  ///
  /// In en, this message translates to:
  /// **'Duplicate account'**
  String get rejectReasonDuplicateAccount;

  /// No description provided for @rejectReasonIncompleteInfo.
  ///
  /// In en, this message translates to:
  /// **'Incomplete information'**
  String get rejectReasonIncompleteInfo;

  /// No description provided for @rejectReasonCapacityFull.
  ///
  /// In en, this message translates to:
  /// **'Capacity full in major'**
  String get rejectReasonCapacityFull;

  /// No description provided for @rejectReasonAgeRequirement.
  ///
  /// In en, this message translates to:
  /// **'Age requirement not met'**
  String get rejectReasonAgeRequirement;

  /// No description provided for @pendingStatusTitlePending.
  ///
  /// In en, this message translates to:
  /// **'Your Application is Under Review'**
  String get pendingStatusTitlePending;

  /// No description provided for @pendingStatusTitleRejected.
  ///
  /// In en, this message translates to:
  /// **'Application Not Accepted'**
  String get pendingStatusTitleRejected;

  /// No description provided for @pendingStatusBodyPending.
  ///
  /// In en, this message translates to:
  /// **'Thank you for registering at the University of Derna. Your application is {status} and you will be notified of the final decision via email within 3-5 business days.'**
  String pendingStatusBodyPending(Object status);

  /// No description provided for @pendingStatusBodyRejected.
  ///
  /// In en, this message translates to:
  /// **'Your registration has been rejected. You can contact Admissions for more information.'**
  String get pendingStatusBodyRejected;

  /// No description provided for @pendingStatusRefresh.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get pendingStatusRefresh;

  /// No description provided for @pendingStatusSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get pendingStatusSignOut;

  /// No description provided for @pendingStatusContact.
  ///
  /// In en, this message translates to:
  /// **'For inquiries: admissions@uod.edu.ly'**
  String get pendingStatusContact;

  /// No description provided for @systemLogsSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemLogsSystem;

  /// Badge shown when admin system is online
  ///
  /// In en, this message translates to:
  /// **'SYSTEM ONLINE'**
  String get adminDashboardSystemOnline;

  /// Fallback when a value is not available
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notApplicable;

  /// Tooltip for syncing grades from portal
  ///
  /// In en, this message translates to:
  /// **'Sync from University Portal'**
  String get gradesSyncTooltip;

  /// Shown after successful sync with record count
  ///
  /// In en, this message translates to:
  /// **'Sync complete — {count} records'**
  String gradesSyncSuccess(int count);

  /// Shown when grades sync fails
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get gradesSyncFailed;

  /// Suffix for grade points
  ///
  /// In en, this message translates to:
  /// **'GP'**
  String get gradesGpSuffix;

  /// Title for fees page
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get feesTitle;

  /// Label for saved fee records
  ///
  /// In en, this message translates to:
  /// **'Saved Fee Records'**
  String get feesSavedRecords;

  /// Items count label
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get feesItems;

  /// Title for local fee records list
  ///
  /// In en, this message translates to:
  /// **'Fee Records (Local)'**
  String get feesLocalRecord;

  /// Message when no local fee records exist
  ///
  /// In en, this message translates to:
  /// **'No local fee data available'**
  String get feesEmpty;

  /// Default title fallback for a fee
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get feesDefaultTitle;

  /// Button to pay fees
  ///
  /// In en, this message translates to:
  /// **'Pay Outstanding Fees'**
  String get feesPayButton;

  /// Status label for paid fees
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get feesPaid;

  /// Status label for unpaid fees
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get feesUnpaid;

  /// My classes tab label
  ///
  /// In en, this message translates to:
  /// **'My Classes'**
  String get facultyMyClasses;

  /// Welcome message for faculty doctor
  ///
  /// In en, this message translates to:
  /// **'Welcome, Doctor'**
  String get facultyWelcome;

  /// Welcome subtitle for faculty
  ///
  /// In en, this message translates to:
  /// **'Wishing you a productive and distinguished semester.'**
  String get facultyWelcomeSubtitle;

  /// Academic stats overview title
  ///
  /// In en, this message translates to:
  /// **'Quick Academic Overview'**
  String get facultyAcademicOverview;

  /// Label for total students count
  ///
  /// In en, this message translates to:
  /// **'Enrolled Students'**
  String get facultyEnrolledStudents;

  /// Label for total courses count
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get facultyCourses;

  /// Attendance chart title
  ///
  /// In en, this message translates to:
  /// **'Weekly Course Attendance Rate'**
  String get facultyWeeklyAttendance;

  /// Shown when there are no courses
  ///
  /// In en, this message translates to:
  /// **'No courses available currently'**
  String get facultyNoCourses;

  /// Details for a course item
  ///
  /// In en, this message translates to:
  /// **'Dept. {dept} | Semester {sem}'**
  String facultyClassSub(String dept, String sem);

  /// Dropdown hint to select course
  ///
  /// In en, this message translates to:
  /// **'Select Course'**
  String get facultySelectCourse;

  /// Shown when courses fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading courses'**
  String get facultyErrorLoadingCourses;

  /// Placeholder before selecting a course
  ///
  /// In en, this message translates to:
  /// **'Please select a course to view students list'**
  String get facultySelectCourseForStudents;

  /// Empty state for class students list
  ///
  /// In en, this message translates to:
  /// **'No students found'**
  String get facultyNoStudents;

  /// Title for grades tab
  ///
  /// In en, this message translates to:
  /// **'Record Academic Grades'**
  String get facultyGradesTitle;

  /// Placeholder before selecting a course in grades
  ///
  /// In en, this message translates to:
  /// **'Please select a course to open grades sheet'**
  String get facultySelectCourseForGrades;

  /// Total score prefix label
  ///
  /// In en, this message translates to:
  /// **'Total: {score}'**
  String facultyTotalScorePrefix(double score);

  /// Label for midterm marks entry
  ///
  /// In en, this message translates to:
  /// **'Midterm (40)'**
  String get facultyMidtermLabel;

  /// Label for final marks entry
  ///
  /// In en, this message translates to:
  /// **'Final (40)'**
  String get facultyFinalLabel;

  /// Label for assignments marks entry
  ///
  /// In en, this message translates to:
  /// **'Assignments (20)'**
  String get facultyAssignmentsLabel;

  /// No description provided for @eRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'E-Requests Portal'**
  String get eRequestsTitle;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequests;

  /// No description provided for @noRequestsYet.
  ///
  /// In en, this message translates to:
  /// **'No requests submitted yet'**
  String get noRequestsYet;

  /// No description provided for @noRequestsDescription.
  ///
  /// In en, this message translates to:
  /// **'You can submit your electronic requests from the sections below'**
  String get noRequestsDescription;

  /// No description provided for @requestTypeGraduationCertificate.
  ///
  /// In en, this message translates to:
  /// **'Graduation Certificate'**
  String get requestTypeGraduationCertificate;

  /// No description provided for @requestTypeOfficialTranscript.
  ///
  /// In en, this message translates to:
  /// **'Official Transcript'**
  String get requestTypeOfficialTranscript;

  /// No description provided for @requestTypeSemesterDeferral.
  ///
  /// In en, this message translates to:
  /// **'Semester Deferral'**
  String get requestTypeSemesterDeferral;

  /// No description provided for @requestTypeMajorChange.
  ///
  /// In en, this message translates to:
  /// **'Major Change'**
  String get requestTypeMajorChange;

  /// No description provided for @requestStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get requestStatusPending;

  /// No description provided for @requestStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get requestStatusApproved;

  /// No description provided for @requestStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get requestStatusRejected;

  /// No description provided for @requestStatusReadyForPickup.
  ///
  /// In en, this message translates to:
  /// **'Ready for Pickup'**
  String get requestStatusReadyForPickup;

  /// Submit button text
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelRequest;

  /// No description provided for @cancelRequestConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this request?'**
  String get cancelRequestConfirm;

  /// No description provided for @cancelRequestWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get cancelRequestWarning;

  /// No description provided for @requestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Request submitted successfully'**
  String get requestSubmitted;

  /// No description provided for @requestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled'**
  String get requestCancelled;

  /// No description provided for @requestDetails.
  ///
  /// In en, this message translates to:
  /// **'Request Details'**
  String get requestDetails;

  /// No description provided for @requestTimeline.
  ///
  /// In en, this message translates to:
  /// **'Request Timeline'**
  String get requestTimeline;

  /// No description provided for @timelineSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get timelineSubmitted;

  /// No description provided for @timelineReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get timelineReview;

  /// No description provided for @timelineDecision.
  ///
  /// In en, this message translates to:
  /// **'Decision Made'**
  String get timelineDecision;

  /// No description provided for @timelineReady.
  ///
  /// In en, this message translates to:
  /// **'Ready for Pickup'**
  String get timelineReady;

  /// No description provided for @adminNote.
  ///
  /// In en, this message translates to:
  /// **'Admin Note'**
  String get adminNote;

  /// No description provided for @optionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get optionalNotes;

  /// No description provided for @numberOfCopies.
  ///
  /// In en, this message translates to:
  /// **'Number of Copies'**
  String get numberOfCopies;

  /// Arabic language name
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @semesterToDefer.
  ///
  /// In en, this message translates to:
  /// **'Semester to Defer'**
  String get semesterToDefer;

  /// No description provided for @reasonForRequest.
  ///
  /// In en, this message translates to:
  /// **'Reason for Request'**
  String get reasonForRequest;

  /// No description provided for @reasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Reason is required'**
  String get reasonRequired;

  /// No description provided for @newMajor.
  ///
  /// In en, this message translates to:
  /// **'Requested New Major'**
  String get newMajor;

  /// No description provided for @selectSemester.
  ///
  /// In en, this message translates to:
  /// **'Select Semester'**
  String get selectSemester;

  /// No description provided for @selectMajor.
  ///
  /// In en, this message translates to:
  /// **'Select Major'**
  String get selectMajor;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields and attach the exam paper'**
  String get validationError;

  /// No description provided for @requestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request submission failed'**
  String get requestFailed;

  /// No description provided for @pleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get pleaseTryAgain;

  /// No description provided for @eRequests.
  ///
  /// In en, this message translates to:
  /// **'E-Requests'**
  String get eRequests;

  /// Label for college campus location
  ///
  /// In en, this message translates to:
  /// **'Campus: {name}'**
  String collegeCampusLabel(String name);

  /// Derna campus name
  ///
  /// In en, this message translates to:
  /// **'Derna'**
  String get campusDerna;

  /// Al-Qubbah campus name
  ///
  /// In en, this message translates to:
  /// **'Al-Qubbah'**
  String get campusQubbah;

  /// Welcome message for a college
  ///
  /// In en, this message translates to:
  /// **'Welcome to {name}'**
  String collegeWelcomeTitle(String name);

  /// Welcome instructions on college homepage
  ///
  /// In en, this message translates to:
  /// **'College content, announcements, and departments are available from the tabs below.'**
  String get collegeWelcomeSubtitle;

  /// Fallback when college has no departments listed
  ///
  /// In en, this message translates to:
  /// **'No registered departments for this college yet.'**
  String get collegeNoDepartments;

  /// Header title for college news section
  ///
  /// In en, this message translates to:
  /// **'{name} News'**
  String collegeNewsTitle(String name);

  /// Label for academic announcements news
  ///
  /// In en, this message translates to:
  /// **'Academic Announcement'**
  String get collegeNewsAnnouncement;

  /// Label for general college news
  ///
  /// In en, this message translates to:
  /// **'College News'**
  String get collegeNewsLabel;

  /// Placeholder for offline/mock news
  ///
  /// In en, this message translates to:
  /// **'News will be connected to Firestore later.'**
  String get collegeNewsPlaceholder;

  /// The official university name
  ///
  /// In en, this message translates to:
  /// **'University of Derna'**
  String get universityName;

  /// Tooltip/text to switch to list view in guest portal
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get guestViewList;

  /// Tooltip/text to switch to grid view in guest portal
  ///
  /// In en, this message translates to:
  /// **'Grid View'**
  String get guestViewGrid;

  /// Placeholder inside search bar
  ///
  /// In en, this message translates to:
  /// **'Search for college or department...'**
  String get guestSearchHint;

  /// Total count of academic colleges
  ///
  /// In en, this message translates to:
  /// **'{count} Colleges'**
  String guestCollegesCount(int count);

  /// Portal heading for unauthenticated users
  ///
  /// In en, this message translates to:
  /// **'Guest Portal'**
  String get guestPortalTitle;

  /// Message when search query matches nothing
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{search}\"'**
  String guestNoResultsFor(String search);

  /// Footer CTA to register new accounts
  ///
  /// In en, this message translates to:
  /// **'Register Now at University of Derna'**
  String get guestSignUpCTA;

  /// Department count of a faculty
  ///
  /// In en, this message translates to:
  /// **'{count} Departments'**
  String guestDepartmentsCount(int count);

  /// Section header in college details bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Academic Departments'**
  String get guestAcademicDepartments;

  /// CTA button to sign up directly to a specific college
  ///
  /// In en, this message translates to:
  /// **'Register in this College'**
  String get guestRegisterInCollege;

  /// Title for colleges listing or explorer
  ///
  /// In en, this message translates to:
  /// **'Colleges'**
  String get collegesTitle;

  /// Search field hint on colleges explorer
  ///
  /// In en, this message translates to:
  /// **'Search colleges...'**
  String get searchCollegesHint;

  /// Empty state when college search has no results
  ///
  /// In en, this message translates to:
  /// **'No colleges found'**
  String get noCollegesFoundMessage;

  /// Department count label for a college
  ///
  /// In en, this message translates to:
  /// **'{count} departments'**
  String departmentsCount(int count);

  /// Button to open college or faculty details
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetailsButton;

  /// Title for the academic timetable screen
  ///
  /// In en, this message translates to:
  /// **'Timetable'**
  String get timetableTitle;

  /// Week tab on timetable screen
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get weekTabLabel;

  /// Month tab on timetable screen
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get monthTabLabel;

  /// Empty state when no timetable sessions exist
  ///
  /// In en, this message translates to:
  /// **'No sessions scheduled'**
  String get noSessionsMessage;

  /// Session time range (always displayed LTR)
  ///
  /// In en, this message translates to:
  /// **'{startTime} - {endTime}'**
  String sessionTimeFormat(String startTime, String endTime);

  /// Primary action to enter guest mode
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get guestContinueButton;

  /// Warning shown before continuing as guest
  ///
  /// In en, this message translates to:
  /// **'Your data won\'t be saved across devices'**
  String get guestWarningMessage;

  /// Confirm action in guest warning dialog
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceedButton;

  /// Cancel action in guest warning dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// Title for semester transcript screen
  ///
  /// In en, this message translates to:
  /// **'Semester Transcript'**
  String get transcriptTitle;

  /// Semester label on transcript screen
  ///
  /// In en, this message translates to:
  /// **'Semester: {semester}'**
  String transcriptSemesterLabel(String semester);

  /// Student ID label on transcript screen
  ///
  /// In en, this message translates to:
  /// **'Student ID: {id}'**
  String transcriptStudentIdLabel(String id);

  /// GPA label on transcript screen
  ///
  /// In en, this message translates to:
  /// **'GPA: {gpa}'**
  String transcriptGpaLabel(String gpa);

  /// Shown while transcript is loading
  ///
  /// In en, this message translates to:
  /// **'Loading transcript...'**
  String get transcriptLoadingMessage;

  /// Shown while PDF is being generated
  ///
  /// In en, this message translates to:
  /// **'Generating PDF...'**
  String get transcriptGeneratingMessage;

  /// Shown when no transcript data exists
  ///
  /// In en, this message translates to:
  /// **'No transcript data available'**
  String get transcriptNoDataMessage;

  /// Retry loading transcript
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get transcriptRetryButton;

  /// Banner when showing cached transcript offline
  ///
  /// In en, this message translates to:
  /// **'Using cached version - offline mode'**
  String get transcriptOfflineBanner;

  /// Shown when offline with no cache
  ///
  /// In en, this message translates to:
  /// **'No cached transcript available offline'**
  String get transcriptNoCacheMessage;

  /// Refresh transcript from server
  ///
  /// In en, this message translates to:
  /// **'Refresh from server'**
  String get transcriptRefreshButton;

  /// Last cache update timestamp
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String transcriptLastUpdatedLabel(String date);

  /// Open transcript PDF
  ///
  /// In en, this message translates to:
  /// **'Open PDF'**
  String get transcriptOpenPdfButton;

  /// Download transcript PDF
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get transcriptDownloadButton;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmptyMessage;

  /// Button to mark all notifications read
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllReadButton;

  /// Badge for unread notifications
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get notificationNewBadge;

  /// Relative time for a notification
  ///
  /// In en, this message translates to:
  /// **'{time} ago'**
  String notificationTimeAgo(String time);

  /// Delete notification button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get notificationDeleteButton;

  /// Title for alerts page
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsTitle;

  /// Title for announcements page
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcementsTitle;

  /// Button to open notification settings
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettingsButton;

  /// Title for messages screen
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// Title for inbox screen
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inboxTitle;

  /// Title for chat screen
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// Empty state when there are no messages
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get messagesEmptyMessage;

  /// Search field hint on messages
  ///
  /// In en, this message translates to:
  /// **'Type your message here...'**
  String get messageSearchHint;

  /// Button to compose a new message
  ///
  /// In en, this message translates to:
  /// **'New Message'**
  String get messageComposeButton;

  /// Reply to a message
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get messageReplyButton;

  /// Title for absence excuse submission page
  ///
  /// In en, this message translates to:
  /// **'Submit Absence Excuse'**
  String get absenceExcuseTitle;

  /// Label for subject selection
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subjectLabel;

  /// Label for absence date range
  ///
  /// In en, this message translates to:
  /// **'Absence Period'**
  String get absencePeriodLabel;

  /// Hint text for date picker
  ///
  /// In en, this message translates to:
  /// **'Tap to select dates'**
  String get selectDatesHint;

  /// Label for excuse type selection
  ///
  /// In en, this message translates to:
  /// **'Excuse Type'**
  String get excuseTypeLabel;

  /// Sick leave excuse type
  ///
  /// In en, this message translates to:
  /// **'Sick Leave'**
  String get excuseTypeSick;

  /// Emergency excuse type
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get excuseTypeEmergency;

  /// Family reasons excuse type
  ///
  /// In en, this message translates to:
  /// **'Family Reasons'**
  String get excuseTypeFamily;

  /// Other excuse type
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get excuseTypeOther;

  /// Label for excuse description
  ///
  /// In en, this message translates to:
  /// **'Description and Reason'**
  String get descriptionLabel;

  /// Hint text for description field
  ///
  /// In en, this message translates to:
  /// **'Write excuse details here...'**
  String get descriptionHint;

  /// Label for file attachments
  ///
  /// In en, this message translates to:
  /// **'Attachments (Optional, required for sick leave)'**
  String get attachmentsLabel;

  /// Hint for attachment upload area
  ///
  /// In en, this message translates to:
  /// **'Tap to attach file or image'**
  String get tapToAttach;

  /// Maximum file size hint
  ///
  /// In en, this message translates to:
  /// **'Maximum: 5 MB'**
  String get maxFileSize;

  /// Button to remove attachment
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeAttachment;

  /// Option to take photo
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Option to choose from gallery
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Option to choose PDF file
  ///
  /// In en, this message translates to:
  /// **'Choose PDF File'**
  String get choosePdf;

  /// Error when file is too large
  ///
  /// In en, this message translates to:
  /// **'File size must not exceed 5 MB'**
  String get fileSizeError;

  /// Error when date range not selected
  ///
  /// In en, this message translates to:
  /// **'Please select absence period'**
  String get selectDateError;

  /// Error when medical attachment missing
  ///
  /// In en, this message translates to:
  /// **'Medical attachment required for sick leave'**
  String get medicalAttachmentRequired;

  /// Error when user not authenticated
  ///
  /// In en, this message translates to:
  /// **'User is not logged in'**
  String get userNotLoggedIn;

  /// Error when duplicate excuse submitted
  ///
  /// In en, this message translates to:
  /// **'An excuse for this subject has already been submitted for the same date'**
  String get excuseAlreadySubmitted;

  /// Loading message during upload
  ///
  /// In en, this message translates to:
  /// **'Uploading request...'**
  String get uploadingRequest;

  /// Success message after excuse submission
  ///
  /// In en, this message translates to:
  /// **'Excuse submitted successfully and will be reviewed by college administration'**
  String get excuseSubmittedSuccess;

  /// Button to return to home
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// Error when subject not selected
  ///
  /// In en, this message translates to:
  /// **'Please select subject'**
  String get selectSubjectError;

  /// Error when excuse type not selected
  ///
  /// In en, this message translates to:
  /// **'Please select excuse type'**
  String get selectExcuseTypeError;

  /// Error when reason not provided
  ///
  /// In en, this message translates to:
  /// **'Please write the reason'**
  String get writeReasonError;

  /// Title for enrollment renewal page
  ///
  /// In en, this message translates to:
  /// **'Enrollment Renewal'**
  String get enrollmentRenewalTitle;

  /// Error when payment method not selected
  ///
  /// In en, this message translates to:
  /// **'Please select payment method first'**
  String get selectPaymentMethodError;

  /// Error during submission
  ///
  /// In en, this message translates to:
  /// **'Error during submission: {error}'**
  String submissionError(String error);

  /// Button to start renewal process
  ///
  /// In en, this message translates to:
  /// **'Start Renewal Process'**
  String get startRenewalProcess;

  /// Button to confirm payment
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment and Submit'**
  String get confirmPayment;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Step title for data review
  ///
  /// In en, this message translates to:
  /// **'Review Data'**
  String get reviewDataStep;

  /// Step title for payment method
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethodStep;

  /// Step title for request status
  ///
  /// In en, this message translates to:
  /// **'Request Status'**
  String get requestStatusStep;

  /// Label for student name
  ///
  /// In en, this message translates to:
  /// **'Student Name:'**
  String get studentNameLabel;

  /// Label for student ID
  ///
  /// In en, this message translates to:
  /// **'Student ID:'**
  String get studentIdLabel;

  /// Label for college
  ///
  /// In en, this message translates to:
  /// **'College:'**
  String get collegeLabel;

  /// Label for academic year
  ///
  /// In en, this message translates to:
  /// **'Academic Year:'**
  String get academicYearLabel;

  /// Label for deadline
  ///
  /// In en, this message translates to:
  /// **'Deadline:'**
  String get deadlineLabel;

  /// Label for required fees
  ///
  /// In en, this message translates to:
  /// **'Required Fees:'**
  String get feesRequiredLabel;

  /// Bank transfer payment method
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get paymentMethodBank;

  /// Libya Bank payment method
  ///
  /// In en, this message translates to:
  /// **'Libya Bank'**
  String get paymentMethodLibyaBank;

  /// Online payment method
  ///
  /// In en, this message translates to:
  /// **'Online Payment'**
  String get paymentMethodOnline;

  /// Republic Bank name
  ///
  /// In en, this message translates to:
  /// **'Republic Bank'**
  String get republicBank;

  /// Bank account number
  ///
  /// In en, this message translates to:
  /// **'Account Number: 123-456789-00'**
  String get bankAccountNumber;

  /// Payment beneficiary
  ///
  /// In en, this message translates to:
  /// **'Beneficiary: University of Derna'**
  String get beneficiary;

  /// Button to attach payment receipt
  ///
  /// In en, this message translates to:
  /// **'Attach Transfer Receipt'**
  String get attachReceipt;

  /// Success message when receipt attached
  ///
  /// In en, this message translates to:
  /// **'Payment receipt attached successfully'**
  String get receiptAttached;

  /// Libya Central Bank name
  ///
  /// In en, this message translates to:
  /// **'Libya Central Bank'**
  String get libyaCentralBank;

  /// Card payment option
  ///
  /// In en, this message translates to:
  /// **'Payment via Bank Card'**
  String get cardPayment;

  /// Coming soon badge
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Status when request approved
  ///
  /// In en, this message translates to:
  /// **'Your Request Approved ✓'**
  String get requestApproved;

  /// Message when request approved
  ///
  /// In en, this message translates to:
  /// **'Your enrollment renewal has been approved. Welcome to the new academic year.'**
  String get requestApprovedMessage;

  /// Status when request rejected
  ///
  /// In en, this message translates to:
  /// **'Request Rejected'**
  String get requestRejected;

  /// Message when request rejected
  ///
  /// In en, this message translates to:
  /// **'Your enrollment renewal request has been rejected. Please contact Admissions and Registration for inquiries.'**
  String get requestRejectedMessage;

  /// Status when request pending
  ///
  /// In en, this message translates to:
  /// **'Your Request Under Review'**
  String get requestPending;

  /// Message when request pending
  ///
  /// In en, this message translates to:
  /// **'Your request has been received successfully. It will be reviewed by Admissions and Registration and you will be notified of the result.'**
  String get requestPendingMessage;

  /// Label for reference number
  ///
  /// In en, this message translates to:
  /// **'Reference Number:'**
  String get referenceNumberLabel;

  /// Title for exam papers page
  ///
  /// In en, this message translates to:
  /// **'Exam Papers'**
  String get examPapersTitle;

  /// Quiz exam category
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzesCategory;

  /// Midterm exam category
  ///
  /// In en, this message translates to:
  /// **'Midterm Exam'**
  String get midtermCategory;

  /// Final exam category
  ///
  /// In en, this message translates to:
  /// **'Final Exam'**
  String get finalCategory;

  /// Empty state when no papers in category
  ///
  /// In en, this message translates to:
  /// **'No papers in this section currently'**
  String get noPapersInSection;

  /// Error loading exam papers
  ///
  /// In en, this message translates to:
  /// **'Error loading exam papers: {error}'**
  String loadingPapersError(String error);

  /// Fallback when date unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown Date'**
  String get unknownDate;

  /// Label for upload date
  ///
  /// In en, this message translates to:
  /// **'Upload Date: {date}'**
  String uploadDateLabel(String date);

  /// Fallback when subject unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown Subject'**
  String get unknownSubject;

  /// Button to view exam paper
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewPaper;

  /// Error when file link unavailable
  ///
  /// In en, this message translates to:
  /// **'File link unavailable'**
  String get fileLinkUnavailable;

  /// Mock subject 1
  ///
  /// In en, this message translates to:
  /// **'Advanced Programming - CS301'**
  String get mockSubject1;

  /// Mock subject 2
  ///
  /// In en, this message translates to:
  /// **'Data Structures - CS202'**
  String get mockSubject2;

  /// Mock subject 3
  ///
  /// In en, this message translates to:
  /// **'Artificial Intelligence - CS405'**
  String get mockSubject3;

  /// Mock subject 4
  ///
  /// In en, this message translates to:
  /// **'Discrete Mathematics - MA104'**
  String get mockSubject4;

  /// Forward a message
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get messageForwardButton;

  /// Title for student forum
  ///
  /// In en, this message translates to:
  /// **'Student Forum'**
  String get forumTitle;

  /// Button to add a new post
  ///
  /// In en, this message translates to:
  /// **'Add Post'**
  String get addPost;

  /// Title for help center hub
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenterTitle;

  /// Title for FAQ screen
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// Title for contact screen
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUsTitle;

  /// Search hint on FAQ screen
  ///
  /// In en, this message translates to:
  /// **'Search FAQs...'**
  String get faqSearchHint;

  /// Submit support ticket button
  ///
  /// In en, this message translates to:
  /// **'Submit a Ticket'**
  String get supportTicketButton;

  /// Email support channel label
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get supportEmailLabel;

  /// Phone support channel label
  ///
  /// In en, this message translates to:
  /// **'Call Support'**
  String get supportPhoneLabel;

  /// Report a problem button
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get reportProblemButton;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterTitle;

  /// No description provided for @clearFiltersButton.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFiltersButton;

  /// No description provided for @applyFiltersButton.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFiltersButton;

  /// No description provided for @noSearchResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noSearchResultsMessage;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network connection failed. Check your internet.'**
  String get networkError;

  /// No description provided for @timeoutError.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get timeoutError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get serverError;

  /// No description provided for @unauthorizedError.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized. Please login again.'**
  String get unauthorizedError;

  /// Title for database seeder widget
  ///
  /// In en, this message translates to:
  /// **'Database Seeder'**
  String get databaseSeederTitle;

  /// Description for database seeder widget
  ///
  /// In en, this message translates to:
  /// **'This tool creates interconnected test data for the university system (Student, Faculty, Admin).'**
  String get databaseSeederDescription;

  /// Button to start database seeding
  ///
  /// In en, this message translates to:
  /// **'Start Seeding'**
  String get seedDatabaseButton;

  /// Warning message for database seeder
  ///
  /// In en, this message translates to:
  /// **'⚠️ Any existing test data will be deleted before seeding.'**
  String get databaseSeederWarning;

  /// Success message for database seeding
  ///
  /// In en, this message translates to:
  /// **'Database seeded successfully!'**
  String get databaseSeedingSuccess;

  /// Error message for database seeding
  ///
  /// In en, this message translates to:
  /// **'Database seeding failed'**
  String get databaseSeedingError;

  /// No description provided for @notFoundError.
  ///
  /// In en, this message translates to:
  /// **'Data not found.'**
  String get notFoundError;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validationInvalidEmail;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validationPasswordTooShort;

  /// No description provided for @validationPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordsDoNotMatch;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to University Portal'**
  String get onboardingTitle;

  /// No description provided for @onboardingSkipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkipButton;

  /// No description provided for @onboardingNextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNextButton;

  /// No description provided for @onboardingGetStartedButton.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStartedButton;

  /// No description provided for @tutorialCoursesTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Your Courses'**
  String get tutorialCoursesTitle;

  /// No description provided for @tutorialGradesTitle.
  ///
  /// In en, this message translates to:
  /// **'View Your Grades'**
  String get tutorialGradesTitle;

  /// No description provided for @tutorialNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay Updated'**
  String get tutorialNotificationsTitle;

  /// Title shown when user tries to access restricted path
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get unauthorizedTitle;

  /// Message shown on unauthorized access page
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access this section. This attempt has been logged for security purposes.'**
  String get unauthorizedMessage;

  /// Button to return to user's appropriate dashboard
  ///
  /// In en, this message translates to:
  /// **'Return to My Portal'**
  String get returnToPortal;

  /// No description provided for @gradeInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get gradeInvalidNumber;

  /// No description provided for @gradeMaxMidterm.
  ///
  /// In en, this message translates to:
  /// **'Max score is 40'**
  String get gradeMaxMidterm;

  /// No description provided for @gradeMaxFinal.
  ///
  /// In en, this message translates to:
  /// **'Max score is 40'**
  String get gradeMaxFinal;

  /// No description provided for @gradeMaxAssignments.
  ///
  /// In en, this message translates to:
  /// **'Max score is 20'**
  String get gradeMaxAssignments;

  /// No description provided for @changeRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Role'**
  String get changeRoleTitle;

  /// No description provided for @classDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Class Details'**
  String get classDetailTitle;

  /// No description provided for @studentsListTab.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get studentsListTab;

  /// No description provided for @announcementsTab.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcementsTab;

  /// No description provided for @searchStudent.
  ///
  /// In en, this message translates to:
  /// **'Search for a student...'**
  String get searchStudent;

  /// No description provided for @addAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Add Announcement'**
  String get addAnnouncement;

  /// No description provided for @addAnnouncementTitle.
  ///
  /// In en, this message translates to:
  /// **'New Announcement'**
  String get addAnnouncementTitle;

  /// No description provided for @announcementHint.
  ///
  /// In en, this message translates to:
  /// **'Write your announcement here...'**
  String get announcementHint;

  /// No description provided for @announcementAdded.
  ///
  /// In en, this message translates to:
  /// **'Announcement added successfully'**
  String get announcementAdded;

  /// No description provided for @deleteAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Delete Announcement'**
  String get deleteAnnouncement;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this announcement?'**
  String get deleteConfirmation;

  /// No description provided for @announcementDeleted.
  ///
  /// In en, this message translates to:
  /// **'Announcement deleted successfully'**
  String get announcementDeleted;

  /// No description provided for @noAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'No announcements yet'**
  String get noAnnouncements;

  /// No description provided for @noStudents.
  ///
  /// In en, this message translates to:
  /// **'No students found'**
  String get noStudents;

  /// No description provided for @profileFacultyMember.
  ///
  /// In en, this message translates to:
  /// **'Distinguished Faculty Member'**
  String get profileFacultyMember;

  /// No description provided for @profileExperienceYears.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get profileExperienceYears;

  /// No description provided for @profilePublishedResearch.
  ///
  /// In en, this message translates to:
  /// **'Published Research'**
  String get profilePublishedResearch;

  /// No description provided for @profileJobId.
  ///
  /// In en, this message translates to:
  /// **'Job ID'**
  String get profileJobId;

  /// No description provided for @profileSpecialization.
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get profileSpecialization;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get profileEmail;

  /// No description provided for @profileDigitalDocuments.
  ///
  /// In en, this message translates to:
  /// **'Digital Documents'**
  String get profileDigitalDocuments;

  /// No description provided for @profileDownloadCard.
  ///
  /// In en, this message translates to:
  /// **'Download Electronic Card'**
  String get profileDownloadCard;

  /// No description provided for @profileDownloadDecree.
  ///
  /// In en, this message translates to:
  /// **'Download Appointment Decree'**
  String get profileDownloadDecree;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @scheduleTerm.
  ///
  /// In en, this message translates to:
  /// **'Fall 2024'**
  String get scheduleTerm;

  /// No description provided for @scheduleToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Schedule'**
  String get scheduleToday;

  /// No description provided for @scheduleActiveNow.
  ///
  /// In en, this message translates to:
  /// **'Active Now'**
  String get scheduleActiveNow;

  /// No description provided for @scheduleLectureRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get scheduleLectureRoom;

  /// No description provided for @scheduleFloor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get scheduleFloor;

  /// No description provided for @scheduleStudentsRegistered.
  ///
  /// In en, this message translates to:
  /// **'students registered'**
  String get scheduleStudentsRegistered;

  /// No description provided for @scheduleAttendanceButton.
  ///
  /// In en, this message translates to:
  /// **'Record Attendance'**
  String get scheduleAttendanceButton;

  /// No description provided for @scheduleUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Lecture'**
  String get scheduleUpcoming;

  /// No description provided for @scheduleTheoretical.
  ///
  /// In en, this message translates to:
  /// **'Theoretical'**
  String get scheduleTheoretical;

  /// No description provided for @schedulePractical.
  ///
  /// In en, this message translates to:
  /// **'Practical'**
  String get schedulePractical;

  /// No description provided for @scheduleGreetingDoctor.
  ///
  /// In en, this message translates to:
  /// **'Hello Dr.'**
  String get scheduleGreetingDoctor;

  /// No description provided for @settingsEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile Information'**
  String get settingsEditProfile;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Secure Password'**
  String get settingsChangePassword;

  /// No description provided for @settingsLanguageDefault.
  ///
  /// In en, this message translates to:
  /// **'Arabic (Default)'**
  String get settingsLanguageDefault;

  /// No description provided for @settingsSystem.
  ///
  /// In en, this message translates to:
  /// **'System Preferences'**
  String get settingsSystem;

  /// No description provided for @settingsBiometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric Fingerprint Login'**
  String get settingsBiometric;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support & Information'**
  String get settingsSupport;

  /// No description provided for @attendanceSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance Registration'**
  String get attendanceSheetTitle;

  /// No description provided for @attendanceSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage student attendance and upload lecture materials'**
  String get attendanceSheetSubtitle;

  /// No description provided for @attendanceCurrentLecture.
  ///
  /// In en, this message translates to:
  /// **'Current Lecture'**
  String get attendanceCurrentLecture;

  /// No description provided for @attendanceRoom.
  ///
  /// In en, this message translates to:
  /// **'Room 104 - Technology Building'**
  String get attendanceRoom;

  /// No description provided for @attendanceStudentList.
  ///
  /// In en, this message translates to:
  /// **'Student List'**
  String get attendanceStudentList;

  /// No description provided for @attendanceStudentCount.
  ///
  /// In en, this message translates to:
  /// **'Total students'**
  String get attendanceStudentCount;

  /// No description provided for @attendancePresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get attendancePresent;

  /// No description provided for @attendanceLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get attendanceLate;

  /// No description provided for @attendanceAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get attendanceAbsent;

  /// No description provided for @attendanceUploadSection.
  ///
  /// In en, this message translates to:
  /// **'Upload Lecture Files'**
  String get attendanceUploadSection;

  /// No description provided for @attendanceUploadHint.
  ///
  /// In en, this message translates to:
  /// **'Tap here or drag files to upload'**
  String get attendanceUploadHint;

  /// No description provided for @attendanceUploadTypes.
  ///
  /// In en, this message translates to:
  /// **'PDF, PPTX, DOCX (up to 50 MB)'**
  String get attendanceUploadTypes;

  /// No description provided for @attendanceSaveReport.
  ///
  /// In en, this message translates to:
  /// **'Save & Submit Report'**
  String get attendanceSaveReport;

  /// No description provided for @attendanceSaved.
  ///
  /// In en, this message translates to:
  /// **'Attendance saved successfully'**
  String get attendanceSaved;

  /// No description provided for @studentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Students Directory & Communication'**
  String get studentsTitle;

  /// No description provided for @studentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage attendance, communication, and academic data'**
  String get studentsSubtitle;

  /// No description provided for @studentsNewAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Send New Announcement'**
  String get studentsNewAnnouncement;

  /// No description provided for @studentsTargetAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get studentsTargetAll;

  /// No description provided for @studentsTargetGroupA.
  ///
  /// In en, this message translates to:
  /// **'Group A'**
  String get studentsTargetGroupA;

  /// No description provided for @studentsTargetGroupB.
  ///
  /// In en, this message translates to:
  /// **'Group B'**
  String get studentsTargetGroupB;

  /// No description provided for @studentsTargetStruggling.
  ///
  /// In en, this message translates to:
  /// **'Struggling Students'**
  String get studentsTargetStruggling;

  /// No description provided for @studentsAnnouncementHint.
  ///
  /// In en, this message translates to:
  /// **'Write your announcement here...'**
  String get studentsAnnouncementHint;

  /// No description provided for @studentsBroadcastNow.
  ///
  /// In en, this message translates to:
  /// **'Broadcast Now'**
  String get studentsBroadcastNow;

  /// No description provided for @studentsRegistered.
  ///
  /// In en, this message translates to:
  /// **'Registered Students'**
  String get studentsRegistered;

  /// No description provided for @studentsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by name or university ID...'**
  String get studentsSearch;

  /// No description provided for @studentsRecentAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Recent Announcements Log'**
  String get studentsRecentAnnouncements;

  /// No description provided for @studentsConfirmations.
  ///
  /// In en, this message translates to:
  /// **'confirmations'**
  String get studentsConfirmations;

  /// No description provided for @studentsViews.
  ///
  /// In en, this message translates to:
  /// **'views'**
  String get studentsViews;

  /// No description provided for @studentsMessageSent.
  ///
  /// In en, this message translates to:
  /// **'Announcement sent successfully'**
  String get studentsMessageSent;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Grade Distribution Reports'**
  String get reportsTitle;

  /// No description provided for @reportsSelectSemester.
  ///
  /// In en, this message translates to:
  /// **'Academic Semester'**
  String get reportsSelectSemester;

  /// No description provided for @reportsSelectCourse.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get reportsSelectCourse;

  /// No description provided for @reportsSuccessRate.
  ///
  /// In en, this message translates to:
  /// **'Overall Pass Rate'**
  String get reportsSuccessRate;

  /// No description provided for @reportsTotalStudents.
  ///
  /// In en, this message translates to:
  /// **'Total Students'**
  String get reportsTotalStudents;

  /// No description provided for @reportsAverageGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade Average'**
  String get reportsAverageGrade;

  /// No description provided for @reportsDistributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Grade Distribution Chart'**
  String get reportsDistributionTitle;

  /// No description provided for @reportsGradeA.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get reportsGradeA;

  /// No description provided for @reportsGradeB.
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get reportsGradeB;

  /// No description provided for @reportsGradeC.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get reportsGradeC;

  /// No description provided for @reportsGradeD.
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get reportsGradeD;

  /// No description provided for @reportsGradeF.
  ///
  /// In en, this message translates to:
  /// **'Fail'**
  String get reportsGradeF;

  /// No description provided for @reportsExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF Report'**
  String get reportsExportPdf;

  /// No description provided for @reportsExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report exported successfully'**
  String get reportsExportSuccess;

  /// No description provided for @assignmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Assignments & Grades'**
  String get assignmentsTitle;

  /// No description provided for @assignmentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fall 2024 Semester - IT Faculty'**
  String get assignmentsSubtitle;

  /// No description provided for @assignmentsWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for grading'**
  String get assignmentsWaiting;

  /// No description provided for @assignmentsStudents.
  ///
  /// In en, this message translates to:
  /// **'students'**
  String get assignmentsStudents;

  /// No description provided for @assignmentsDueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Due tomorrow'**
  String get assignmentsDueTomorrow;

  /// No description provided for @assignmentsGraded.
  ///
  /// In en, this message translates to:
  /// **'Graded Students'**
  String get assignmentsGraded;

  /// No description provided for @assignmentsAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Assignment'**
  String get assignmentsAddTitle;

  /// No description provided for @assignmentsAssignmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Assignment Title'**
  String get assignmentsAssignmentTitle;

  /// No description provided for @assignmentsAssignmentTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Assignment 1 - Data Structures'**
  String get assignmentsAssignmentTitleHint;

  /// No description provided for @assignmentsMaxGrade.
  ///
  /// In en, this message translates to:
  /// **'Max Grade'**
  String get assignmentsMaxGrade;

  /// No description provided for @assignmentsDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get assignmentsDueDate;

  /// No description provided for @assignmentsPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish New Assignment'**
  String get assignmentsPublish;

  /// No description provided for @assignmentsCoursePrefix.
  ///
  /// In en, this message translates to:
  /// **'Course:'**
  String get assignmentsCoursePrefix;

  /// No description provided for @assignmentsGradingSection.
  ///
  /// In en, this message translates to:
  /// **'Grade Entry'**
  String get assignmentsGradingSection;

  /// No description provided for @assignmentsGradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get assignmentsGradeLabel;

  /// No description provided for @assignmentsShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show More Students'**
  String get assignmentsShowMore;

  /// No description provided for @assignmentsValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please check input values'**
  String get assignmentsValidationError;

  /// No description provided for @facultyPortalDrawerTitle.
  ///
  /// In en, this message translates to:
  /// **'Faculty Portal'**
  String get facultyPortalDrawerTitle;

  /// No description provided for @academicPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Academic Plan & Tracking'**
  String get academicPlanTitle;

  /// No description provided for @semesterOne.
  ///
  /// In en, this message translates to:
  /// **'Semester 1'**
  String get semesterOne;

  /// No description provided for @semesterTwo.
  ///
  /// In en, this message translates to:
  /// **'Semester 2'**
  String get semesterTwo;

  /// No description provided for @semesterThree.
  ///
  /// In en, this message translates to:
  /// **'Semester 3'**
  String get semesterThree;

  /// No description provided for @semesterFour.
  ///
  /// In en, this message translates to:
  /// **'Semester 4'**
  String get semesterFour;

  /// No description provided for @noCoursesThisSemester.
  ///
  /// In en, this message translates to:
  /// **'No courses listed for this semester'**
  String get noCoursesThisSemester;

  /// No description provided for @planProgressRate.
  ///
  /// In en, this message translates to:
  /// **'Academic Plan Progress Rate'**
  String get planProgressRate;

  /// No description provided for @planProgressDetails.
  ///
  /// In en, this message translates to:
  /// **'You have successfully completed {completed} out of {total} credit hours in your academic plan.'**
  String planProgressDetails(int completed, int total);

  /// No description provided for @courseStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get courseStatusCompleted;

  /// No description provided for @courseStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get courseStatusInProgress;

  /// No description provided for @courseStatusRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get courseStatusRemaining;

  /// No description provided for @creditHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'{credits} credit hours'**
  String creditHoursLabel(int credits);

  /// No description provided for @lecture.
  ///
  /// In en, this message translates to:
  /// **'Lecture'**
  String get lecture;

  /// No description provided for @editProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTooltip;

  /// No description provided for @absenceExcuse.
  ///
  /// In en, this message translates to:
  /// **'Absence Excuse'**
  String get absenceExcuse;

  /// No description provided for @examPapers.
  ///
  /// In en, this message translates to:
  /// **'Exam Papers'**
  String get examPapers;

  /// No description provided for @registrationRenewal.
  ///
  /// In en, this message translates to:
  /// **'Registration Renewal'**
  String get registrationRenewal;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @goodEveningReply.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEveningReply;

  /// Title for the student forum page
  ///
  /// In en, this message translates to:
  /// **'Student Forum'**
  String get studentForum;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @am.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get am;

  /// No description provided for @pm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get pm;

  /// No description provided for @sendMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Announcement'**
  String get sendMessageTitle;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @sendMessageSuccess.
  ///
  /// In en, this message translates to:
  /// **'Announcement sent successfully'**
  String get sendMessageSuccess;

  /// No description provided for @selectCourseError.
  ///
  /// In en, this message translates to:
  /// **'Please select a course'**
  String get selectCourseError;

  /// No description provided for @courseSection.
  ///
  /// In en, this message translates to:
  /// **'Course / Section'**
  String get courseSection;

  /// No description provided for @announcementSubjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Announcement Subject'**
  String get announcementSubjectTitle;

  /// No description provided for @announcementSubjectPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Write announcement subject here'**
  String get announcementSubjectPlaceholder;

  /// No description provided for @announcementSubjectError.
  ///
  /// In en, this message translates to:
  /// **'Please write a subject'**
  String get announcementSubjectError;

  /// No description provided for @announcementBodyTitle.
  ///
  /// In en, this message translates to:
  /// **'Announcement Body'**
  String get announcementBodyTitle;

  /// No description provided for @announcementBodyPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Write your announcement or notice to students here...'**
  String get announcementBodyPlaceholder;

  /// No description provided for @announcementBodyError.
  ///
  /// In en, this message translates to:
  /// **'Please write the announcement text'**
  String get announcementBodyError;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemTheme;

  /// No description provided for @langAr.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get langAr;

  /// No description provided for @langEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEn;

  /// No description provided for @facultyMember.
  ///
  /// In en, this message translates to:
  /// **'Faculty Member'**
  String get facultyMember;

  /// No description provided for @associateProfessor.
  ///
  /// In en, this message translates to:
  /// **'Associate Professor - Faculty of Engineering'**
  String get associateProfessor;

  /// No description provided for @distinguishedFacultyMember.
  ///
  /// In en, this message translates to:
  /// **'Distinguished Faculty Member'**
  String get distinguishedFacultyMember;

  /// No description provided for @passwordResetNote.
  ///
  /// In en, this message translates to:
  /// **'A password reset link will be sent to your email'**
  String get passwordResetNote;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of the portal?'**
  String get logoutConfirmBody;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @ahmed.
  ///
  /// In en, this message translates to:
  /// **'Ahmed'**
  String get ahmed;

  /// No description provided for @hourShortcut.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hourShortcut;

  /// No description provided for @hall.
  ///
  /// In en, this message translates to:
  /// **'Hall'**
  String get hall;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @questionMark.
  ///
  /// In en, this message translates to:
  /// **'?'**
  String get questionMark;

  /// No description provided for @fileSizeLimitNote.
  ///
  /// In en, this message translates to:
  /// **'File size must not exceed 10 MB'**
  String get fileSizeLimitNote;

  /// No description provided for @uploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Exam paper uploaded successfully'**
  String get uploadSuccess;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Error occurred during upload'**
  String get uploadFailed;

  /// No description provided for @uploadPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Exam Paper'**
  String get uploadPageTitle;

  /// No description provided for @selectCourse.
  ///
  /// In en, this message translates to:
  /// **'Select Course'**
  String get selectCourse;

  /// No description provided for @selectExamType.
  ///
  /// In en, this message translates to:
  /// **'Select Exam Type'**
  String get selectExamType;

  /// No description provided for @pdfPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tap to select a PDF file'**
  String get pdfPlaceholder;

  /// No description provided for @maxSizeLimit.
  ///
  /// In en, this message translates to:
  /// **'Max: 10MB'**
  String get maxSizeLimit;

  /// No description provided for @removeFile.
  ///
  /// In en, this message translates to:
  /// **'Remove File'**
  String get removeFile;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @targetCourse.
  ///
  /// In en, this message translates to:
  /// **'Target Course'**
  String get targetCourse;

  /// No description provided for @examType.
  ///
  /// In en, this message translates to:
  /// **'Exam Type'**
  String get examType;

  /// No description provided for @examPaperPdf.
  ///
  /// In en, this message translates to:
  /// **'Exam Paper (PDF)'**
  String get examPaperPdf;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @uploadAndSave.
  ///
  /// In en, this message translates to:
  /// **'Upload & Save'**
  String get uploadAndSave;

  /// No description provided for @studentsPageSelectCourse.
  ///
  /// In en, this message translates to:
  /// **'Select Course:'**
  String get studentsPageSelectCourse;

  /// Title for faculty excuses page
  ///
  /// In en, this message translates to:
  /// **'Absence Excuses'**
  String get excusesTitle;

  /// Empty state message when no excuses are submitted
  ///
  /// In en, this message translates to:
  /// **'No excuses submitted yet'**
  String get excusesNoExcuses;

  /// Default text when no reason is provided
  ///
  /// In en, this message translates to:
  /// **'No reason provided'**
  String get excusesWithoutReason;

  /// Status label for submitted excuse
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get excusesStatusSubmitted;

  /// Label for excuse reason
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get excusesReasonLabel;

  /// Button label to view attachment
  ///
  /// In en, this message translates to:
  /// **'View Attachment'**
  String get excusesViewAttachment;

  /// Success message when excuse is approved
  ///
  /// In en, this message translates to:
  /// **'✅ Excuse approved successfully'**
  String get excusesApproved;

  /// Success message when excuse is rejected
  ///
  /// In en, this message translates to:
  /// **'✅ Excuse rejected successfully'**
  String get excusesRejected;

  /// Error message with error details
  ///
  /// In en, this message translates to:
  /// **'❌ Error occurred: {error}'**
  String excusesErrorOccurred(String error);

  /// Default faculty member name
  ///
  /// In en, this message translates to:
  /// **'Faculty Member'**
  String get excusesFacultyMember;

  /// Label for target audience selection
  ///
  /// In en, this message translates to:
  /// **'Target Audience'**
  String get classDetailTargetAudience;

  /// Target audience option for affected students
  ///
  /// In en, this message translates to:
  /// **'Affected'**
  String get classDetailAffectedStudents;

  /// Target audience option for group A
  ///
  /// In en, this message translates to:
  /// **'Group A'**
  String get classDetailGroupA;

  /// Target audience option for group B
  ///
  /// In en, this message translates to:
  /// **'Group B'**
  String get classDetailGroupB;

  /// Button label to post announcement
  ///
  /// In en, this message translates to:
  /// **'Post Announcement Now'**
  String get classDetailPostAnnouncement;

  /// Message when starting chat with student
  ///
  /// In en, this message translates to:
  /// **'Start direct chat with {name}'**
  String classDetailStartChat(String name);

  /// University ID label with value
  ///
  /// In en, this message translates to:
  /// **'University ID: {id}'**
  String classDetailUniversityId(String id);

  /// Error message when loading fails
  ///
  /// In en, this message translates to:
  /// **'Loading error: {error}'**
  String classDetailLoadingError(String error);

  /// Default text when announcement has no title
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get classDetailNoTitle;

  /// Default forum tag for announcements
  ///
  /// In en, this message translates to:
  /// **'Forum'**
  String get classDetailForum;

  /// Label for view count
  ///
  /// In en, this message translates to:
  /// **'views'**
  String get classDetailViews;

  /// Label for comment count
  ///
  /// In en, this message translates to:
  /// **'comments'**
  String get classDetailComments;

  /// Error message when deletion fails
  ///
  /// In en, this message translates to:
  /// **'Error during deletion: {error}'**
  String classDetailDeleteError(String error);

  /// Message shown when downloading university card
  ///
  /// In en, this message translates to:
  /// **'Downloading university card...'**
  String get profileDownloadingCard;

  /// Message shown when downloading appointment decree
  ///
  /// In en, this message translates to:
  /// **'Downloading appointment decree...'**
  String get profileDownloadingDecree;

  /// Message shown when help center is loading
  ///
  /// In en, this message translates to:
  /// **'Help center loading...'**
  String get settingsHelpLoading;

  /// Privacy policy message
  ///
  /// In en, this message translates to:
  /// **'University of Derna Privacy Policy {year}'**
  String settingsPrivacyPolicy(int year);

  /// Role label for faculty members
  ///
  /// In en, this message translates to:
  /// **'Associate Professor - College of Engineering'**
  String get settingsRoleFaculty;

  /// Role label for staff members
  ///
  /// In en, this message translates to:
  /// **'Honored Faculty Member'**
  String get settingsRoleStaff;

  /// Message shown when schedule notifications are enabled
  ///
  /// In en, this message translates to:
  /// **'Schedule notifications are automatically enabled'**
  String get scheduleNotificationsEnabled;

  /// Message shown when no lectures are scheduled for the day
  ///
  /// In en, this message translates to:
  /// **'No lectures scheduled for today'**
  String get scheduleNoLecturesToday;

  /// Dashboard welcome message for faculty
  ///
  /// In en, this message translates to:
  /// **'Welcome, Dr.'**
  String get dashboardWelcome;

  /// Fallback doctor title when name is empty
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get dashboardDoctorFallback;

  /// Label for courses taught count
  ///
  /// In en, this message translates to:
  /// **'Courses Taught'**
  String get dashboardCoursesTaught;

  /// Label for student count
  ///
  /// In en, this message translates to:
  /// **'Student Count'**
  String get dashboardStudentCount;

  /// Label for weekly lectures count
  ///
  /// In en, this message translates to:
  /// **'Weekly Lectures'**
  String get dashboardWeeklyLectures;

  /// Section title for quick actions
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get dashboardQuickActions;

  /// Quick action label for uploading lecture
  ///
  /// In en, this message translates to:
  /// **'Upload Lecture'**
  String get dashboardActionUploadLecture;

  /// Quick action label for uploading exam
  ///
  /// In en, this message translates to:
  /// **'Upload Exam'**
  String get dashboardActionUploadExam;

  /// Quick action label for adding assignment
  ///
  /// In en, this message translates to:
  /// **'Add Assignment'**
  String get dashboardActionAddAssignment;

  /// Section title for recent activities
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get dashboardRecentActivity;

  /// Section title for today's lectures
  ///
  /// In en, this message translates to:
  /// **'Today\'s Lectures'**
  String get dashboardTodayLectures;

  /// Message when no lectures are scheduled
  ///
  /// In en, this message translates to:
  /// **'No lectures scheduled for today'**
  String get dashboardNoLectures;

  /// Error message when lectures fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading lectures'**
  String get dashboardLoadError;

  /// Section title for grades entry progress
  ///
  /// In en, this message translates to:
  /// **'Grades Entry Progress'**
  String get dashboardGradesProgress;

  /// AM period shortcut
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get dashboardPeriodAM;

  /// Section title for grade distribution reports
  ///
  /// In en, this message translates to:
  /// **'Grade Distribution Reports'**
  String get dashboardGradeReports;

  /// Label for average grades
  ///
  /// In en, this message translates to:
  /// **'Average Grades'**
  String get dashboardAvgGrades;

  /// Label for pass rate
  ///
  /// In en, this message translates to:
  /// **'Pass Rate'**
  String get dashboardPassRate;

  /// Label for pending requests
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get dashboardPendingRequests;

  /// Label for weekly sessions
  ///
  /// In en, this message translates to:
  /// **'Weekly Sessions'**
  String get dashboardWeekSessions;

  /// Message when file upload is only available on mobile
  ///
  /// In en, this message translates to:
  /// **'File upload requires the mobile app — under development'**
  String get attendanceUploadMobileOnly;

  /// Error message when user is not logged in
  ///
  /// In en, this message translates to:
  /// **'You must be logged in first'**
  String get attendanceLoginRequired;

  /// Error message when professor lacks permission
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to record attendance for this course'**
  String get attendanceNoPermission;

  /// Total students count label
  ///
  /// In en, this message translates to:
  /// **'Total Students: {count}'**
  String assignmentsTotalStudents(int count);

  /// Out of total label
  ///
  /// In en, this message translates to:
  /// **'of {total}'**
  String assignmentsOutOf(int total);

  /// Course exam type option for exam upload page (dedicated key, do not confuse with existing mistranslated 'quiz' key)
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get examTypeCourseOption;

  /// Upload failure message with error detail
  ///
  /// In en, this message translates to:
  /// **'Error occurred during upload: {error}'**
  String uploadFailedWithReason(String error);

  /// Upload progress percentage label
  ///
  /// In en, this message translates to:
  /// **'Uploading: {progress}%'**
  String examUploadProgress(String progress);

  /// Morning period label
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get periodMorning;

  /// Afternoon period label
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get periodAfternoon;

  /// View all button label on dashboard
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get dashboardViewAll;

  /// Error message when image upload config is not set
  ///
  /// In en, this message translates to:
  /// **'Image upload configuration is missing'**
  String get imageUploadConfigMissing;

  /// Error message when image upload fails
  ///
  /// In en, this message translates to:
  /// **'Image upload failed: {error}'**
  String imageUploadFailed(String error);

  /// Error message when image upload is rejected
  ///
  /// In en, this message translates to:
  /// **'Image upload rejected'**
  String get imageUploadRejected;

  /// Error message when image URL is not available
  ///
  /// In en, this message translates to:
  /// **'Image URL is missing'**
  String get imageUrlMissing;

  /// Title for remove profile photo dialog
  ///
  /// In en, this message translates to:
  /// **'Remove Profile Photo'**
  String get removeImageTitle;

  /// Confirmation message for removing profile photo
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove your profile photo?'**
  String get removeImageConfirm;

  /// Button label to remove image
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeImageAction;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
