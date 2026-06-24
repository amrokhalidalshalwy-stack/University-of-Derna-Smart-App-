import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_project/core/app_keys.dart';
import 'package:flutter_project/core/widgets/app_sync_listener.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/preferences/app_preferences.dart';
import 'package:flutter_project/core/localization/locale_provider.dart';
import 'package:flutter_project/core/router/app_router.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:flutter_project/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/features/hifzh/core/di/hive_init.dart';
import 'package:flutter_project/features/hifzh/core/di/hifzh_injection.dart';
import 'package:flutter_project/core/services/error_tracking_service.dart';

Future<void> main() async {
  // 1. Ensure Widgets are initialized + حجز الـ Native Splash حتى يجهز التطبيق
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  debugPrint("🚀 [Main] Starting application...");

  SharedPreferences? prefs;

  try {
    // 2. Initialize Firebase with a timeout to prevent infinite hangs
    debugPrint("🚀 [Main] Initializing Firebase...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        debugPrint("⚠️ [Main] Firebase initialization timed out (15 seconds)");
        throw Exception('Firebase Initialization Timeout');
      },
    );
    debugPrint("✅ [Main] Firebase initialized successfully");
    
    // Initialize Error Tracking
    await ErrorTrackingService.initialize();

    if (!kIsWeb) {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      debugPrint("📦 [Main] Local database configured (Firestore Persistence)");
    }
  } catch (e, stackTrace) {
      ErrorTrackingService.recordError(e, stackTrace, context: '❌ [Main] Error initializing Firebase');
  }

  try {
    // 3. Load SharedPreferences with a timeout
    debugPrint("🚀 [Main] Loading SharedPreferences...");
    prefs = await SharedPreferences.getInstance().timeout(
      const Duration(seconds: 5),
    );
    debugPrint("✅ [Main] SharedPreferences loaded");
  } catch (e, stackTrace) {
      ErrorTrackingService.recordError(e, stackTrace, context: '❌ [Main] Error loading SharedPreferences');
  }

  try {
    // 4. HifdhTracker initializations
    await dotenv.load(fileName: '.env');
    await initHive();
    await HifzhInjection.init();
    debugPrint("✅ [Main] HifdhTracker DI initialized");
  } catch (e, stackTrace) {
      ErrorTrackingService.recordError(e, stackTrace, context: '⚠️ [Main] HifdhTracker initialization skipped');
    debugPrint("ℹ️ [Main] App will continue without HifdhTracker feature");
  }

  // 5. إزالة الـ Native Splash بعد اكتمال جميع التهيئات
  FlutterNativeSplash.remove();

  runApp(
    ProviderScope(
      overrides: [
        if (prefs != null) sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔥 تفعيل الـ Providers لقراءة حالة الثيم واللغة المفضلة الحالية للمستخدم
    final themeMode = ref.watch(themeModeNotifierProvider);
    final localePreference = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);

    debugPrint("🎨 [MyApp] Building Dynamic MaterialApp.router...");

    return MaterialApp.router(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      onGenerateTitle:
          (context) =>
              AppLocalizations.of(context)?.appTitle ?? 'University of Derna',

      // الأكواد الأصلية للثيمات المخزنة في ملف AppTheme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // 1️⃣ جعل الثيم متغيراً ديناميكياً يتبع اختيار المستخدم أو النظام
      themeMode: themeMode,

      // 2️⃣ جعل اللغة ديناميكية تتبع اختيار المستخدم المخزن في التطبيق
      locale: localePreference,

      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,

      // 3️⃣ ترك النظام يختار اللغة المفضلة ديناميكياً بناءً على التفضيلات
      localeListResolutionCallback: (deviceLocales, supportedLocales) {
        return localePreference;
      },

      // 4️⃣ تم تعديل الـ builder ليمرر الـ child (الـ Navigator الفعلي للراوتر) مباشرة دون تداخل في اتجاهات النصوص، ليرث الـ ChatPage وباقي الصفحات الـ ThemeContext بشكل سليم
      builder: (context, child) {
        if (child == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return AppSyncListener(child: child);
      },
      routerConfig: router,
    );
  }
}

