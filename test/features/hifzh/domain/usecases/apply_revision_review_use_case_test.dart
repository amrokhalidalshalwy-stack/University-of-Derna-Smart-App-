import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/data/repositories/quran_repository.dart';
import 'package:flutter_project/features/hifzh/domain/models/revision_session_model.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/apply_revision_review_use_case.dart';

class MockQuranRepository extends Mock implements QuranRepository {}

void main() {
  late ApplyRevisionReviewUseCase useCase;
  late MockQuranRepository mockRepository;

  setUp(() {
    mockRepository = MockQuranRepository();
    useCase = ApplyRevisionReviewUseCase(mockRepository);
    registerFallbackValue(
      RevisionSessionModel(
        id: 'fallback',
        userUid: 'uid',
        pageNumber: 1,
        surahNumber: 1,
        nextReviewDate: DateTime.now(),
        easeFactor: 2.5,
        intervalDays: 1,
        repetitions: 0,
        lastReviewDate: DateTime.now(),
      ),
    );
  });

  final tSession = RevisionSessionModel(
    id: 'session_1',
    userUid: 'user_123',
    pageNumber: 5,
    surahNumber: 2,
    nextReviewDate: DateTime.now(),
    easeFactor: 2.5,
    intervalDays: 1,
    repetitions: 1,
    lastReviewDate: DateTime.now(),
  );

  test(
    'should return ValidationFailure when quality is not between 0 and 5',
    () async {
      // act & assert
      final resultLow = await useCase(session: tSession, quality: -1);
      expect(resultLow, isA<HifzhError<RevisionSessionModel>>());
      expect(
        (resultLow as HifzhError<RevisionSessionModel>).failure,
        isA<ValidationFailure>(),
      );

      final resultHigh = await useCase(session: tSession, quality: 6);
      expect(resultHigh, isA<HifzhError<RevisionSessionModel>>());
      expect(
        (resultHigh as HifzhError<RevisionSessionModel>).failure,
        isA<ValidationFailure>(),
      );
    },
  );

  group('SM-2 Spaced Repetition Logic Checks', () {
    test(
      'when quality is < 3 (e.g. 2): should reset repetitions to 0, intervalDays to 1, and keep easeFactor unchanged',
      () async {
        // arrange
        when(
          () => mockRepository.saveRevisionSession(any()),
        ).thenAnswer((_) async => const HifzhSuccess(null));

        // act
        final result = await useCase(session: tSession, quality: 2);

        // assert
        expect(result, isA<HifzhSuccess<RevisionSessionModel>>());
        final updated = (result as HifzhSuccess<RevisionSessionModel>).data;
        expect(updated.repetitions, equals(0));
        expect(updated.intervalDays, equals(1));
        expect(updated.easeFactor, equals(2.5));
        verify(() => mockRepository.saveRevisionSession(any())).called(1);
      },
    );

    test(
      'when quality is >= 3 (e.g. 5): should increase repetitions, compute higher interval, and increase easeFactor',
      () async {
        // arrange
        when(
          () => mockRepository.saveRevisionSession(any()),
        ).thenAnswer((_) async => const HifzhSuccess(null));

        // act
        final result = await useCase(session: tSession, quality: 5);

        // assert
        expect(result, isA<HifzhSuccess<RevisionSessionModel>>());
        final updated = (result as HifzhSuccess<RevisionSessionModel>).data;
        expect(updated.repetitions, equals(tSession.repetitions + 1));
        expect(updated.intervalDays, greaterThan(tSession.intervalDays));
        expect(updated.easeFactor, greaterThan(2.5));
        verify(() => mockRepository.saveRevisionSession(any())).called(1);
      },
    );
  });
}
