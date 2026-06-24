import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/data/repositories/halaqah_repository.dart';
import 'package:flutter_project/features/hifzh/domain/models/halaqah_model.dart';

class RemoteHalaqahRepositoryImpl implements HalaqahRepository {
  RemoteHalaqahRepositoryImpl(this._dio);

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
  Future<HifzhResult<List<HalaqahModel>>> getUserHalaqahs() async {
    try {
      final response = await _dio.get('/api/halaqah');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        final list =
            (data['data'] as List)
                .map((e) => HalaqahModel.fromJson(e as Map<String, dynamic>))
                .toList();

        // Cache on success
        final box = Hive.box<HalaqahModel>('halaqahs');
        await box.clear();
        for (final h in list) {
          await box.put(h.id, h);
        }
        return HifzhSuccess(list);
      }
      throw DioException(
        requestOptions: RequestOptions(path: '/api/halaqah'),
        message: 'Invalid response format',
      );
    } catch (e) {
      // Fallback to Hive cache
      final box = Hive.box<HalaqahModel>('halaqahs');
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
  Future<HifzhResult<HalaqahModel>> joinHalaqah(String inviteCode) async {
    try {
      final response = await _dio.post(
        '/api/halaqah/join',
        data: {'code': inviteCode},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        final halaqah = HalaqahModel.fromJson(
          data['data'] as Map<String, dynamic>,
        );
        return HifzhSuccess(halaqah);
      }
      throw DioException(
        requestOptions: RequestOptions(path: '/api/halaqah/join'),
        message: 'Invalid response format',
      );
    } on DioException catch (e) {
      return HifzhError(_mapDioException(e));
    } catch (e) {
      return HifzhError(ServerFailure(e.toString()));
    }
  }

  @override
  Future<HifzhResult<HalaqahModel>> createHalaqah(String name) async {
    try {
      final response = await _dio.post('/api/halaqah', data: {'name': name});
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        final halaqah = HalaqahModel.fromJson(
          data['data'] as Map<String, dynamic>,
        );
        return HifzhSuccess(halaqah);
      }
      throw DioException(
        requestOptions: RequestOptions(path: '/api/halaqah'),
        message: 'Invalid response format',
      );
    } on DioException catch (e) {
      return HifzhError(_mapDioException(e));
    } catch (e) {
      return HifzhError(ServerFailure(e.toString()));
    }
  }

  @override
  Future<HifzhResult<List<HalaqahMember>>> getLeaderboard(
    String halaqahId,
  ) async {
    try {
      final response = await _dio.get('/api/halaqah/$halaqahId/leaderboard');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        final list =
            (data['data'] as List)
                .map((e) => HalaqahMember.fromJson(e as Map<String, dynamic>))
                .toList();
        return HifzhSuccess(list);
      }
      throw DioException(
        requestOptions: RequestOptions(
          path: '/api/halaqah/$halaqahId/leaderboard',
        ),
        message: 'Invalid response format',
      );
    } on DioException catch (e) {
      return HifzhError(_mapDioException(e));
    } catch (e) {
      return HifzhError(ServerFailure(e.toString()));
    }
  }
}
