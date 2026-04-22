import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'domain/usecases/get_things_usecase.dart';
import 'domain/usecases/delete_thing_usecase.dart';
import 'domain/usecases/save_thing_usecase.dart';
import 'domain/usecases/get_task_lists_usecase.dart';
import 'domain/usecases/get_tasks_for_list_usecase.dart';
import 'domain/usecases/save_task_usecase.dart';
import 'domain/usecases/save_task_list_usecase.dart';
import 'domain/usecases/add_task_to_list_usecase.dart';
import 'data/services/debug_api_service.dart';
import 'ui/router/app_router.dart';
import 'ui/theme.dart';

class MyApp extends StatelessWidget {
  final GetThingsUseCase getThingsUseCase;
  final DeleteThingUseCase deleteThingUseCase;
  final SaveThingUseCase saveThingUseCase;

  final GetTaskListsUseCase getTaskListsUseCase;
  final GetTasksForListUseCase getTasksForListUseCase;
  final SaveTaskUseCase saveTaskUseCase;
  final SaveTaskListUseCase saveTaskListUseCase;
  final AddTaskToListUseCase addTaskToListUseCase;
  final DebugApiService debugApiService;

  late final GoRouter _router;

  MyApp({
    super.key,
    required this.getThingsUseCase,
    required this.deleteThingUseCase,
    required this.saveThingUseCase,
    required this.getTaskListsUseCase,
    required this.getTasksForListUseCase,
    required this.saveTaskUseCase,
    required this.saveTaskListUseCase,
    required this.addTaskToListUseCase,
    required this.debugApiService,
  }) {
    _router = createAppRouter(
      getTaskListsUseCase: getTaskListsUseCase,
      saveTaskListUseCase: saveTaskListUseCase,
      getTasksForListUseCase: getTasksForListUseCase,
      saveTaskUseCase: saveTaskUseCase,
      addTaskToListUseCase: addTaskToListUseCase,
      debugApiService: debugApiService,
      getThingsUseCase: getThingsUseCase,
      deleteThingUseCase: deleteThingUseCase,
      saveThingUseCase: saveThingUseCase,
    );
  }

  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme(Theme.of(context).textTheme);

    return MaterialApp.router(
      title: 'Things App',
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
