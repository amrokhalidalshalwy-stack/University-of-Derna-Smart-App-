import 'package:flutter_project/features/transcript/data/datasources/local_pdf_cache_data_source.dart';
import 'package:flutter_project/features/transcript/data/datasources/n8n_remote_data_source.dart';
import 'package:flutter_project/features/transcript/data/exceptions/offline_fallback_exception.dart';
import 'package:flutter_project/features/transcript/data/repositories/student_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalPdfCache extends Mock implements LocalPdfCacheDataSource {}
class MockN8nRemote extends Mock implements N8nRemoteDataSource {}

void main() {
  late MockLocalPdfCache mockLocal;
  late MockN8nRemote mockRemote;
  late StudentRepository repository;

  setUp(() {
    mockLocal = MockLocalPdfCache();
    mockRemote = MockN8nRemote();
    repository = StudentRepository(local: mockLocal, remote: mockRemote);
  });

  group('StudentRepository Tests', () {
    test('getPdfUrl returns cached url if available and forceRefresh is false (Happy Path)', () async {
      when(() => mockLocal.getCachedPdf('student_123', 'Fall 2023'))
          .thenAnswer((_) async => CachedPdfEntry(studentId: 'student_123', semester: 'Fall 2023', pdfUrl: 'https://cached.pdf', cachedAt: DateTime.now().millisecondsSinceEpoch));

      final url = await repository.getPdfUrl('student_123', 'Fall 2023');

      expect(url, 'https://cached.pdf');
      verifyNever(() => mockRemote.generatePdf(any(), any()));
    });

    test('getPdfUrl fetches from remote and caches it if cache is empty (Happy Path)', () async {
      when(() => mockLocal.getCachedPdf('student_123', 'Fall 2023'))
          .thenAnswer((_) async => null);
      when(() => mockRemote.generatePdf('student_123', 'Fall 2023'))
          .thenAnswer((_) async => 'https://remote.pdf');
      when(() => mockLocal.savePdfUrl('student_123', 'Fall 2023', 'https://remote.pdf'))
          .thenAnswer((_) async => 1);

      final url = await repository.getPdfUrl('student_123', 'Fall 2023');

      expect(url, 'https://remote.pdf');
      verify(() => mockLocal.savePdfUrl('student_123', 'Fall 2023', 'https://remote.pdf')).called(1);
    });

    test('getPdfUrl throws OfflineFallbackException if remote fails and cache exists (Failure Path)', () async {
      when(() => mockLocal.getCachedPdf('student_123', 'Fall 2023'))
          .thenAnswer((_) async => null); // First time it tries to get cache, returns null
          
      // Wait, the repository logic calls it twice:
      // First at the beginning (if not forceRefresh) -> we can return null to force remote call
      // Then in the catch block it calls it again -> we return the cached pdf
      int callCount = 0;
      when(() => mockLocal.getCachedPdf('student_123', 'Fall 2023'))
          .thenAnswer((_) async {
            callCount++;
            if (callCount == 1) return null;
            return CachedPdfEntry(studentId: 'student_123', semester: 'Fall 2023', pdfUrl: 'https://old-cached.pdf', cachedAt: DateTime.now().millisecondsSinceEpoch);
          });

      when(() => mockRemote.generatePdf('student_123', 'Fall 2023'))
          .thenThrow(Exception('Network Error'));

      expect(
        () => repository.getPdfUrl('student_123', 'Fall 2023'),
        throwsA(isA<OfflineFallbackException>()),
      );
    });
  });
}
