/// Thrown when the n8n request fails but a cached PDF URL is available.
///
/// The UI should treat this as success with [cachedPdfUrl] and show an offline warning.
class OfflineFallbackException implements Exception {
  OfflineFallbackException(this.cachedPdfUrl);

  final String cachedPdfUrl;

  @override
  String toString() =>
      'OfflineFallbackException(cachedPdfUrl: ${cachedPdfUrl.length > 48 ? '${cachedPdfUrl.substring(0, 48)}...' : cachedPdfUrl})';
}
