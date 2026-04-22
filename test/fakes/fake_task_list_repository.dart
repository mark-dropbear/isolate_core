import 'package:isolate_core/api/models/resource_name.dart';
import 'package:isolate_core/api/models/task.dart';
import 'package:isolate_core/api/models/task_list.dart';
import 'package:isolate_core/domain/repositories/task_list_repository.dart';
import 'fake_task_repository.dart';

class FakeTaskListRepository implements TaskListRepository {
  final List<TaskList> _taskLists = [];
  final FakeTaskRepository _fakeTaskRepository;

  FakeTaskListRepository(this._fakeTaskRepository);

  void seed(List<TaskList> initialTaskLists) {
    _taskLists.clear();
    _taskLists.addAll(initialTaskLists);
  }

  @override
  Future<List<TaskList>> getTaskLists() async {
    return List.from(_taskLists);
  }

  @override
  Future<TaskList> getTaskList(String name) async {
    return _taskLists.firstWhere(
      (t) => t.name == name,
      orElse: () => throw Exception('TaskList not found'),
    );
  }

  @override
  Future<TaskList> createTaskList(String displayName) async {
    final newList = TaskList(
      name: ResourceName.generate('taskLists').toString(),
      displayName: displayName,
    );
    _taskLists.add(newList);
    return newList;
  }

  @override
  Future<TaskList> updateTaskList(TaskList taskList) async {
    final index = _taskLists.indexWhere((t) => t.name == taskList.name);
    if (index == -1) {
      throw Exception('TaskList not found');
    }
    _taskLists[index] = taskList;
    return taskList;
  }

  @override
  Future<void> deleteTaskList(String name) async {
    _taskLists.removeWhere((t) => t.name == name);
  }

  @override
  Future<List<Task>> getTasksForList(String listName) async {
    final list = await getTaskList(listName);
    final tasks = <Task>[];
    for (final item in list.items) {
      try {
        final task = await _fakeTaskRepository.getTask(item.taskName);
        tasks.add(task);
      } catch (_) {
        // Ignore if task doesn't exist in fake repo
      }
    }
    return tasks;
  }

  @override
  Future<void> addTaskToList(String listName, String taskName, int position) async {
    final list = await getTaskList(listName);
    final updatedItems = List<TaskListItem>.from(list.items);
    updatedItems.add(TaskListItem(position: position, taskName: taskName));
    await updateTaskList(list.copyWith(items: updatedItems));
  }

  @override
  Future<void> removeTaskFromList(String listName, String taskName) async {
    final list = await getTaskList(listName);
    final updatedItems =
        list.items.where((item) => item.taskName != taskName).toList();
    await updateTaskList(list.copyWith(items: updatedItems));
  }
}
