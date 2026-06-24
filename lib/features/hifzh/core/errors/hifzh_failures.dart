/// Domain-level failure types for HifdhTracker.
///
/// Sealed hierarchy eliminates unhandled error cases at compile time.
/// Use [HifzhResult] as the return type for all repository & use-case methods.
library;

// ── Failures ──────────────────────────────────────────────────────────────────

/// Base class for all HifdhTracker domain failures.
sealed class HifzhFailure {
  const HifzhFailure(this.message);
  final String message;
}

/// Remote server returned a non-2xx response.
final class ServerFailure extends HifzhFailure {
  const ServerFailure(super.message, {this.statusCode});
  final int? statusCode;
}

/// Device has no internet connectivity.
final class NetworkFailure extends HifzhFailure {
  const NetworkFailure() : super('لا يوجد اتصال بالإنترنت');
}

/// Local cache read/write failure.
final class CacheFailure extends HifzhFailure {
  const CacheFailure(super.message);
}

/// Authentication-specific failure (wrong password, user not found, etc.).
final class AuthFailure extends HifzhFailure {
  const AuthFailure(super.message);
}

/// Client-side input validation failure.
final class ValidationFailure extends HifzhFailure {
  const ValidationFailure(this.field, String message) : super(message);

  /// The name of the invalid field (e.g. 'email', 'password').
  final String field;
}

// ── Result type ───────────────────────────────────────────────────────────────

/// A discriminated union of success and failure — avoids adding dartz/fpdart.
sealed class HifzhResult<T> {
  const HifzhResult();

  /// Returns [true] if this is a [HifzhSuccess].
  bool get isSuccess => this is HifzhSuccess<T>;

  /// Returns [true] if this is a [HifzhError].
  bool get isError => this is HifzhError<T>;

  /// Runs [onSuccess] or [onError] and returns their result.
  R fold<R>(
    R Function(T data) onSuccess,
    R Function(HifzhFailure failure) onError,
  ) {
    return switch (this) {
      HifzhSuccess<T>(:final data) => onSuccess(data),
      HifzhError<T>(:final failure) => onError(failure),
    };
  }
}

/// Represents a successful operation carrying [data].
final class HifzhSuccess<T> extends HifzhResult<T> {
  const HifzhSuccess(this.data);
  final T data;
}

/// Represents a failed operation carrying a [HifzhFailure].
final class HifzhError<T> extends HifzhResult<T> {
  const HifzhError(this.failure);
  final HifzhFailure failure;
}
