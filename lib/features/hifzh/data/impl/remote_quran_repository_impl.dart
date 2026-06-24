import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/data/repositories/quran_repository.dart';
import 'package:flutter_project/features/hifzh/domain/models/surah_model.dart';
import 'package:flutter_project/features/hifzh/domain/models/revision_session_model.dart';

class RemoteQuranRepositoryImpl implements QuranRepository {
  RemoteQuranRepositoryImpl(this._dio);

  final Dio _dio;

  HifzhFailure _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const NetworkFailure();
    }
    final response = e.response;
    if (response != null) {
      final status = response.statusCode;
      if (status == 401) {
        return const AuthFailure('Unauthorized');
      } else if (status == 404) {
        return const CacheFailure('Not found');
      } else if (status == 500) {
        return const ServerFailure('Server error', statusCode: 500);
      }
      final msg =
          response.data is Map
              ? response.data['message'] ?? response.statusMessage
              : response.statusMessage;
      return ServerFailure(msg ?? 'Server error', statusCode: status);
    }
    return const NetworkFailure();
  }

  @override
  Future<HifzhResult<List<SurahModel>>> getAllSurahs() async {
    try {
      final response = await _dio.get('/api/quran/surahs');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        final list =
            (data['data'] as List)
                .map((e) => SurahModel.fromJson(e as Map<String, dynamic>))
                .toList();

        // Update local Hive box
        final box = Hive.box<SurahModel>('surahs');
        await box.clear();
        for (final s in list) {
          await box.put(s.number, s);
        }
        return HifzhSuccess(list);
      }
      throw DioException(
        requestOptions: RequestOptions(path: '/api/quran/surahs'),
        message: 'Invalid response format',
      );
    } catch (e) {
      // Fallback to Hive cache
      final box = Hive.box<SurahModel>('surahs');
      if (box.isNotEmpty) {
        return HifzhSuccess(box.values.toList());
      }
      if (e is DioException) {
        return HifzhError(_mapDioException(e));
      }
      return HifzhError(
        CacheFailure('فشل الاتصال بالخادم والذاكرة المؤقتة فارغة: $e'),
      );
    }
  }

  @override
  Future<HifzhResult<SurahModel>> getSurahById(int id) async {
    try {
      final response = await _dio.get('/api/quran/surahs/$id');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        final surah = SurahModel.fromJson(data['data'] as Map<String, dynamic>);
        final box = Hive.box<SurahModel>('surahs');
        await box.put(surah.number, surah);
        return HifzhSuccess(surah);
      }
      throw DioException(
        requestOptions: RequestOptions(path: '/api/quran/surahs/$id'),
        message: 'Invalid response format',
      );
    } catch (e) {
      final box = Hive.box<SurahModel>('surahs');
      final cached = box.get(id);
      if (cached != null) {
        return HifzhSuccess(cached);
      }
      if (e is DioException) {
        return HifzhError(_mapDioException(e));
      }
      return HifzhError(
        CacheFailure('السورة رقم $id غير موجودة في الذاكرة المؤقتة: $e'),
      );
    }
  }

  @override
  Future<HifzhResult<void>> updateMemorizationStatus(
    int surahId,
    MemorizationStatus status,
  ) async {
    // Optimistic Update local Hive cache
    final box = Hive.box<SurahModel>('surahs');
    final cached = box.get(surahId);
    if (cached != null) {
      await box.put(surahId, cached.copyWith(status: status));
    }

    try {
      await _dio.patch(
        '/api/quran/surahs/$surahId/status',
        data: {'status': status.name},
      );
      return const HifzhSuccess(null);
    } on DioException catch (e) {
      return HifzhError(_mapDioException(e));
    } catch (e) {
      return HifzhError(ServerFailure(e.toString()));
    }
  }

  @override
  Future<HifzhResult<List<RevisionSessionModel>>> getDueSessions() async {
    try {
      final response = await _dio.get('/api/quran/sessions/due');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        final list =
            (data['data'] as List)
                .map(
                  (e) =>
                      RevisionSessionModel.fromJson(e as Map<String, dynamic>),
                )
                .toList();

        final box = Hive.box<RevisionSessionModel>('sessions');
        await box.clear();
        for (final s in list) {
          await box.put(s.id, s);
        }
        return HifzhSuccess(list);
      }
      throw DioException(
        requestOptions: RequestOptions(path: '/api/quran/sessions/due'),
        message: 'Invalid response format',
      );
    } catch (e) {
      final box = Hive.box<RevisionSessionModel>('sessions');
      if (box.isNotEmpty) {
        return HifzhSuccess(box.values.toList());
      }
      if (e is DioException) {
        return HifzhError(_mapDioException(e));
      }
      return HifzhError(
        CacheFailure('فشل الاتصال بالخادم والذاكرة المؤقتة فارغة: $e'),
      );
    }
  }

  @override
  Future<HifzhResult<void>> saveRevisionSession(
    RevisionSessionModel session,
  ) async {
    // Optimistic Update Hive cache
    final box = Hive.box<RevisionSessionModel>('sessions');
    await box.put(session.id, session);

    try {
      await _dio.post('/api/quran/sessions', data: session.toJson());
      return const HifzhSuccess(null);
    } on DioException catch (e) {
      return HifzhError(_mapDioException(e));
    } catch (e) {
      return HifzhError(ServerFailure(e.toString()));
    }
  }
}
