import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isolate_core/api/models/task.dart';
import 'package:isolate_core/api/models/task_list.dart';
import 'package:isolate_core/domain/usecases/add_task_to_list_usecase.dart';
import 'package:isolate_core/domain/usecases/get_tasks_for_list_usecase.dart';
import 'package:isolate_core/domain/usecases/save_task_usecase.dart';
import 'package:isolate_core/domain/usecases/get_things_usecase.dart';
import 'package:isolate_core/ui/viewmodels/task_screen_viewmodel.dart';
import 'package:isolate_core/ui/views/task_screen.dart';

import '../../fakes/fake_task_list_repository.dart';
import '../../fakes/fake_task_repository.dart';
import '../../fakes/fake_thing_repository.dart';

void main() {
  group('TaskScreen Widget Tests', () {
    late FakeTaskRepository fakeTaskRepo;
    late FakeTaskListRepository fakeListRepo;
    late FakeThingRepository fakeThingRepo;
    late TaskScreenViewModel viewModel;

    setUp(() {
      fakeTaskRepo = FakeTaskRepository();
      fakeListRepo = FakeTaskListRepository(fakeTaskRepo);
      fakeThingRepo = FakeThingRepository();
      viewModel = TaskScreenViewModel(
        GetTasksForListUseCase(fakeListRepo),
        SaveTaskUseCase(fakeTaskRepo),
        AddTaskToListUseCase(fakeTaskRepo, fakeListRepo),
        GetThingsUseCase(fakeThingRepo),
      );

      // Seed a default task list so we can test adding to it
      fakeListRepo.seed([
        const TaskList(name: 'list/1', displayName: 'My List', items: []),
      ]);
    });

    testWidgets('renders empty state when no tasks exist', (
      WidgetTester tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/tasks/list%2F1',
        routes: [
          GoRoute(
            path: '/tasks/:listName',
            builder: (context, state) => TaskScreen(
              viewModel: viewModel,
              listName: 'list/1',
              listDisplayName: 'My List',
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('My List'), findsOneWidget);
      expect(find.text('No tasks in this list.'), findsOneWidget);
    });

    testWidgets('renders list of tasks', (WidgetTester tester) async {
      fakeTaskRepo.seed([
        const Task(name: 'task/1', displayName: 'Buy milk'),
        const Task(
          name: 'task/2',
          displayName: 'Walk dog',
          actionStatus: 'https://schema.org/CompletedActionStatus',
        ),
      ]);
      fakeListRepo.seed([
        const TaskList(
          name: 'list/1',
          displayName: 'My List',
          items: [
            TaskListItem(position: 1, taskName: 'task/1'),
            TaskListItem(position: 2, taskName: 'task/2'),
          ],
        ),
      ]);

      final router = GoRouter(
        initialLocation: '/tasks/list%2F1',
        routes: [
          GoRoute(
            path: '/tasks/:listName',
            builder: (context, state) => TaskScreen(
              viewModel: viewModel,
              listName: 'list/1',
              listDisplayName: 'My List',
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Buy milk'), findsOneWidget);
      expect(find.text('Walk dog'), findsOneWidget);

      final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
      expect(checkboxes.length, 2);
      expect(checkboxes.elementAt(0).value, isFalse); // Buy milk
      expect(checkboxes.elementAt(1).value, isTrue); // Walk dog
    });

    testWidgets('tapping add button opens create dialog and saves task', (
      WidgetTester tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/tasks/list%2F1',
        routes: [
          GoRoute(
            path: '/tasks/:listName',
            builder: (context, state) => TaskScreen(
              viewModel: viewModel,
              listName: 'list/1',
              listDisplayName: 'My List',
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('No tasks in this list.'), findsOneWidget);

      // Open dialog
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('New Task'), findsOneWidget);

      // Enter text and save
      await tester.enterText(find.byType(TextField), 'Clean house');
      await tester.pump();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Verify UI update
      expect(find.text('Clean house'), findsOneWidget);
      expect(find.text('No tasks in this list.'), findsNothing);

      // Verify backend update
      final tasks = await fakeTaskRepo.getTasks();
      expect(tasks.length, 1);
      expect(tasks.first.displayName, 'Clean house');
      
      final list = await fakeListRepo.getTaskList('list/1');
      expect(list.items.length, 1);
      expect(list.items.first.taskName, tasks.first.name);
    });

    testWidgets('toggling checkbox updates task status', (
      WidgetTester tester,
    ) async {
      fakeTaskRepo.seed([
        const Task(name: 'task/1', displayName: 'Read book'),
      ]);
      fakeListRepo.seed([
        const TaskList(
          name: 'list/1',
          displayName: 'My List',
          items: [
            TaskListItem(position: 1, taskName: 'task/1'),
          ],
        ),
      ]);

      final router = GoRouter(
        initialLocation: '/tasks/list%2F1',
        routes: [
          GoRoute(
            path: '/tasks/:listName',
            builder: (context, state) => TaskScreen(
              viewModel: viewModel,
              listName: 'list/1',
              listDisplayName: 'My List',
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      var checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);

      // Tap checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);

      // Verify backend
      final tasks = await fakeTaskRepo.getTasks();
      expect(tasks.first.isCompleted, isTrue);
    });
  });
}
