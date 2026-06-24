import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_project/features/hifzh/core/services/connectivity_service.dart';
import 'package:flutter_project/features/hifzh/core/network/hifzh_api_client.dart';
import 'package:flutter_project/features/hifzh/data/repositories/auth_repository.dart';
import 'package:flutter_project/features/hifzh/data/repositories/quran_repository.dart';
import 'package:flutter_project/features/hifzh/data/repositories/halaqah_repository.dart';
import 'package:flutter_project/features/hifzh/data/impl/local_quran_repository_impl.dart';
import 'package:flutter_project/features/hifzh/data/impl/remote_quran_repository_impl.dart';
import 'package:flutter_project/features/hifzh/data/impl/local_halaqah_repository_impl.dart';
import 'package:flutter_project/features/hifzh/data/impl/remote_halaqah_repository_impl.dart';
import 'package:flutter_project/features/hifzh/data/impl/remote_auth_repository_impl.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/sign_in_use_case.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/register_use_case.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/sign_out_use_case.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/get_all_surahs_use_case.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/update_memorization_status_use_case.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/get_due_sessions_use_case.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/apply_revision_review_use_case.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/get_leaderboard_use_case.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/auth/auth_cubit.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/quran/quran_cubit.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/revision/revision_cubit.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/halaqah/halaqah_cubit.dart';

class HifzhInjection {
  HifzhInjection._();

  static HifzhInjection? _instance;

  // ── Infrastructure & API Client ──────────────────────────────────────────
  late final HifzhConnectivityService connectivity;

  // ── Authenticaton Repository ─────────────────────────────────────────────
  late final HifzhAuthRepository authRepository;

  // ── Quran Repositories (Local & Remote) ──────────────────────────────────
  late final LocalQuranRepositoryImpl localQuranRepository;
  late final RemoteQuranRepositoryImpl remoteQuranRepository;

  // ── Halaqah Repositories (Local & Remote) ────────────────────────────────
  late final LocalHalaqahRepositoryImpl localHalaqahRepository;
  late final RemoteHalaqahRepositoryImpl remoteHalaqahRepository;

  // ── Connectivity-Aware Dynamic Switchers ─────────────────────────────────
  QuranRepository get quranRepository =>
      connectivity.isConnectedSync
          ? remoteQuranRepository
          : localQuranRepository;

  HalaqahRepository get halaqahRepository =>
      connectivity.isConnectedSync
          ? remoteHalaqahRepository
          : localHalaqahRepository;

  // ── Use-cases (lightweight, dynamically resolves switcher repo) ──────────
  late final SignInUseCase signIn;
  late final RegisterUseCase register;
  late final SignOutUseCase signOut;
  late final GetAllSurahsUseCase getAllSurahs;
  late final UpdateMemorizationStatusUseCase updateStatus;
  late final GetDueSessionsUseCase getDueSessions;
  late final ApplyRevisionReviewUseCase applyReview;
  late final GetLeaderboardUseCase getLeaderboard;
  late final JoinHalaqahUseCase joinHalaqah;

  /// Initializes all dependencies.
  static Future<HifzhInjection> init() async {
    if (_instance != null) return _instance!;

    final instance = HifzhInjection._();
    final prefs = await SharedPreferences.getInstance();

    // 1. Infrastructure & API Client
    instance.connectivity = HifzhConnectivityService(Connectivity());
    final dio = HifzhApiClient.create();

    // 2. Instantiate Repositories
    instance.authRepository = RemoteAuthRepositoryImpl(dio);
    instance.localQuranRepository = LocalQuranRepositoryImpl(prefs);
    instance.remoteQuranRepository = RemoteQuranRepositoryImpl(dio);
    instance.localHalaqahRepository = LocalHalaqahRepositoryImpl();
    instance.remoteHalaqahRepository = RemoteHalaqahRepositoryImpl(dio);

    // 3. Setup Use-cases
    instance.signIn = SignInUseCase(instance.authRepository);
    instance.register = RegisterUseCase(instance.authRepository);
    instance.signOut = SignOutUseCase(instance.authRepository);

    // Injecting the switcher getters (which evaluate dynamically at call-time)
    instance.getAllSurahs = GetAllSurahsUseCase(instance.quranRepository);
    instance.updateStatus = UpdateMemorizationStatusUseCase(
      instance.quranRepository,
    );
    instance.getDueSessions = GetDueSessionsUseCase(instance.quranRepository);
    instance.applyReview = ApplyRevisionReviewUseCase(instance.quranRepository);
    instance.getLeaderboard = GetLeaderboardUseCase(instance.halaqahRepository);
    instance.joinHalaqah = JoinHalaqahUseCase(instance.halaqahRepository);

    _instance = instance;
    return instance;
  }

  /// Returns the already-initialized singleton. Throws if [init] was not called.
  static HifzhInjection get instance {
    assert(
      _instance != null,
      'HifzhInjection.init() must be called before accessing instance.',
    );
    return _instance!;
  }

  // ── Cubit factories (new instance per page) ──────────────────────────────

  /// Creates a fresh [AuthCubit].
  AuthCubit createAuthCubit() => AuthCubit(
    signInUseCase: signIn,
    registerUseCase: register,
    signOutUseCase: signOut,
    repository: authRepository,
  );

  /// Creates a fresh [QuranCubit].
  QuranCubit createQuranCubit() =>
      QuranCubit(getAllSurahs: getAllSurahs, updateStatus: updateStatus);

  /// Creates a fresh [RevisionCubit].
  RevisionCubit createRevisionCubit() =>
      RevisionCubit(getDueSessions: getDueSessions, applyReview: applyReview);

  /// Creates a fresh [HalaqahCubit].
  HalaqahCubit createHalaqahCubit() => HalaqahCubit(
    repository: halaqahRepository,
    getLeaderboard: getLeaderboard,
    joinHalaqah: joinHalaqah,
  );

  AuthCubit? _authCubit;

  /// Retrieves or builds the single active [AuthCubit] instance.
  AuthCubit get authCubit =>
      _authCubit ??= createAuthCubit()..checkAuthStatus();
}

/// Global service locator getter for dependencies.
T getIt<T extends Object>() {
  if (T == AuthCubit) {
    return HifzhInjection.instance.authCubit as T;
  }
  if (T == HifzhConnectivityService) {
    return HifzhInjection.instance.connectivity as T;
  }
  if (T == QuranRepository) {
    return HifzhInjection.instance.quranRepository as T;
  }
  if (T == HalaqahRepository) {
    return HifzhInjection.instance.halaqahRepository as T;
  }
  if (T == HifzhAuthRepository) {
    return HifzhInjection.instance.authRepository as T;
  }
  throw UnimplementedError('Dependency not registered for: $T');
}
