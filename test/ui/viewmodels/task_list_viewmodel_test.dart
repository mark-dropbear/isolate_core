import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_core/api/models/task_list.dart';
import 'package:isolate_core/domain/usecases/get_task_lists_usecase.dart';
import 'package:isolate_core/domain/usecases/save_task_list_usecase.dart';
import 'package:isolate_core/ui/viewmodels/task_list_viewmodel.dart';

import '../../fakes/fake_task_list_repository.dart';
import '../../fakes/fake_task_repository.dart';
import '../../fakes/fake_debug_api_service.dart';

void main() {
  group('TaskListViewModel Tests', () {
    late FakeTaskListRepository listRepo;
    late TaskListViewModel viewModel;

    setUp(() {
      final taskRepo = FakeTaskRepository();
      listRepo = FakeTaskListRepository(taskRepo);
      viewModel = TaskListViewModel(
        GetTaskListsUseCase(listRepo),
        SaveTaskListUseCase(listRepo),
        FakeDebugApiService(),
      );
    });

    test('loadTaskLists updates state and loads data', () async {
      listRepo.seed([const TaskList(name: 'list/1', displayName: 'List 1')]);

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.taskLists, isEmpty);

      final future = viewModel.loadTaskLists();
      expect(viewModel.isLoading, isTrue); // Should be true while loading

      await future;

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.taskLists.length, 1);
      expect(viewModel.taskLists.first.displayName, 'List 1');
      expect(viewModel.error, isNull);
    });

    test('createTaskList creates list and updates state', () async {
      await viewModel.createTaskList('New List');

      expect(viewModel.taskLists.length, 1);
      expect(viewModel.taskLists.first.displayName, 'New List');
      expect(viewModel.taskLists.first.name, isNotEmpty);
      expect(viewModel.error, isNull);
      
      final listsInRepo = await listRepo.getTaskLists();
      expect(listsInRepo.length, 1);
    });
  });
}
