import 'package:rdf_dart/rdf_dart.dart';
import '../../api/models/vocab.dart';
import '../../api/models/task_list.dart';
import '../../transport/transport_client.dart';
import '../../transport/transport_models.dart';
import '../../api/models/api_requests.dart';
import 'package:logging/logging.dart';

class TaskListApiService {
  final _logger = Logger('TaskListApiService');
  final TransportClient _client;

  TaskListApiService(this._client);

  Future<ListTaskListsResponse> listTaskLists(
    ListTaskListsRequest request,
  ) async {
    _logger.info('listTaskLists()');
    String path = '/taskLists';

    final response = await _client.send(
      TransportRequest(method: 'GET', path: path),
    );

    if (response.statusCode == 200) {
      if (response.body == null || response.body is! String) {
        return const ListTaskListsResponse(taskLists: []);
      }
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      return ListTaskListsResponse.fromDataset(dataset);
    } else {
      _logger.warning('listTaskLists failed: ${response.statusCode}');
      throw Exception('Failed to load task lists: ${response.statusCode}');
    }
  }

  Future<TaskList> getTaskList(GetTaskListRequest request) async {
    _logger.info('getTaskList(${request.name})');
    final response = await _client.send(
      TransportRequest(method: 'GET', path: '/${request.name}'),
    );

    if (response.statusCode == 200) {
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      return TaskList.fromDataset(dataset, request.name);
    } else {
      _logger.warning('getTaskList failed: ${response.statusCode}');
      throw Exception(
        'Failed to get task list ${request.name}: ${response.statusCode}',
      );
    }
  }

  Future<TaskList> createTaskList(CreateTaskListRequest request) async {
    _logger.info('createTaskList()');
    String path = '/taskLists';

    final response = await _client.send(
      TransportRequest(
        method: 'POST',
        path: path,
        body: nQuadsCodec.encode(request.taskList.toDataset()),
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
      return TaskList.fromDataset(dataset, name);
    } else {
      _logger.warning('createTaskList failed: ${response.statusCode}');
      throw Exception('Failed to create task list: ${response.statusCode}');
    }
  }

  Future<TaskList> updateTaskList(UpdateTaskListRequest request) async {
    _logger.info('updateTaskList(${request.taskList.name})');

    String path = '/${request.taskList.name}';
    if (request.updateMask != null && request.updateMask!.isNotEmpty) {
      path += '?updateMask=${request.updateMask!.join(',')}';
    }

    final response = await _client.send(
      TransportRequest(
        method: 'PATCH',
        path: path,
        body: nQuadsCodec.encode(request.taskList.toDataset()),
      ),
    );

    if (response.statusCode == 200) {
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      return TaskList.fromDataset(dataset, request.taskList.name);
    } else {
      _logger.warning('updateTaskList failed: ${response.statusCode}');
      throw Exception('Failed to update task list: ${response.statusCode}');
    }
  }

  Future<void> deleteTaskList(DeleteTaskListRequest request) async {
    _logger.info('deleteTaskList(${request.name})');
    final response = await _client.send(
      TransportRequest(method: 'DELETE', path: '/${request.name}'),
    );

    if (response.statusCode != 204) {
      _logger.warning('deleteTaskList failed: ${response.statusCode}');
      throw Exception(
        'Failed to delete task list ${request.name}: ${response.statusCode}',
      );
    }
  }
}
