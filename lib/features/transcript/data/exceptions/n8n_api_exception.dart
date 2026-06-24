/// User-facing error from the n8n transcript webhook.
class N8nApiException implements Exception {
  N8nApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
