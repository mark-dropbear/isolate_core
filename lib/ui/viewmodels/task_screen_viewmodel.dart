import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../api/models/task.dart';
import '../../api/models/thing.dart';
import '../../api/models/person.dart';
import '../../api/models/organization.dart';
import '../../domain/usecases/get_tasks_for_list_usecase.dart';
import '../../domain/usecases/save_task_usecase.dart';
import '../../domain/usecases/add_task_to_list_usecase.dart';
import '../../domain/usecases/get_things_usecase.dart';
import '../../domain/usecases/get_persons_usecase.dart';
import '../../domain/usecases/get_organizations_usecase.dart';

class TaskScreenViewModel extends ChangeNotifier {
  final _logger = Logger('TaskScreenViewModel');
  final GetTasksForListUseCase _getTasksForList;
  final SaveTaskUseCase _saveTask;
  final AddTaskToListUseCase _addTaskToList;
  final GetThingsUseCase _getThings;
  final GetPersonsUseCase _getPersons;
  final GetOrganizationsUseCase _getOrganizations;

  List<Task> tasks = [];
  List<Thing> availableThings = [];
  List<Person> availablePersons = [];
  List<Organization> availableOrganizations = [];
  bool isLoading = false;
  String? error;

  TaskScreenViewModel(
    this._getTasksForList,
    this._saveTask,
    this._addTaskToList,
    this._getThings,
    this._getPersons,
    this._getOrganizations,
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

  Future<void> loadAvailableThings() async {
    _logger.info('Loading available things for task creation');
    try {
      availableThings = await _getThings();
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.severe('Failed to load things', e, stackTrace);
    }
  }

  Future<void> loadAvailableAgents() async {
    _logger.info('Loading available agents for task creation');
    try {
      availablePersons = await _getPersons();
      availableOrganizations = await _getOrganizations();
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.severe('Failed to load agents', e, stackTrace);
    }
  }

  Future<void> addTask(String listName, String displayName, {List<String> instruments = const [], List<String> agents = const []}) async {
    _logger.info('Adding task $displayName to list $listName');
    try {
      await _addTaskToList(
        listName: listName,
        displayName: displayName,
        instruments: instruments,
        agents: agents,
      );
      await loadTasks(listName); // Refresh list
    } catch (e, stackTrace) {
      _logger.severe('Failed to add task', e, stackTrace);
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleTaskStatus(Task task) async {
    _logger.info('Toggling status for task ${task.name}');
    final isNowCompleted = !task.isCompleted;
    final newStatus = isNowCompleted
        ? 'https://schema.org/CompletedActionStatus'
        : 'https://schema.org/PotentialActionStatus';

    try {
      final updatedTask = task.copyWith(
        actionStatus: newStatus,
        endTime: isNowCompleted ? DateTime.now().toUtc() : null,
        clearEndTime: !isNowCompleted,
      );
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
