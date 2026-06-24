import 'package:flutter_project/features/transcript/data/database/database_helper.dart';
import 'package:flutter_project/features/transcript/data/datasources/local_pdf_cache_data_source.dart';
import 'package:flutter_project/features/transcript/data/datasources/n8n_remote_data_source.dart';
import 'package:flutter_project/features/transcript/data/network/n8n_dio_client.dart';
import 'package:flutter_project/features/transcript/data/repositories/student_repository.dart';
import 'package:flutter_project/features/transcript/presentation/providers/transcript_provider.dart';

/// Wires transcript data sources and [TranscriptProvider] for the UI layer.
class TranscriptModule {
  TranscriptModule._();

  static StudentRepository? _repository;

  static StudentRepository get repository {
    return _repository ??= StudentRepository(
      local: LocalPdfCacheDataSource(DatabaseHelper.instance),
      remote: N8nRemoteDataSource(N8nDioClient.create()),
    );
  }

  static TranscriptProvider createProvider() {
    return TranscriptProvider(repository);
  }
}
