import 'dart:isolate';
import 'dart:developer' as developer;
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:logging/logging.dart';

import '../transport/transport_models.dart';
import 'api_server.dart';
import 'data/file_thing_storage.dart';

class IsolateServerMessage {
  final String id;
  final TransportRequest request;
  final SendPort responsePort;

  IsolateServerMessage({
    required this.id,
    required this.request,
    required this.responsePort,
  });
}

void isolateServerEntry(SendPort mainSendPort) {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    developer.log(
      record.message,
      time: record.time,
      sequenceNumber: record.sequenceNumber,
      level: record.level.value,
      name: record.loggerName,
      zone: record.zone,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  });

  final logger = Logger('IsolateServer');
  logger.info('Worker isolate started');

  final workerReceivePort = ReceivePort();
  mainSendPort.send(workerReceivePort.sendPort);

  // Initialize Backend Layers
  final FileSystem fs = MemoryFileSystem();
  final dataFile = fs.file('/things.json');
  final storage = FileThingStorage(dataFile);
  
  final apiServer = ApiServer(storage: storage);

  workerReceivePort.listen((message) async {
    if (message is IsolateServerMessage) {
      final response = await apiServer.handleRequest(message.request);
      logger.info('Sending response [${message.id}]: ${response.statusCode}');
      message.responsePort.send(response);
    }
  });
}
