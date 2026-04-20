import 'package:logging/logging.dart';
import '../api/models/vocab.dart';
import '../transport/transport_models.dart';
import 'controllers/standard_resource_controller.dart';
import 'data/resource_storage.dart';
import 'router/server_router.dart';

class ApiServer {
  final _logger = Logger('ApiServer');

  late final StandardResourceController _thingController;
  late final ServerRouter _router;

  ApiServer({required ResourceStorage storage}) {
    _thingController = StandardResourceController(
      storage: storage,
      collectionName: 'things',
      resourceClass: Vocab.thingClass,
      fieldMapper: Vocab.mapFieldsToPredicates,
    );
    _router = ServerRouter(thingController: _thingController);
    _logger.info('ApiServer initialized with dependencies');
  }

  Future<TransportResponse> handleRequest(TransportRequest request) async {
    return _router.route(request);
  }
}
