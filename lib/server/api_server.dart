import 'package:logging/logging.dart';
import '../transport/transport_models.dart';
import 'controllers/thing_controller.dart';
import 'data/resource_storage.dart';
import 'router/server_router.dart';

class ApiServer {
  final _logger = Logger('ApiServer');
  
  late final ThingController _thingController;
  late final ServerRouter _router;

  ApiServer({
    required ResourceStorage storage,
  }) {
    _thingController = ThingController(storage);
    _router = ServerRouter(_thingController);
    _logger.info('ApiServer initialized with dependencies');
  }

  Future<TransportResponse> handleRequest(TransportRequest request) async {
    return _router.route(request);
  }
}
