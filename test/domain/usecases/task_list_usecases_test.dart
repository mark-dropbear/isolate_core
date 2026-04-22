import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_core/api/models/task.dart';
import 'package:isolate_core/api/models/task_list.dart';
import 'package:isolate_core/domain/usecases/add_task_to_list_usecase.dart';
import 'package:isolate_core/domain/usecases/get_task_lists_usecase.dart';
import 'package:isolate_core/domain/usecases/get_tasks_for_list_usecase.dart';
import 'package:isolate_core/domain/usecases/save_task_list_usecase.dart';

import '../../fakes/fake_task_repository.dart';
import '../../fakes/fake_task_list_repository.dart';

void main() {
  group('TaskList UseCases', () {
    late FakeTaskRepository taskRepo;
    late FakeTaskListRepository listRepo;

    setUp(() {
      taskRepo = FakeTaskRepository();
      listRepo = FakeTaskListRepository(taskRepo);
    });

    test('GetTaskListsUseCase returns lists', () async {
      listRepo.seed([const TaskList(name: 'list/1', displayName: 'List 1')]);
      final useCase = GetTaskListsUseCase(listRepo);
      final result = await useCase();
      expect(result.length, 1);
      expect(result.first.displayName, 'List 1');
    });

    test('SaveTaskListUseCase creates list when name is empty', () async {
      final useCase = SaveTaskListUseCase(listRepo);
      final list = const TaskList(name: '', displayName: 'New List');
      final result = await useCase(list);

      expect(result.name, isNotEmpty);
      expect(result.displayName, 'New List');

      final savedLists = await listRepo.getTaskLists();
      expect(savedLists.length, 1);
    });

    test('SaveTaskListUseCase updates list when name is populated', () async {
      listRepo.seed([const TaskList(name: 'list/1', displayName: 'Old List')]);
      final useCase = SaveTaskListUseCase(listRepo);
      final list = const TaskList(name: 'list/1', displayName: 'Updated List');
      final result = await useCase(list);

      expect(result.displayName, 'Updated List');
    });

    test('AddTaskToListUseCase creates task and adds to list', () async {
      listRepo.seed([const TaskList(name: 'list/1', displayName: 'List 1')]);
      final useCase = AddTaskToListUseCase(taskRepo, listRepo);

      await useCase(listName: 'list/1', displayName: 'My New Task');

      // Verify task was created
      final tasks = await taskRepo.getTasks();
      expect(tasks.length, 1);
      expect(tasks.first.displayName, 'My New Task');
      final taskName = tasks.first.name;

      // Verify list was updated
      final updatedList = await listRepo.getTaskList('list/1');
      expect(updatedList.items.length, 1);
      expect(updatedList.items.first.taskName, taskName);
      expect(updatedList.items.first.position, 1);
    });

    test('GetTasksForListUseCase returns tasks associated with list', () async {
      taskRepo.seed([
        const Task(name: 'task/1', displayName: 'Task 1'),
        const Task(name: 'task/2', displayName: 'Task 2'),
      ]);
      listRepo.seed([
        const TaskList(
          name: 'list/1',
          displayName: 'List 1',
          items: [
            TaskListItem(position: 1, taskName: 'task/1'),
            TaskListItem(position: 2, taskName: 'task/2'),
          ],
        )
      ]);

      final useCase = GetTasksForListUseCase(listRepo);
      final result = await useCase('list/1');

      expect(result.length, 2);
      expect(result[0].name, 'task/1');
      expect(result[1].name, 'task/2');
    });
  });
}
