import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/data/repositories/auth_repository.dart';
import 'package:flutter_project/features/hifzh/domain/models/user_model.dart';

class RemoteAuthRepositoryImpl implements HifzhAuthRepository {
  RemoteAuthRepositoryImpl(
    this._dio, [
    this._storage = const FlutterSecureStorage(),
  ]);

  final Dio _dio;
  final FlutterSecureStorage _storage;

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
        return const AuthFailure('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      } else if (status == 404) {
        return const CacheFailure('الخادم غير موجود');
      } else if (status == 500) {
        return const ServerFailure('خطأ في الخادم الداخلي', statusCode: 500);
      }
      final msg =
          response.data is Map
              ? response.data['message'] ?? response.statusMessage
              : response.statusMessage;
      return AuthFailure(msg ?? 'حدث خطأ في المصادقة');
    }
    return const NetworkFailure();
  }

  @override
  Future<HifzhResult<HifzhUserModel>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = response.data;
      if (data is Map<String, dynamic> &&
          data['token'] != null &&
          data['user'] != null) {
        final token = data['token'] as String;
        final userMap = data['user'] as Map<String, dynamic>;
        final user = HifzhUserModel.fromJson(userMap);

        // Save token to secure storage
        await _storage.write(key: 'auth_token', value: token);

        // Save UserModel to Hive user_prefs box
        final box = Hive.box('user_prefs');
        await box.put('current_user', user);

        return HifzhSuccess(user);
      }
      return const HifzhError(AuthFailure('استجابة غير صالحة من الخادم'));
    } on DioException catch (e) {
      return HifzhError(_mapDioException(e));
    } catch (e) {
      return HifzhError(ServerFailure('خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<HifzhResult<HifzhUserModel>> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: {'email': email, 'password': password},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['user'] != null) {
        final userMap = data['user'] as Map<String, dynamic>;
        final user = HifzhUserModel.fromJson(userMap);

        // If register also returns token, persist it immediately
        if (data['token'] != null) {
          final token = data['token'] as String;
          await _storage.write(key: 'auth_token', value: token);

          final box = Hive.box('user_prefs');
          await box.put('current_user', user);
        }

        return HifzhSuccess(user);
      }
      return const HifzhError(AuthFailure('استجابة غير صالحة من الخادم'));
    } on DioException catch (e) {
      return HifzhError(_mapDioException(e));
    } catch (e) {
      return HifzhError(ServerFailure('خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<HifzhResult<void>> signOut() async {
    try {
      await _dio.post('/api/auth/logout');
    } catch (_) {
      // Best effort to hit API logout endpoint, proceed to clear local state
    }

    try {
      await _storage.delete(key: 'auth_token');
      final box = Hive.box('user_prefs');
      await box.delete('current_user');
      return const HifzhSuccess(null);
    } catch (e) {
      return HifzhError(CacheFailure('فشل مسح بيانات الجلسة: $e'));
    }
  }

  @override
  Future<HifzhResult<void>> sendPasswordResetEmail(String email) async {
    try {
      await _dio.post('/api/auth/forgot-password', data: {'email': email});
      return const HifzhSuccess(null);
    } on DioException catch (e) {
      return HifzhError(_mapDioException(e));
    } catch (e) {
      return HifzhError(ServerFailure('فشل إرسال البريد: $e'));
    }
  }

  @override
  Stream<HifzhUserModel?> get authStateChanges async* {
    final box = Hive.box('user_prefs');
    final initial = box.get('current_user');
    if (initial is HifzhUserModel) {
      yield initial;
    } else {
      yield null;
    }
    yield* box.watch(key: 'current_user').map((event) {
      final val = event.value;
      if (val is HifzhUserModel) return val;
      return null;
    });
  }
}
