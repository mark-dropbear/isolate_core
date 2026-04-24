import 'package:logging/logging.dart';
import '../transport/transport_models.dart';
import 'controllers/thing_controller.dart';
import 'controllers/task_controller.dart';
import 'controllers/task_list_controller.dart';
import 'controllers/person_controller.dart';
import 'controllers/organization_controller.dart';
import 'data/resource_storage.dart';
import 'router/server_router.dart';

class ApiServer {
  final _logger = Logger('ApiServer');

  late final ThingController _thingController;
  late final TaskController _taskController;
  late final TaskListController _taskListController;
  late final PersonController _personController;
  late final OrganizationController _organizationController;
  late final ServerRouter _router;

  ApiServer({required ResourceStorage storage}) {
    _thingController = ThingController(storage);
    _taskController = TaskController(storage);
    _taskListController = TaskListController(storage);
    _personController = PersonController(storage);
    _organizationController = OrganizationController(storage);
    _router = ServerRouter(
      _thingController,
      _taskController,
      _taskListController,
      _personController,
      _organizationController,
    );
    _logger.info('ApiServer initialized with dependencies');
  }

  Future<TransportResponse> handleRequest(TransportRequest request) async {
    return _router.route(request);
  }
}
