import 'package:logging/logging.dart';
import '../../api/models/resource_name.dart';
import '../../transport/transport_models.dart';
import '../controllers/thing_controller.dart';

class ServerRouter {
  final _logger = Logger('ServerRouter');
  final ThingController _thingController;

  ServerRouter(this._thingController);

  Future<TransportResponse> route(TransportRequest request) async {
    _logger.info('Routing request: ${request.method} ${request.path}');
    
    try {
      final uri = Uri.parse(request.path);
      final path = uri.path;

      if (path == '/things') {
        if (request.method == 'GET') {
          return await _thingController.handleList(uri);
        } else if (request.method == 'POST') {
          return await _thingController.handleCreate(request);
        } else {
          return const TransportResponse(statusCode: 405);
        }
      } else if (path.startsWith('/things/')) {
        ResourceName resourceName;
        try {
          resourceName = ResourceName.parse(path.substring(1));
        } on FormatException {
          return const TransportResponse(statusCode: 400);
        }
        final name = resourceName.toString();
        
        if (request.method == 'GET') {
          return await _thingController.handleGet(name);
        } else if (request.method == 'PATCH') {
          return await _thingController.handleUpdate(name, request, uri);
        } else if (request.method == 'DELETE') {
          return await _thingController.handleDelete(name);
        } else {
          return const TransportResponse(statusCode: 405);
        }
      }

      return const TransportResponse(statusCode: 404);
    } catch (e, stackTrace) {
      _logger.severe('Routing error', e, stackTrace);
      return const TransportResponse(statusCode: 500);
    }
  }
}
