import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_core/api/models/task.dart';
import 'package:isolate_core/api/models/task_list.dart';
import 'package:isolate_core/domain/usecases/add_task_to_list_usecase.dart';
import 'package:isolate_core/domain/usecases/get_tasks_for_list_usecase.dart';
import 'package:isolate_core/domain/usecases/save_task_usecase.dart';
import 'package:isolate_core/domain/usecases/get_things_usecase.dart';
import 'package:isolate_core/ui/viewmodels/task_screen_viewmodel.dart';

import '../../fakes/fake_task_list_repository.dart';
import '../../fakes/fake_task_repository.dart';
import '../../fakes/fake_thing_repository.dart';

void main() {
  group('TaskScreenViewModel Tests', () {
    late FakeTaskRepository taskRepo;
    late FakeTaskListRepository listRepo;
    late FakeThingRepository thingRepo;
    late TaskScreenViewModel viewModel;

    setUp(() {
      taskRepo = FakeTaskRepository();
      listRepo = FakeTaskListRepository(taskRepo);
      thingRepo = FakeThingRepository();
      viewModel = TaskScreenViewModel(
        GetTasksForListUseCase(listRepo),
        SaveTaskUseCase(taskRepo),
        AddTaskToListUseCase(taskRepo, listRepo),
        GetThingsUseCase(thingRepo),
      );
    });

    test('loadTasks fetches tasks for list and updates state', () async {
      taskRepo.seed([const Task(name: 'task/1', displayName: 'Task 1')]);
      listRepo.seed([
        const TaskList(
          name: 'list/1',
          displayName: 'List 1',
          items: [TaskListItem(position: 1, taskName: 'task/1')],
        )
      ]);

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.tasks, isEmpty);

      final future = viewModel.loadTasks('list/1');
      expect(viewModel.isLoading, isTrue);

      await future;

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.tasks.length, 1);
      expect(viewModel.tasks.first.displayName, 'Task 1');
      expect(viewModel.error, isNull);
    });

    test('addTask creates task, adds to list, and reloads', () async {
      listRepo.seed([const TaskList(name: 'list/1', displayName: 'List 1')]);

      await viewModel.addTask('list/1', 'New Task');

      expect(viewModel.tasks.length, 1);
      expect(viewModel.tasks.first.displayName, 'New Task');
      
      final updatedList = await listRepo.getTaskList('list/1');
      expect(updatedList.items.length, 1);
    });

    test('toggleTaskStatus updates status and persists', () async {
      const task = Task(name: 'task/1', displayName: 'Task 1', actionStatus: 'https://schema.org/PotentialActionStatus');
      taskRepo.seed([task]);
      
      // Inject task into viewModel manually or via loadTasks for testing
      listRepo.seed([
        const TaskList(
          name: 'list/1',
          displayName: 'List 1',
          items: [TaskListItem(position: 1, taskName: 'task/1')],
        )
      ]);
      await viewModel.loadTasks('list/1');

      final taskToToggle = viewModel.tasks.first;
      expect(taskToToggle.isCompleted, isFalse);

      await viewModel.toggleTaskStatus(taskToToggle);

      expect(viewModel.tasks.first.isCompleted, isTrue);
      
      final persistedTask = await taskRepo.getTask('task/1');
      expect(persistedTask.isCompleted, isTrue);
    });
  });
}
