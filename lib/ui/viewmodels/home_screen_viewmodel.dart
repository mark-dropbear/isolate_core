import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../domain/usecases/get_task_lists_usecase.dart';
import '../../domain/usecases/get_persons_usecase.dart';
import '../../domain/usecases/get_organizations_usecase.dart';
import '../../domain/usecases/get_things_usecase.dart';

class HomeScreenViewModel extends ChangeNotifier {
  final _logger = Logger('HomeScreenViewModel');
  final GetTaskListsUseCase _getTaskLists;
  final GetPersonsUseCase _getPersons;
  final GetOrganizationsUseCase _getOrganizations;
  final GetThingsUseCase _getThings;

  bool isLoading = false;
  String? error;

  int taskListCount = 0;
  int personCount = 0;
  int organizationCount = 0;
  int thingCount = 0;

  HomeScreenViewModel(
    this._getTaskLists,
    this._getPersons,
    this._getOrganizations,
    this._getThings,
  );

  Future<void> loadMetrics() async {
    _logger.info('Loading home screen metrics');
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _getTaskLists(),
        _getPersons(),
        _getOrganizations(),
        _getThings(),
      ]);

      taskListCount = results[0].length;
      personCount = results[1].length;
      organizationCount = results[2].length;
      thingCount = results[3].length;
      
      _logger.info('Successfully loaded metrics');
    } catch (e, stackTrace) {
      _logger.severe('Failed to load metrics', e, stackTrace);
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
