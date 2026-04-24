import '../../api/models/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../api/models/api_requests.dart';
import '../services/task_api_service.dart';
import 'package:logging/logging.dart';

class TaskRepositoryImpl implements TaskRepository {
  final _logger = Logger('TaskRepositoryImpl');
  final TaskApiService _apiService;

  TaskRepositoryImpl(this._apiService);

  @override
  Future<List<Task>> getTasks() async {
    _logger.info('getTasks()');
    final response = await _apiService.listTasks(const ListTasksRequest());
    return response.tasks;
  }

  @override
  Future<Task> getTask(String name) async {
    _logger.info('getTask($name)');
    return _apiService.getTask(GetTaskRequest(name: name));
  }

  @override
  Future<Task> createTask(String displayName, {String description = '', List<String> instruments = const [], List<String> agents = const []}) async {
    _logger.info('createTask($displayName)');
    final task = Task(
      name: '',
      displayName: displayName,
      description: description,
      instruments: instruments,
      agents: agents,
    );
    return _apiService.createTask(CreateTaskRequest(task: task));
  }

  @override
  Future<Task> updateTask(Task task) async {
    _logger.info('updateTask(${task.name})');
    return _apiService.updateTask(
      UpdateTaskRequest(
        task: task,
        updateMask: ['name', 'description', 'actionStatus', 'instrument', 'endTime', 'agent'],
      ),
    );
  }

  @override
  Future<void> deleteTask(String name) async {
    _logger.info('deleteTask($name)');
    return _apiService.deleteTask(DeleteTaskRequest(name: name));
  }
}
