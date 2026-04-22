import '../repositories/task_repository.dart';
import '../repositories/task_list_repository.dart';

class AddTaskToListUseCase {
  final TaskRepository _taskRepository;
  final TaskListRepository _taskListRepository;

  AddTaskToListUseCase(this._taskRepository, this._taskListRepository);

  Future<void> call({
    required String listName,
    required String displayName,
    String description = '',
  }) async {
    // 1. Create the task
    final task = await _taskRepository.createTask(
      displayName,
      description: description,
    );

    // 2. Determine next position (get existing tasks for list)
    final existingTasks = await _taskListRepository.getTasksForList(listName);
    final nextPosition = existingTasks.length + 1;

    // 3. Link task to list
    await _taskListRepository.addTaskToList(listName, task.name, nextPosition);
  }
}
