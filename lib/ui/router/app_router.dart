import 'package:go_router/go_router.dart';
import 'package:isolate_core/domain/usecases/get_task_lists_usecase.dart';
import 'package:isolate_core/domain/usecases/save_task_list_usecase.dart';
import 'package:isolate_core/domain/usecases/get_tasks_for_list_usecase.dart';
import 'package:isolate_core/domain/usecases/save_task_usecase.dart';
import 'package:isolate_core/domain/usecases/add_task_to_list_usecase.dart';
import 'package:isolate_core/data/services/debug_api_service.dart';
import 'package:isolate_core/ui/viewmodels/task_list_viewmodel.dart';
import 'package:isolate_core/ui/viewmodels/task_screen_viewmodel.dart';
import 'package:isolate_core/ui/views/task_list_screen.dart';
import 'package:isolate_core/ui/views/task_screen.dart';
import 'package:isolate_core/ui/views/app_shell.dart';

GoRouter createAppRouter({
  required GetTaskListsUseCase getTaskListsUseCase,
  required SaveTaskListUseCase saveTaskListUseCase,
  required GetTasksForListUseCase getTasksForListUseCase,
  required SaveTaskUseCase saveTaskUseCase,
  required AddTaskToListUseCase addTaskToListUseCase,
  required DebugApiService debugApiService,
}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => TaskListScreen(
              viewModel: TaskListViewModel(
                getTaskListsUseCase,
                saveTaskListUseCase,
                debugApiService,
              ),
            ),
          ),
          GoRoute(
            path: '/tasks/:listName',
            builder: (context, state) {
              final encodedListName = state.pathParameters['listName']!;
              final listName = Uri.decodeComponent(encodedListName);
              final displayName = state.extra as String? ?? 'Tasks';
              return TaskScreen(
                viewModel: TaskScreenViewModel(
                  getTasksForListUseCase,
                  saveTaskUseCase,
                  addTaskToListUseCase,
                ),
                listName: listName,
                listDisplayName: displayName,
              );
            },
          ),
        ],
      ),
    ],
  );
}
