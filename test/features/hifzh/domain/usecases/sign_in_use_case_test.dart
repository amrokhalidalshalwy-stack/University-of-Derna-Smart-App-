import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/data/repositories/auth_repository.dart';
import 'package:flutter_project/features/hifzh/domain/models/user_model.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/sign_in_use_case.dart';

class MockAuthRepository extends Mock implements HifzhAuthRepository {}

void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(mockRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = HifzhUserModel(
    uid: 'uid123',
    email: tEmail,
    displayName: 'Test User',
  );

  test(
    'should return HifzhSuccess(UserModel) when login is successful',
    () async {
      // arrange
      when(
        () => mockRepository.signInWithEmail(tEmail, tPassword),
      ).thenAnswer((_) async => const HifzhSuccess(tUser));

      // act
      final result = await useCase(email: tEmail, password: tPassword);

      // assert
      expect(result, isA<HifzhSuccess<HifzhUserModel>>());
      final successData = (result as HifzhSuccess<HifzhUserModel>).data;
      expect(successData, equals(tUser));
      verify(() => mockRepository.signInWithEmail(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );

  test(
    'should return HifzhError(AuthFailure) when invalid credentials are provided',
    () async {
      // arrange
      const failure = AuthFailure('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      when(
        () => mockRepository.signInWithEmail(tEmail, tPassword),
      ).thenAnswer((_) async => const HifzhError(failure));

      // act
      final result = await useCase(email: tEmail, password: tPassword);

      // assert
      expect(result, isA<HifzhError<HifzhUserModel>>());
      final errorFailure = (result as HifzhError<HifzhUserModel>).failure;
      expect(errorFailure, equals(failure));
      verify(() => mockRepository.signInWithEmail(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );

  test(
    'should return HifzhError(NetworkFailure) on connection timeout',
    () async {
      // arrange
      const failure = NetworkFailure();
      when(
        () => mockRepository.signInWithEmail(tEmail, tPassword),
      ).thenAnswer((_) async => const HifzhError(failure));

      // act
      final result = await useCase(email: tEmail, password: tPassword);

      // assert
      expect(result, isA<HifzhError<HifzhUserModel>>());
      final errorFailure = (result as HifzhError<HifzhUserModel>).failure;
      expect(errorFailure, equals(failure));
      verify(() => mockRepository.signInWithEmail(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );

  test(
    'should return HifzhError(ValidationFailure) when format is incorrect',
    () async {
      // arrange
      const failure = ValidationFailure(
        'email',
        'صيغة البريد الإلكتروني غير صحيحة',
      );
      when(
        () => mockRepository.signInWithEmail(tEmail, tPassword),
      ).thenAnswer((_) async => const HifzhError(failure));

      // act
      final result = await useCase(email: tEmail, password: tPassword);

      // assert
      expect(result, isA<HifzhError<HifzhUserModel>>());
      final errorFailure = (result as HifzhError<HifzhUserModel>).failure;
      expect(errorFailure, equals(failure));
      verify(() => mockRepository.signInWithEmail(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );
}
