import '../../api/models/task.dart';
import '../../api/models/task_list.dart';
import '../../domain/repositories/task_list_repository.dart';
import '../../api/models/api_requests.dart';
import '../services/task_list_api_service.dart';
import '../services/task_api_service.dart';
import 'package:logging/logging.dart';

class TaskListRepositoryImpl implements TaskListRepository {
  final _logger = Logger('TaskListRepositoryImpl');
  final TaskListApiService _apiService;
  final TaskApiService _taskApiService;

  TaskListRepositoryImpl(this._apiService, this._taskApiService);

  @override
  Future<List<TaskList>> getTaskLists() async {
    _logger.info('getTaskLists()');
    final response =
        await _apiService.listTaskLists(const ListTaskListsRequest());
    return response.taskLists;
  }

  @override
  Future<TaskList> getTaskList(String name) async {
    _logger.info('getTaskList($name)');
    return _apiService.getTaskList(GetTaskListRequest(name: name));
  }

  @override
  Future<TaskList> createTaskList(String displayName) async {
    _logger.info('createTaskList($displayName)');
    final taskList = TaskList(name: '', displayName: displayName);
    return _apiService.createTaskList(CreateTaskListRequest(taskList: taskList));
  }

  @override
  Future<TaskList> updateTaskList(TaskList taskList) async {
    _logger.info('updateTaskList(${taskList.name})');
    return _apiService.updateTaskList(
      UpdateTaskListRequest(taskList: taskList),
    );
  }

  @override
  Future<void> deleteTaskList(String name) async {
    _logger.info('deleteTaskList($name)');
    return _apiService.deleteTaskList(DeleteTaskListRequest(name: name));
  }

  @override
  Future<List<Task>> getTasksForList(String listName) async {
    _logger.info('getTasksForList($listName)');
    final response = await _taskApiService.listTasks(
      ListTasksRequest(parent: listName),
    );
    return response.tasks;
  }

  @override
  Future<void> addTaskToList(
    String listName,
    String taskName,
    int position,
  ) async {
    _logger.info('addTaskToList($listName, $taskName, $position)');
    final list = await getTaskList(listName);
    final updatedItems = List<TaskListItem>.from(list.items);
    updatedItems.add(TaskListItem(position: position, taskName: taskName));
    await updateTaskList(list.copyWith(items: updatedItems));
  }

  @override
  Future<void> removeTaskFromList(String listName, String taskName) async {
    _logger.info('removeTaskFromList($listName, $taskName)');
    final list = await getTaskList(listName);
    final updatedItems =
        list.items.where((item) => item.taskName != taskName).toList();
    await updateTaskList(list.copyWith(items: updatedItems));
  }
}
