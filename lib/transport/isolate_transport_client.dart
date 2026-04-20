import 'dart:async';
import 'dart:isolate';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import 'transport_client.dart';
import 'transport_models.dart';
import '../server/isolate_server.dart';

class IsolateTransportClient implements TransportClient {
  final _logger = Logger('IsolateTransportClient');

  late SendPort _workerSendPort;
  final ReceivePort _mainReceivePort = ReceivePort();
  Isolate? _isolate;
  final Completer<void> _initCompleter = Completer<void>();

  @override
  Future<void> initialize() async {
    _logger.info('Initializing isolate server...');
    _isolate = await Isolate.spawn(isolateServerEntry, _mainReceivePort.sendPort);

    _mainReceivePort.listen((message) {
      if (message is SendPort) {
        _logger.info('Received worker SendPort, initialization complete');
        _workerSendPort = message;
        if (!_initCompleter.isCompleted) {
          _initCompleter.complete();
        }
      }
    });

    return _initCompleter.future;
  }

  @override
  Future<TransportResponse> send(TransportRequest request) async {
    await _initCompleter.future;

    final responsePort = ReceivePort();
    final requestId = const Uuid().v4();
    
    _logger.fine('Sending request [$requestId]: ${request.method} ${request.path}');

    final message = IsolateServerMessage(
      id: requestId,
      request: request,
      responsePort: responsePort.sendPort,
    );

    _workerSendPort.send(message);

    final response = await responsePort.first as TransportResponse;
    _logger.fine('Received response [$requestId]: ${response.statusCode}');
    responsePort.close();
    
    return response;
  }

  @override
  void dispose() {
    _mainReceivePort.close();
    _isolate?.kill();
  }
}
