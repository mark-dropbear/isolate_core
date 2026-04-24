import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'dart:developer' as developer;

import 'domain/usecases/get_things_usecase.dart';
import 'domain/usecases/delete_thing_usecase.dart';
import 'domain/usecases/save_thing_usecase.dart';
import 'domain/usecases/get_persons_usecase.dart';
import 'domain/usecases/delete_person_usecase.dart';
import 'domain/usecases/save_person_usecase.dart';
import 'domain/usecases/get_organizations_usecase.dart';
import 'domain/usecases/delete_organization_usecase.dart';
import 'domain/usecases/save_organization_usecase.dart';
import 'domain/usecases/get_task_lists_usecase.dart';
import 'domain/usecases/get_tasks_for_list_usecase.dart';
import 'domain/usecases/save_task_usecase.dart';
import 'domain/usecases/save_task_list_usecase.dart';
import 'domain/usecases/add_task_to_list_usecase.dart';
import 'data/repositories/thing_repository_impl.dart';
import 'data/repositories/person_repository_impl.dart';
import 'data/repositories/organization_repository_impl.dart';
import 'data/repositories/task_repository_impl.dart';
import 'data/repositories/task_list_repository_impl.dart';
import 'data/services/thing_api_service.dart';
import 'data/services/person_api_service.dart';
import 'data/services/organization_api_service.dart';
import 'data/services/task_api_service.dart';
import 'data/services/task_list_api_service.dart';
import 'data/services/debug_api_service.dart';
import 'transport/isolate_transport_client.dart';
import 'app.dart';

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

  // Person dependencies
  final personApiService = PersonApiService(transportClient);
  final personRepository = PersonRepositoryImpl(personApiService);
  final getPersonsUseCase = GetPersonsUseCase(personRepository);
  final deletePersonUseCase = DeletePersonUseCase(personRepository);
  final savePersonUseCase = SavePersonUseCase(personRepository);

  // Organization dependencies
  final organizationApiService = OrganizationApiService(transportClient);
  final organizationRepository = OrganizationRepositoryImpl(organizationApiService);
  final getOrganizationsUseCase = GetOrganizationsUseCase(organizationRepository);
  final deleteOrganizationUseCase = DeleteOrganizationUseCase(organizationRepository);
  final saveOrganizationUseCase = SaveOrganizationUseCase(organizationRepository);

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
      getPersonsUseCase: getPersonsUseCase,
      deletePersonUseCase: deletePersonUseCase,
      savePersonUseCase: savePersonUseCase,
      getOrganizationsUseCase: getOrganizationsUseCase,
      deleteOrganizationUseCase: deleteOrganizationUseCase,
      saveOrganizationUseCase: saveOrganizationUseCase,
      getTaskListsUseCase: getTaskListsUseCase,
      getTasksForListUseCase: getTasksForListUseCase,
      saveTaskUseCase: saveTaskUseCase,
      saveTaskListUseCase: saveTaskListUseCase,
      addTaskToListUseCase: addTaskToListUseCase,
      debugApiService: debugApiService,
    ),
  );
}
