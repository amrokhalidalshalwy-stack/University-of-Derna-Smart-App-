import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/features/academic/data/academic_records_repository.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';

const _functionsRegion = 'europe-west1';

final academicRecordsRepositoryProvider = Provider<AcademicRecordsRepository>((
  ref,
) {
  return AcademicRecordsRepository(
    ref.watch(firestoreProvider),
    FirebaseFunctions.instanceFor(region: _functionsRegion),
  );
});

final academicSyncProvider = AsyncNotifierProvider<AcademicSyncNotifier, void>(
  AcademicSyncNotifier.new,
);

class AcademicSyncNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<AcademicSyncResult> sync() async {
    state = const AsyncLoading();
    final result =
        await ref.read(academicRecordsRepositoryProvider).requestSync();
    if (result.success) {
      state = const AsyncData(null);
    } else {
      state = AsyncError(result.message ?? 'Sync failed', StackTrace.current);
    }
    return result;
  }
}
