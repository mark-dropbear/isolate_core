import 'package:isolate_core/data/services/debug_api_service.dart';
import 'package:isolate_core/transport/transport_client.dart';
import 'package:isolate_core/transport/transport_models.dart';

class FakeTransportClient implements TransportClient {
  @override
  Future<void> initialize() async {}

  @override
  Future<TransportResponse> send(TransportRequest request) async {
    return const TransportResponse(statusCode: 200, body: '<dataset>');
  }
  
  @override
  void dispose() {}
}

class FakeDebugApiService extends DebugApiService {
  FakeDebugApiService() : super(FakeTransportClient());

  @override
  Future<String> fetchDatasetDump() async {
    return '<dataset dump>';
  }
}
