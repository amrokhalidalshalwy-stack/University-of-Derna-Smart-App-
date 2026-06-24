/// Local implementation of [HalaqahRepository] (Stub for UI testing).
library;

import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/data/repositories/halaqah_repository.dart';
import 'package:flutter_project/features/hifzh/domain/models/halaqah_model.dart';

final _stubHalaqah = HalaqahModel(
  id: 'stub_halaqah_1',
  name: 'حلقة الفجر — جامعة درنة',
  teacherUid: 'teacher_uid',
  createdAt: DateTime(2026, 1, 15),
  inviteCode: 'DERNA24',
  description: 'حلقة لطلاب جامعة درنة — هدفنا حفظ جزء عم هذا الفصل.',
  members: [
    HalaqahMember(
      uid: 'u1',
      displayName: 'عمر خالد',
      role: HalaqahRole.student,
      joinedAt: DateTime(2026, 1, 16),
      pagesThisWeek: 5,
      currentStreak: 14,
      totalPagesMemorized: 47,
    ),
    HalaqahMember(
      uid: 'u2',
      displayName: 'أحمد السنوسي',
      role: HalaqahRole.student,
      joinedAt: DateTime(2026, 1, 17),
      pagesThisWeek: 4,
      currentStreak: 9,
      totalPagesMemorized: 32,
    ),
    HalaqahMember(
      uid: 'u3',
      displayName: 'فاطمة المبروك',
      role: HalaqahRole.student,
      joinedAt: DateTime(2026, 1, 18),
      pagesThisWeek: 6,
      currentStreak: 21,
      totalPagesMemorized: 60,
    ),
    HalaqahMember(
      uid: 'teacher',
      displayName: 'د. محمد الطاهر',
      role: HalaqahRole.teacher,
      joinedAt: DateTime(2026, 1, 15),
      pagesThisWeek: 0,
      currentStreak: 30,
      totalPagesMemorized: 604,
    ),
  ],
);

/// Concrete [HalaqahRepository] using local mock data.
class LocalHalaqahRepositoryImpl implements HalaqahRepository {
  LocalHalaqahRepositoryImpl();

  @override
  Future<HifzhResult<List<HalaqahModel>>> getUserHalaqahs() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return HifzhSuccess([_stubHalaqah]);
  }

  @override
  Future<HifzhResult<HalaqahModel>> joinHalaqah(String inviteCode) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (inviteCode == 'DERNA24') {
      return HifzhSuccess(_stubHalaqah);
    }
    return const HifzhError(ServerFailure('رمز الدعوة غير صحيح'));
  }

  @override
  Future<HifzhResult<HalaqahModel>> createHalaqah(String name) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return HifzhSuccess(
      _stubHalaqah.copyWith(
        name: name,
        id: 'new_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
  }

  @override
  Future<HifzhResult<List<HalaqahMember>>> getLeaderboard(
    String halaqahId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final members = List<HalaqahMember>.from(_stubHalaqah.members);
    members.sort((a, b) => b.pagesThisWeek.compareTo(a.pagesThisWeek));
    return HifzhSuccess(members);
  }
}
