import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_project/features/hifzh/core/di/hive_init.dart';
import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/data/impl/remote_auth_repository_impl.dart';
import 'package:flutter_project/features/hifzh/domain/models/user_model.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response<dynamic> {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late RemoteAuthRepositoryImpl repository;
  late MockDio mockDio;
  late MockResponse mockResponse;
  late MockFlutterSecureStorage mockSecureStorage;
  late Directory tempDir;

  setUp(() async {
    mockDio = MockDio();
    mockResponse = MockResponse();
    mockSecureStorage = MockFlutterSecureStorage();
    repository = RemoteAuthRepositoryImpl(mockDio, mockSecureStorage);

    tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    await Hive.openBox('user_prefs');
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = HifzhUserModel(
    uid: 'user_123',
    email: tEmail,
    displayName: 'Test User',
  );

  group('signInWithEmail', () {
    test(
      'should return HifzhSuccess with HifzhUserModel on success (200) and save token/profile',
      () async {
        // arrange
        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => mockResponse);
        when(
          () => mockResponse.data,
        ).thenReturn({'token': 'mock_jwt_token', 'user': tUser.toJson()});
        when(
          () => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async => {});

        // act
        final result = await repository.signInWithEmail(tEmail, tPassword);

        // assert
        expect(result, isA<HifzhSuccess<HifzhUserModel>>());
        final user = (result as HifzhSuccess<HifzhUserModel>).data;
        expect(user.uid, equals('user_123'));
        expect(user.email, equals(tEmail));

        // Check secure storage was called
        verify(
          () => mockSecureStorage.write(
            key: 'auth_token',
            value: 'mock_jwt_token',
          ),
        ).called(1);

        // Check Hive cache has current user profile saved
        final box = Hive.box('user_prefs');
        expect(
          (box.get('current_user') as HifzhUserModel).displayName,
          equals('Test User'),
        );
      },
    );

    test(
      'should return HifzhError with AuthFailure on unauthorized (401)',
      () async {
        // arrange
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/auth/login'),
            response: Response(
              requestOptions: RequestOptions(path: '/api/auth/login'),
              statusCode: 401,
              data: {'message': 'البريد الإلكتروني أو كلمة المرور غير صحيحة'},
            ),
          ),
        );

        // act
        final result = await repository.signInWithEmail(tEmail, tPassword);

        // assert
        expect(result, isA<HifzhError<HifzhUserModel>>());
        final failure = (result as HifzhError<HifzhUserModel>).failure;
        expect(failure, isA<AuthFailure>());
        expect(
          failure.message,
          equals('البريد الإلكتروني أو كلمة المرور غير صحيحة'),
        );
      },
    );
  });

  group('signOut', () {
    test(
      'should clear secure storage token and user preferences box',
      () async {
        // arrange: populate Hive cache first
        final box = Hive.box('user_prefs');
        await box.put('current_user', tUser);

        when(() => mockDio.post(any())).thenAnswer((_) async => mockResponse);
        when(() => mockResponse.data).thenReturn({});
        when(
          () => mockSecureStorage.delete(key: any(named: 'key')),
        ).thenAnswer((_) async => {});

        // act
        final result = await repository.signOut();

        // assert
        expect(result, isA<HifzhSuccess<void>>());
        verify(() => mockSecureStorage.delete(key: 'auth_token')).called(1);

        // Verify Hive is cleared
        expect(box.get('current_user'), isNull);
      },
    );
  });

  group('sendPasswordResetEmail', () {
    test(
      'should send POST request to forgot-password with correct email',
      () async {
        // arrange
        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => mockResponse);
        when(() => mockResponse.data).thenReturn({});

        // act
        final result = await repository.sendPasswordResetEmail(tEmail);

        // assert
        expect(result, isA<HifzhSuccess<void>>());
        verify(
          () => mockDio.post(
            '/api/auth/forgot-password',
            data: {'email': tEmail},
          ),
        ).called(1);
      },
    );
  });
}
