import 'package:logging/logging.dart';
import '../../api/models/resource_name.dart';
import '../../transport/transport_models.dart';
import '../controllers/thing_controller.dart';
import '../controllers/task_controller.dart';
import '../controllers/task_list_controller.dart';
import '../controllers/person_controller.dart';
import '../controllers/organization_controller.dart';

class ServerRouter {
  final _logger = Logger('ServerRouter');
  final ThingController _thingController;
  final TaskController _taskController;
  final TaskListController _taskListController;
  final PersonController _personController;
  final OrganizationController _organizationController;

  ServerRouter(
    this._thingController,
    this._taskController,
    this._taskListController,
    this._personController,
    this._organizationController,
  );

  Future<TransportResponse> route(TransportRequest request) async {
    _logger.info('Routing request: ${request.method} ${request.path}');

    try {
      final uri = Uri.parse(request.path);
      // Clean path segments to ignore empty ones (e.g., from trailing slashes)
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();

      return await switch ((request.method, segments)) {
        // --- Debug ---
        ('GET', ['debug', 'dump']) => _taskListController.handleDump(),

        // --- Things ---
        ('GET', ['things']) => _thingController.handleList(uri),
        ('POST', ['things']) => _thingController.handleCreate(request),
        (final method, ['things', ...final rest]) when rest.isNotEmpty => switch (method) {
          'GET' => _handleGet('things/${rest.join('/')}', _thingController.handleGet),
          'PATCH' => _handleUpdate('things/${rest.join('/')}', request, uri, _thingController.handleUpdate),
          'DELETE' => _handleDelete('things/${rest.join('/')}', _thingController.handleDelete),
          _ => Future.value(const TransportResponse(statusCode: 405)),
        },

        // --- Persons ---
        ('GET', ['persons']) => _personController.handleList(),
        ('POST', ['persons']) => _personController.handleCreate(request),
        (final method, ['persons', ...final rest]) when rest.isNotEmpty => switch (method) {
          'GET' => _handleGet('persons/${rest.join('/')}', _personController.handleGet),
          'PATCH' => _handleUpdate('persons/${rest.join('/')}', request, uri, _personController.handleUpdate),
          'DELETE' => _handleDelete('persons/${rest.join('/')}', _personController.handleDelete),
          _ => Future.value(const TransportResponse(statusCode: 405)),
        },

        // --- Organizations ---
        ('GET', ['organizations']) => _organizationController.handleList(),
        ('POST', ['organizations']) => _organizationController.handleCreate(request),
        (final method, ['organizations', ...final rest]) when rest.isNotEmpty => switch (method) {
          'GET' => _handleGet('organizations/${rest.join('/')}', _organizationController.handleGet),
          'PATCH' => _handleUpdate('organizations/${rest.join('/')}', request, uri, _organizationController.handleUpdate),
          'DELETE' => _handleDelete('organizations/${rest.join('/')}', _organizationController.handleDelete),
          _ => Future.value(const TransportResponse(statusCode: 405)),
        },

        // --- Tasks ---
        ('GET', ['tasks']) => _taskController.handleList(uri),
        ('POST', ['tasks']) => _taskController.handleCreate(request),
        (final method, ['tasks', ...final rest]) when rest.isNotEmpty => switch (method) {
          'GET' => _handleGet('tasks/${rest.join('/')}', _taskController.handleGet),
          'PATCH' => _handleUpdate('tasks/${rest.join('/')}', request, uri, _taskController.handleUpdate),
          'DELETE' => _handleDelete('tasks/${rest.join('/')}', _taskController.handleDelete),
          _ => Future.value(const TransportResponse(statusCode: 405)),
        },

        // --- TaskLists ---
        ('GET', ['taskLists']) => _taskListController.handleList(uri),
        ('POST', ['taskLists']) => _taskListController.handleCreate(request),
        
        // Nested sub-collection
        ('GET', ['taskLists', final id, 'tasks']) => _handleGetTasks('taskLists/$id'),

        (final method, ['taskLists', ...final rest]) when rest.isNotEmpty => switch (method) {
          'GET' => _handleGet('taskLists/${rest.join('/')}', _taskListController.handleGet),
          'PATCH' => _handleUpdate('taskLists/${rest.join('/')}', request, uri, _taskListController.handleUpdate),
          'DELETE' => _handleDelete('taskLists/${rest.join('/')}', _taskListController.handleDelete),
          _ => Future.value(const TransportResponse(statusCode: 405)),
        },

        // --- Fallbacks ---
        // Catch-all for unsupported methods on base collections
        (_, ['things']) || (_, ['tasks']) || (_, ['taskLists']) || (_, ['persons']) || (_, ['organizations']) => 
            Future.value(const TransportResponse(statusCode: 405)),
            
        _ => Future.value(const TransportResponse(statusCode: 404)),
      };
    } catch (e, stackTrace) {
      _logger.severe('Routing error', e, stackTrace);
      return const TransportResponse(statusCode: 500);
    }
  }

  // --- Helper Methods to handle ResourceName parsing and error handling ---

  Future<TransportResponse> _handleGet(
      String rawName, Future<TransportResponse> Function(String) handler) async {
    try {
      final name = ResourceName.parse(rawName).toString();
      return await handler(name);
    } on FormatException {
      return const TransportResponse(statusCode: 400);
    }
  }

  Future<TransportResponse> _handleUpdate(
      String rawName,
      TransportRequest request,
      Uri uri,
      Future<TransportResponse> Function(String, TransportRequest, Uri) handler) async {
    try {
      final name = ResourceName.parse(rawName).toString();
      return await handler(name, request, uri);
    } on FormatException {
      return const TransportResponse(statusCode: 400);
    }
  }

  Future<TransportResponse> _handleDelete(
      String rawName, Future<TransportResponse> Function(String) handler) async {
    try {
      final name = ResourceName.parse(rawName).toString();
      return await handler(name);
    } on FormatException {
      return const TransportResponse(statusCode: 400);
    }
  }

  Future<TransportResponse> _handleGetTasks(String rawListName) async {
    try {
      final name = ResourceName.parse(rawListName).toString();
      return await _taskListController.handleListTasks(name);
    } on FormatException {
      return const TransportResponse(statusCode: 400);
    }
  }
}
