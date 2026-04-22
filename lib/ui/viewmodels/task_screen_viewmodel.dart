import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../api/models/task.dart';
import '../../domain/usecases/get_tasks_for_list_usecase.dart';
import '../../domain/usecases/save_task_usecase.dart';
import '../../domain/usecases/add_task_to_list_usecase.dart';

class TaskScreenViewModel extends ChangeNotifier {
  final _logger = Logger('TaskScreenViewModel');
  final GetTasksForListUseCase _getTasksForList;
  final SaveTaskUseCase _saveTask;
  final AddTaskToListUseCase _addTaskToList;

  List<Task> tasks = [];
  bool isLoading = false;
  String? error;

  TaskScreenViewModel(
    this._getTasksForList,
    this._saveTask,
    this._addTaskToList,
  );

  Future<void> loadTasks(String listName) async {
    _logger.info('Loading tasks for list $listName');
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      tasks = await _getTasksForList(listName);
      _logger.info('Successfully loaded ${tasks.length} tasks');
    } catch (e, stackTrace) {
      _logger.severe('Failed to load tasks', e, stackTrace);
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(String listName, String displayName) async {
    _logger.info('Adding task $displayName to list $listName');
    try {
      await _addTaskToList(listName: listName, displayName: displayName);
      await loadTasks(listName); // Refresh list
    } catch (e, stackTrace) {
      _logger.severe('Failed to add task', e, stackTrace);
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleTaskStatus(Task task) async {
    _logger.info('Toggling status for task ${task.name}');
    final newStatus = task.isCompleted
        ? 'https://schema.org/PotentialActionStatus'
        : 'https://schema.org/CompletedActionStatus';

    try {
      final updatedTask = task.copyWith(actionStatus: newStatus);
      await _saveTask(updatedTask);
      final index = tasks.indexWhere((t) => t.name == task.name);
      if (index != -1) {
        tasks[index] = updatedTask;
      }
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.severe('Failed to toggle status', e, stackTrace);
      error = e.toString();
      notifyListeners();
    }
  }
}
