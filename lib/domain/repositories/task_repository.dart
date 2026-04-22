import '../../api/models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();
  Future<Task> getTask(String name);
  Future<Task> createTask(String displayName, {String description});
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String name);
}
