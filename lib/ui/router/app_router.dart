import 'package:go_router/go_router.dart';
import 'package:isolate_core/domain/usecases/get_task_lists_usecase.dart';
import 'package:isolate_core/domain/usecases/save_task_list_usecase.dart';
import 'package:isolate_core/domain/usecases/get_tasks_for_list_usecase.dart';
import 'package:isolate_core/domain/usecases/save_task_usecase.dart';
import 'package:isolate_core/domain/usecases/add_task_to_list_usecase.dart';
import 'package:isolate_core/domain/usecases/get_things_usecase.dart';
import 'package:isolate_core/domain/usecases/delete_thing_usecase.dart';
import 'package:isolate_core/domain/usecases/save_thing_usecase.dart';
import 'package:isolate_core/data/services/debug_api_service.dart';
import 'package:isolate_core/ui/viewmodels/task_list_viewmodel.dart';
import 'package:isolate_core/ui/viewmodels/task_screen_viewmodel.dart';
import 'package:isolate_core/ui/viewmodels/thing_list_viewmodel.dart';
import 'package:isolate_core/ui/viewmodels/thing_detail_viewmodel.dart';
import 'package:isolate_core/ui/views/task_list_screen.dart';
import 'package:isolate_core/ui/views/task_screen.dart';
import 'package:isolate_core/ui/views/thing_list_screen.dart';
import 'package:isolate_core/ui/views/thing_form_screen.dart';
import 'package:isolate_core/ui/views/app_shell.dart';
import 'package:isolate_core/api/models/thing.dart';

GoRouter createAppRouter({
  required GetTaskListsUseCase getTaskListsUseCase,
  required SaveTaskListUseCase saveTaskListUseCase,
  required GetTasksForListUseCase getTasksForListUseCase,
  required SaveTaskUseCase saveTaskUseCase,
  required AddTaskToListUseCase addTaskToListUseCase,
  required DebugApiService debugApiService,
  required GetThingsUseCase getThingsUseCase,
  required DeleteThingUseCase deleteThingUseCase,
  required SaveThingUseCase saveThingUseCase,
}) {
  // Instantiate ViewModels once to prevent loss of state during GoRouter rebuilds
  final taskListViewModel = TaskListViewModel(
    getTaskListsUseCase,
    saveTaskListUseCase,
    debugApiService,
  );

  final thingListViewModel = ThingListViewModel(
    getThingsUseCase,
    deleteThingUseCase,
  );

  // We can reuse the same detail/screen viewmodels since their state is refreshed via load() methods or they are short-lived.
  final taskScreenViewModel = TaskScreenViewModel(
    getTasksForListUseCase,
    saveTaskUseCase,
    addTaskToListUseCase,
  );

  final thingDetailViewModel = ThingDetailViewModel(saveThingUseCase);

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
              viewModel: taskListViewModel,
            ),
          ),
          GoRoute(
            path: '/tasks/:listName',
            builder: (context, state) {
              final encodedListName = state.pathParameters['listName']!;
              final listName = Uri.decodeComponent(encodedListName);
              final displayName = state.extra as String? ?? 'Tasks';
              return TaskScreen(
                viewModel: taskScreenViewModel,
                listName: listName,
                listDisplayName: displayName,
              );
            },
          ),
          GoRoute(
            path: '/things',
            builder: (context, state) => ThingListScreen(
              viewModel: thingListViewModel,
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => ThingFormScreen(
                  viewModel: thingDetailViewModel,
                ),
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final thing = state.extra as Thing?;
                  return ThingFormScreen(
                    viewModel: thingDetailViewModel,
                    thing: thing,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
