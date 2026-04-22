import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'dart:developer' as developer;

import 'domain/usecases/get_things_usecase.dart';
import 'domain/usecases/delete_thing_usecase.dart';
import 'domain/usecases/save_thing_usecase.dart';
import 'domain/usecases/get_task_lists_usecase.dart';
import 'domain/usecases/get_tasks_for_list_usecase.dart';
import 'domain/usecases/save_task_usecase.dart';
import 'domain/usecases/save_task_list_usecase.dart';
import 'domain/usecases/add_task_to_list_usecase.dart';
import 'data/repositories/thing_repository_impl.dart';
import 'data/repositories/task_repository_impl.dart';
import 'data/repositories/task_list_repository_impl.dart';
import 'data/services/thing_api_service.dart';
import 'data/services/task_api_service.dart';
import 'data/services/task_list_api_service.dart';
import 'data/services/debug_api_service.dart';
import 'transport/isolate_transport_client.dart';
import 'ui/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    developer.log(
      record.message,
      time: record.time,
      sequenceNumber: record.sequenceNumber,
      level: record.level.value,
      name: record.loggerName,
      zone: record.zone,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  });

  final logger = Logger('main');
  logger.info('Starting Things App');

  // Initialize transport and data layers
  final transportClient = IsolateTransportClient();
  await transportClient.initialize();

  // Thing dependencies
  final thingApiService = ThingApiService(transportClient);
  final thingRepository = ThingRepositoryImpl(thingApiService);
  final getThingsUseCase = GetThingsUseCase(thingRepository);
  final deleteThingUseCase = DeleteThingUseCase(thingRepository);
  final saveThingUseCase = SaveThingUseCase(thingRepository);

  // Task & TaskList dependencies
  final taskApiService = TaskApiService(transportClient);
  final taskListApiService = TaskListApiService(transportClient);
  final debugApiService = DebugApiService(transportClient);
  final taskRepository = TaskRepositoryImpl(taskApiService);
  final taskListRepository =
      TaskListRepositoryImpl(taskListApiService, taskApiService);

  final getTaskListsUseCase = GetTaskListsUseCase(taskListRepository);
  final getTasksForListUseCase = GetTasksForListUseCase(taskListRepository);
  final saveTaskUseCase = SaveTaskUseCase(taskRepository);
  final saveTaskListUseCase = SaveTaskListUseCase(taskListRepository);
  final addTaskToListUseCase =
      AddTaskToListUseCase(taskRepository, taskListRepository);

  runApp(
    MyApp(
      getThingsUseCase: getThingsUseCase,
      deleteThingUseCase: deleteThingUseCase,
      saveThingUseCase: saveThingUseCase,
      getTaskListsUseCase: getTaskListsUseCase,
      getTasksForListUseCase: getTasksForListUseCase,
      saveTaskUseCase: saveTaskUseCase,
      saveTaskListUseCase: saveTaskListUseCase,
      addTaskToListUseCase: addTaskToListUseCase,
      debugApiService: debugApiService,
    ),
  );
}

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
    );
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp.router(
      title: 'Things App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
