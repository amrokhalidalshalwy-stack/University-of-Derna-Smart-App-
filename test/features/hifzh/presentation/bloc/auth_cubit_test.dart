import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/domain/models/user_model.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/sign_in_use_case.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/register_use_case.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/sign_out_use_case.dart';
import 'package:flutter_project/features/hifzh/data/repositories/auth_repository.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/auth/auth_cubit.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/auth/auth_state.dart';

class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockAuthRepository extends Mock implements HifzhAuthRepository {}

void main() {
  late AuthCubit cubit;
  late MockSignInUseCase mockSignIn;
  late MockRegisterUseCase mockRegister;
  late MockSignOutUseCase mockSignOut;
  late MockAuthRepository mockRepository;

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = HifzhUserModel(
    uid: 'uid123',
    email: tEmail,
    displayName: 'Test User',
  );

  setUp(() {
    mockSignIn = MockSignInUseCase();
    mockRegister = MockRegisterUseCase();
    mockSignOut = MockSignOutUseCase();
    mockRepository = MockAuthRepository();

    // Default stub for authStateChanges stream to prevent errors during construction/checking
    when(
      () => mockRepository.authStateChanges,
    ).thenAnswer((_) => const Stream.empty());

    cubit = AuthCubit(
      signInUseCase: mockSignIn,
      registerUseCase: mockRegister,
      signOutUseCase: mockSignOut,
      repository: mockRepository,
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state should be AuthInitial', () {
    expect(cubit.state, isA<AuthInitial>());
  });

  group('checkAuthStatus', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthAuthenticated] when authStateChanges emits a user',
      build: () {
        when(
          () => mockRepository.authStateChanges,
        ).thenAnswer((_) => Stream.value(tUser));
        return cubit;
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [isA<AuthAuthenticated>()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthUnauthenticated] when authStateChanges emits null',
      build: () {
        when(
          () => mockRepository.authStateChanges,
        ).thenAnswer((_) => Stream.value(null));
        return cubit;
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [isA<AuthUnauthenticated>()],
    );
  });

  group('signIn', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when signIn is successful',
      build: () {
        when(
          () => mockSignIn(email: tEmail, password: tPassword),
        ).thenAnswer((_) async => const HifzhSuccess(tUser));
        return cubit;
      },
      act: (cubit) => cubit.signIn(email: tEmail, password: tPassword),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] when signIn fails',
      build: () {
        when(() => mockSignIn(email: tEmail, password: tPassword)).thenAnswer(
          (_) async => const HifzhError(AuthFailure('خطأ في تسجيل الدخول')),
        );
        return cubit;
      },
      act: (cubit) => cubit.signIn(email: tEmail, password: tPassword),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );
  });

  group('signOut', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when signOut is successful',
      build: () {
        when(
          () => mockSignOut(),
        ).thenAnswer((_) async => const HifzhSuccess(null));
        return cubit;
      },
      act: (cubit) => cubit.signOut(),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] when signOut fails',
      build: () {
        when(() => mockSignOut()).thenAnswer(
          (_) async => const HifzhError(AuthFailure('خطأ في تسجيل الخروج')),
        );
        return cubit;
      },
      act: (cubit) => cubit.signOut(),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );
  });
}
