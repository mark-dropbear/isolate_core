import 'package:isolate_core/api/models/resource_name.dart';
import 'package:isolate_core/api/models/task.dart';
import 'package:isolate_core/domain/repositories/task_repository.dart';

class FakeTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];

  void seed(List<Task> initialTasks) {
    _tasks.clear();
    _tasks.addAll(initialTasks);
  }

  @override
  Future<List<Task>> getTasks() async {
    return List.from(_tasks);
  }

  @override
  Future<Task> getTask(String name) async {
    return _tasks.firstWhere(
      (t) => t.name == name,
      orElse: () => throw Exception('Task not found'),
    );
  }

  @override
  Future<Task> createTask(String displayName, {String description = ''}) async {
    final newTask = Task(
      name: ResourceName.generate('tasks').toString(),
      displayName: displayName,
      description: description,
    );
    _tasks.add(newTask);
    return newTask;
  }

  @override
  Future<Task> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.name == task.name);
    if (index == -1) {
      throw Exception('Task not found');
    }
    _tasks[index] = task;
    return task;
  }

  @override
  Future<void> deleteTask(String name) async {
    _tasks.removeWhere((t) => t.name == name);
  }
}
