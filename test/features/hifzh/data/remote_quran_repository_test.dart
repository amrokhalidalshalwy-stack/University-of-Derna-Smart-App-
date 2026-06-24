import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/features/hifzh/core/di/hive_init.dart';
import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/data/impl/remote_quran_repository_impl.dart';
import 'package:flutter_project/features/hifzh/domain/models/surah_model.dart';
import 'package:flutter_project/features/hifzh/domain/models/revision_session_model.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response<dynamic> {}

void main() {
  late RemoteQuranRepositoryImpl repository;
  late MockDio mockDio;
  late MockResponse mockResponse;
  late Directory tempDir;

  setUp(() async {
    mockDio = MockDio();
    mockResponse = MockResponse();
    repository = RemoteQuranRepositoryImpl(mockDio);

    tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);

    // Register adapters dynamically if not registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SurahModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(RevisionSessionModelAdapter());
    }

    await Hive.openBox<SurahModel>('surahs');
    await Hive.openBox<RevisionSessionModel>('sessions');
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  final tSurah = SurahModel(
    number: 1,
    nameArabic: 'الفاتحة',
    nameEnglish: 'Al-Fatihah',
    nameTransliteration: 'Al-Fatihah',
    ayahCount: 7,
    revelationType: 'Meccan',
    juzStart: 1,
    pageStart: 1,
    status: MemorizationStatus.notStarted,
    memorizedAyahs: 0,
  );

  final tSession = RevisionSessionModel(
    id: 'session_1',
    userUid: 'user_123',
    pageNumber: 1,
    surahNumber: 1,
    nextReviewDate: DateTime(2026, 5, 20),
    easeFactor: 2.5,
    intervalDays: 1,
    repetitions: 0,
    lastReviewDate: DateTime(2026, 5, 19),
  );

  group('getAllSurahs', () {
    test(
      'should return HifzhSuccess with list when call is successful (200) and cache it',
      () async {
        // arrange
        when(() => mockDio.get(any())).thenAnswer((_) async => mockResponse);
        when(() => mockResponse.data).thenReturn({
          'data': [tSurah.toJson()],
        });

        // act
        final result = await repository.getAllSurahs();

        // assert
        expect(result, isA<HifzhSuccess<List<SurahModel>>>());
        final list = (result as HifzhSuccess<List<SurahModel>>).data;
        expect(list.first.number, equals(1));

        // Verify Hive cache is updated
        final box = Hive.box<SurahModel>('surahs');
        expect(box.get(1)?.nameArabic, equals('الفاتحة'));
      },
    );

    test('should fallback to Hive cache on server failure', () async {
      // arrange: populate Hive cache first
      final box = Hive.box<SurahModel>('surahs');
      await box.put(tSurah.number, tSurah);

      when(() => mockDio.get(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/quran/surahs'),
          type: DioExceptionType.connectionError,
        ),
      );

      // act
      final result = await repository.getAllSurahs();

      // assert
      expect(result, isA<HifzhSuccess<List<SurahModel>>>());
      final list = (result as HifzhSuccess<List<SurahModel>>).data;
      expect(list.length, equals(1));
      expect(list.first.number, equals(1));
    });

    test(
      'should return HifzhError when server fails and cache is empty',
      () async {
        // arrange: cache is empty
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/quran/surahs'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        // act
        final result = await repository.getAllSurahs();

        // assert
        expect(result, isA<HifzhError<List<SurahModel>>>());
        final failure = (result as HifzhError<List<SurahModel>>).failure;
        expect(failure, isA<NetworkFailure>());
      },
    );
  });

  group('updateMemorizationStatus', () {
    test(
      'should send PATCH request with correct status and return success',
      () async {
        // arrange
        when(
          () => mockDio.patch(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => mockResponse);
        when(() => mockResponse.data).thenReturn({});

        // act
        final result = await repository.updateMemorizationStatus(
          1,
          MemorizationStatus.memorized,
        );

        // assert
        expect(result, isA<HifzhSuccess<void>>());
        verify(
          () => mockDio.patch(
            '/api/quran/surahs/1/status',
            data: {'status': 'memorized'},
          ),
        ).called(1);
      },
    );
  });

  group('getDueSessions', () {
    test(
      'should return HifzhSuccess with list when successful (200) and cache them',
      () async {
        // arrange
        when(() => mockDio.get(any())).thenAnswer((_) async => mockResponse);
        when(() => mockResponse.data).thenReturn({
          'data': [tSession.toJson()],
        });

        // act
        final result = await repository.getDueSessions();

        // assert
        expect(result, isA<HifzhSuccess<List<RevisionSessionModel>>>());
        final list = (result as HifzhSuccess<List<RevisionSessionModel>>).data;
        expect(list.first.id, equals('session_1'));

        final box = Hive.box<RevisionSessionModel>('sessions');
        expect(box.get('session_1')?.pageNumber, equals(1));
      },
    );
  });
}
