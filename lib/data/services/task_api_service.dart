import 'package:rdf_dart/rdf_dart.dart';
import '../../api/models/vocab.dart';
import '../../api/models/task.dart';
import '../../transport/transport_client.dart';
import '../../transport/transport_models.dart';
import '../../api/models/api_requests.dart';
import 'package:logging/logging.dart';

class TaskApiService {
  final _logger = Logger('TaskApiService');
  final TransportClient _client;

  TaskApiService(this._client);

  Future<ListTasksResponse> listTasks(ListTasksRequest request) async {
    _logger.info('listTasks()');
    String path = request.parent != null ? '/${request.parent}/tasks' : '/tasks';

    final response = await _client.send(
      TransportRequest(method: 'GET', path: path),
    );

    if (response.statusCode == 200) {
      if (response.body == null || response.body is! String) {
        return const ListTasksResponse(tasks: []);
      }
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      return ListTasksResponse.fromDataset(dataset);
    } else {
      _logger.warning('listTasks failed: ${response.statusCode}');
      throw Exception('Failed to load tasks: ${response.statusCode}');
    }
  }

  Future<Task> getTask(GetTaskRequest request) async {
    _logger.info('getTask(${request.name})');
    final response = await _client.send(
      TransportRequest(method: 'GET', path: '/${request.name}'),
    );

    if (response.statusCode == 200) {
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      return Task.fromDataset(dataset, request.name);
    } else {
      _logger.warning('getTask failed: ${response.statusCode}');
      throw Exception(
        'Failed to get task ${request.name}: ${response.statusCode}',
      );
    }
  }

  Future<Task> createTask(CreateTaskRequest request) async {
    _logger.info('createTask()');
    String path = '/tasks';

    final response = await _client.send(
      TransportRequest(
        method: 'POST',
        path: path,
        body: nQuadsCodec.encode(request.task.toDataset()),
      ),
    );

    if (response.statusCode == 201) {
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      final graphNames = dataset.map((q) => q.graph).whereType<NamedNode>();
      final name = graphNames.isNotEmpty
          ? Vocab.getResourceName(graphNames.first)
          : '';
      return Task.fromDataset(dataset, name);
    } else {
      _logger.warning('createTask failed: ${response.statusCode}');
      throw Exception('Failed to create task: ${response.statusCode}');
    }
  }

  Future<Task> updateTask(UpdateTaskRequest request) async {
    _logger.info('updateTask(${request.task.name})');

    String path = '/${request.task.name}';
    if (request.updateMask != null && request.updateMask!.isNotEmpty) {
      path += '?updateMask=${request.updateMask!.join(',')}';
    }

    final response = await _client.send(
      TransportRequest(
        method: 'PATCH',
        path: path,
        body: nQuadsCodec.encode(request.task.toDataset()),
      ),
    );

    if (response.statusCode == 200) {
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      return Task.fromDataset(dataset, request.task.name);
    } else {
      _logger.warning('updateTask failed: ${response.statusCode}');
      throw Exception('Failed to update task: ${response.statusCode}');
    }
  }

  Future<void> deleteTask(DeleteTaskRequest request) async {
    _logger.info('deleteTask(${request.name})');
    final response = await _client.send(
      TransportRequest(method: 'DELETE', path: '/${request.name}'),
    );

    if (response.statusCode != 204) {
      _logger.warning('deleteTask failed: ${response.statusCode}');
      throw Exception(
        'Failed to delete task ${request.name}: ${response.statusCode}',
      );
    }
  }
}
