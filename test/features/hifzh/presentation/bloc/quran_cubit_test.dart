import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/domain/models/surah_model.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/get_all_surahs_use_case.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/update_memorization_status_use_case.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/quran/quran_cubit.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/quran/quran_state.dart';

class MockGetAllSurahsUseCase extends Mock implements GetAllSurahsUseCase {}

class MockUpdateMemorizationStatusUseCase extends Mock
    implements UpdateMemorizationStatusUseCase {}

void main() {
  late QuranCubit cubit;
  late MockGetAllSurahsUseCase mockGetAllSurahs;
  late MockUpdateMemorizationStatusUseCase mockUpdateStatus;

  final tSurahs = [
    const SurahModel(
      number: 1,
      nameArabic: 'الفاتحة',
      nameEnglish: 'Al-Fatihah',
      nameTransliteration: 'Al-Fatihah',
      ayahCount: 7,
      revelationType: 'Meccan',
      juzStart: 1,
      pageStart: 1,
      status: MemorizationStatus.mastered,
      memorizedAyahs: 7,
    ),
    const SurahModel(
      number: 2,
      nameArabic: 'البقرة',
      nameEnglish: 'Al-Baqarah',
      nameTransliteration: 'Al-Baqarah',
      ayahCount: 286,
      revelationType: 'Medinan',
      juzStart: 1,
      pageStart: 2,
      status: MemorizationStatus.inProgress,
      memorizedAyahs: 10,
    ),
  ];

  setUp(() {
    mockGetAllSurahs = MockGetAllSurahsUseCase();
    mockUpdateStatus = MockUpdateMemorizationStatusUseCase();
    cubit = QuranCubit(
      getAllSurahs: mockGetAllSurahs,
      updateStatus: mockUpdateStatus,
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state should be QuranInitial', () {
    expect(cubit.state, isA<QuranInitial>());
  });

  group('loadSurahs', () {
    blocTest<QuranCubit, QuranState>(
      'emits [QuranLoading, QuranLoaded] when loadSurahs is successful',
      build: () {
        when(
          () => mockGetAllSurahs(),
        ).thenAnswer((_) async => HifzhSuccess(tSurahs));
        return cubit;
      },
      act: (cubit) => cubit.loadSurahs(),
      expect:
          () => [
            isA<QuranLoading>(),
            isA<QuranLoaded>().having(
              (s) => s.surahs,
              'surahs',
              equals(tSurahs),
            ),
          ],
    );

    blocTest<QuranCubit, QuranState>(
      'emits [QuranLoading, QuranError] when loadSurahs fails',
      build: () {
        when(() => mockGetAllSurahs()).thenAnswer(
          (_) async => const HifzhError(CacheFailure('خطأ في القراءة')),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadSurahs(),
      expect: () => [isA<QuranLoading>(), isA<QuranError>()],
    );
  });

  group('filterByStatus', () {
    blocTest<QuranCubit, QuranState>(
      'filters surahs and emits QuranLoaded with active filter',
      build: () {
        when(
          () => mockGetAllSurahs(),
        ).thenAnswer((_) async => HifzhSuccess(tSurahs));
        return cubit;
      },
      act: (cubit) async {
        await cubit.loadSurahs();
        cubit.filterByStatus(MemorizationStatus.mastered);
      },
      skip: 2, // Skip loadSurahs's loading and loaded states
      expect:
          () => [
            isA<QuranLoaded>()
                .having((s) => s.surahs.length, 'length', equals(1))
                .having((s) => s.surahs.first.number, 'number', equals(1))
                .having(
                  (s) => s.filter,
                  'filter',
                  equals(MemorizationStatus.mastered),
                ),
          ],
    );
  });

  group('searchSurahs', () {
    blocTest<QuranCubit, QuranState>(
      'searches surahs and emits QuranLoaded matching text search',
      build: () {
        when(
          () => mockGetAllSurahs(),
        ).thenAnswer((_) async => HifzhSuccess(tSurahs));
        return cubit;
      },
      act: (cubit) async {
        await cubit.loadSurahs();
        cubit.searchSurahs('البقرة');
      },
      skip: 2, // Skip loadSurahs's states
      expect:
          () => [
            isA<QuranLoaded>()
                .having((s) => s.surahs.length, 'length', equals(1))
                .having((s) => s.surahs.first.number, 'number', equals(2)),
          ],
    );
  });
}
