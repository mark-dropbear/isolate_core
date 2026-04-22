import 'package:logging/logging.dart';
import '../../transport/transport_client.dart';
import '../../transport/transport_models.dart';

class DebugApiService {
  final _logger = Logger('DebugApiService');
  final TransportClient _client;

  DebugApiService(this._client);

  Future<String> fetchDatasetDump() async {
    _logger.info('fetchDatasetDump()');
    final response = await _client.send(
      TransportRequest(method: 'GET', path: '/debug/dump'),
    );

    if (response.statusCode == 200) {
      return response.body ?? '';
    } else {
      _logger.warning('fetchDatasetDump failed: ${response.statusCode}');
      throw Exception('Failed to fetch dataset dump: ${response.statusCode}');
    }
  }
}
