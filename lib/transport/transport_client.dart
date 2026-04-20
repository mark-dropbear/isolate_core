import 'transport_models.dart';

abstract class TransportClient {
  Future<TransportResponse> send(TransportRequest request);

  Future<void> initialize();

  void dispose();
}
