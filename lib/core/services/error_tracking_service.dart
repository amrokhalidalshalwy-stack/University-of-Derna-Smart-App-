import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class ErrorTrackingService {
  static final _crashlytics = FirebaseCrashlytics.instance;

  /// تهيئة الخدمة عند بدء التطبيق
  static Future<void> initialize() async {
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    FlutterError.onError = _crashlytics.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// تسجيل خطأ مع سياق إضافي
  static Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? extras,
    bool fatal = false,
  }) async {
    if (kDebugMode) {
      debugPrint('❌ ERROR${context != null ? " in $context" : ""}: $error');
      if (stackTrace != null) debugPrint(stackTrace.toString());
      return;
    }

    if (context != null) {
      await _crashlytics.setCustomKey('error_context', context);
    }

    if (extras != null) {
      for (final entry in extras.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value.toString());
      }
    }

    await _crashlytics.recordError(error, stackTrace, fatal: fatal);
  }

  /// تسجيل رسالة معلوماتية (Log)
  static void log(String message) {
    if (kDebugMode) {
      debugPrint('📝 LOG: $message');
      return;
    }
    _crashlytics.log(message);
  }

  /// ربط الخطأ بالمستخدم الحالي
  static Future<void> setUser(String uid, String role) async {
    await _crashlytics.setUserIdentifier(uid);
    await _crashlytics.setCustomKey('user_role', role);
  }

  /// مسح بيانات المستخدم عند تسجيل الخروج
  static Future<void> clearUser() async {
    await _crashlytics.setUserIdentifier('');
  }
}
