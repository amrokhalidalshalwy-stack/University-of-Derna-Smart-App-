import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/services/integration_service.dart';

/// Provides a singleton instance of [IntegrationService] throughout the app.
final integrationServiceProvider = Provider<IntegrationService>((ref) {
  return IntegrationService();
});
