import '../../api/models/task.dart';
import '../../api/models/task_list.dart';

abstract class TaskListRepository {
  Future<List<TaskList>> getTaskLists();
  Future<TaskList> getTaskList(String name);
  Future<TaskList> createTaskList(String displayName);
  Future<TaskList> updateTaskList(TaskList taskList);
  Future<void> deleteTaskList(String name);

  /// Retrieves tasks belonging to the specified list, including their positions.
  Future<List<Task>> getTasksForList(String listName);

  /// Adds a task to a list at a specific position.
  Future<void> addTaskToList(String listName, String taskName, int position);

  /// Removes a task from a list.
  Future<void> removeTaskFromList(String listName, String taskName);
}
