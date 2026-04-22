import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isolate_core/api/models/task_list.dart';
import 'package:isolate_core/domain/usecases/get_task_lists_usecase.dart';
import 'package:isolate_core/domain/usecases/save_task_list_usecase.dart';
import 'package:isolate_core/ui/viewmodels/task_list_viewmodel.dart';
import 'package:isolate_core/ui/views/task_list_screen.dart';

import '../../fakes/fake_debug_api_service.dart';
import '../../fakes/fake_task_list_repository.dart';
import '../../fakes/fake_task_repository.dart';

void main() {
  group('TaskListScreen Widget Tests', () {
    late FakeTaskListRepository fakeRepo;
    late TaskListViewModel viewModel;

    setUp(() {
      final taskRepo = FakeTaskRepository();
      fakeRepo = FakeTaskListRepository(taskRepo);
      viewModel = TaskListViewModel(
        GetTaskListsUseCase(fakeRepo),
        SaveTaskListUseCase(fakeRepo),
        FakeDebugApiService(),
      );
    });

    testWidgets('renders empty state when no task lists exist', (
      WidgetTester tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => TaskListScreen(viewModel: viewModel),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('My Task Lists'), findsOneWidget);
      expect(find.text('No lists found.'), findsOneWidget);
    });

    testWidgets('renders list of task lists', (WidgetTester tester) async {
      fakeRepo.seed([
        const TaskList(name: 'list/1', displayName: 'Work Tasks'),
        const TaskList(name: 'list/2', displayName: 'Personal Tasks'),
      ]);

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => TaskListScreen(viewModel: viewModel),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Work Tasks'), findsOneWidget);
      expect(find.text('Personal Tasks'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('tapping add button opens create dialog and saves list', (
      WidgetTester tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => TaskListScreen(viewModel: viewModel),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('No lists found.'), findsOneWidget);

      // Open dialog
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('New Task List'), findsOneWidget);

      // Enter text and save
      await tester.enterText(find.byType(TextField), 'Groceries');
      await tester.pump();
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify UI update
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('No lists found.'), findsNothing);

      // Verify backend update
      final lists = await fakeRepo.getTaskLists();
      expect(lists.length, 1);
      expect(lists.first.displayName, 'Groceries');
    });

    testWidgets('tapping a list navigates to the task screen', (
      WidgetTester tester,
    ) async {
      fakeRepo.seed([
        const TaskList(name: 'list/1', displayName: 'Work Tasks'),
      ]);

      String? navigatedPath;

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => TaskListScreen(viewModel: viewModel),
          ),
          GoRoute(
            path: '/tasks/:listName',
            builder: (context, state) {
              navigatedPath = state.uri.toString();
              return const Scaffold(body: Text('Task Screen Stub'));
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Tap the list item
      await tester.tap(find.text('Work Tasks'));
      await tester.pumpAndSettle();

      expect(navigatedPath, '/tasks/list%2F1');
      expect(find.text('Task Screen Stub'), findsOneWidget);
    });
  });
}
