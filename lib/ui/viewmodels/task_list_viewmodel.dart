import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import '../../api/models/task_list.dart';
import '../../domain/usecases/get_task_lists_usecase.dart';
import '../../domain/usecases/save_task_list_usecase.dart';
import '../../data/services/debug_api_service.dart';

class TaskListViewModel extends ChangeNotifier {
  final _logger = Logger('TaskListViewModel');
  final GetTaskListsUseCase _getTaskLists;
  final SaveTaskListUseCase _saveTaskList;
  final DebugApiService _debugApiService;

  List<TaskList> taskLists = [];
  bool isLoading = false;
  String? error;

  TaskListViewModel(
    this._getTaskLists,
    this._saveTaskList,
    this._debugApiService,
  );

  Future<void> loadTaskLists() async {
    _logger.info('Loading task lists');
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      taskLists = await _getTaskLists();
      _logger.info('Successfully loaded ${taskLists.length} lists');
    } catch (e, stackTrace) {
      _logger.severe('Failed to load lists', e, stackTrace);
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTaskList(String displayName) async {
    _logger.info('Creating task list $displayName');
    try {
      final newList = await _saveTaskList(
        TaskList(name: '', displayName: displayName),
      );
      taskLists.add(newList);
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.severe('Failed to create list', e, stackTrace);
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> copyDatasetToClipboard() async {
    _logger.info('Copying dataset to clipboard');
    try {
      final quads = await _debugApiService.fetchDatasetDump();
      await Clipboard.setData(ClipboardData(text: quads));
      _logger.info('Dataset copied successfully');
    } catch (e, stackTrace) {
      _logger.severe('Failed to copy dataset', e, stackTrace);
      error = 'Failed to copy to clipboard: ${e.toString()}';
      notifyListeners();
    }
  }
}
