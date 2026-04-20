import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'dart:developer' as developer;

import 'domain/usecases/get_things_usecase.dart';
import 'domain/usecases/delete_thing_usecase.dart';
import 'domain/usecases/save_thing_usecase.dart';
import 'data/repositories/thing_repository_impl.dart';
import 'data/services/thing_api_service.dart';
import 'api/models/thing.dart';
import 'transport/isolate_transport_client.dart';
import 'ui/viewmodels/thing_detail_viewmodel.dart';
import 'ui/viewmodels/thing_list_viewmodel.dart';
import 'ui/views/thing_list_screen.dart';
import 'ui/views/thing_form_screen.dart';

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

  final apiService = ThingApiService(transportClient);
  final repository = ThingRepositoryImpl(apiService);

  final getThingsUseCase = GetThingsUseCase(repository);
  final deleteThingUseCase = DeleteThingUseCase(repository);
  final saveThingUseCase = SaveThingUseCase(repository);

  runApp(
    MyApp(
      getThingsUseCase: getThingsUseCase,
      deleteThingUseCase: deleteThingUseCase,
      saveThingUseCase: saveThingUseCase,
    ),
  );
}

class MyApp extends StatelessWidget {
  final GetThingsUseCase getThingsUseCase;
  final DeleteThingUseCase deleteThingUseCase;
  final SaveThingUseCase saveThingUseCase;

  const MyApp({
    super.key,
    required this.getThingsUseCase,
    required this.deleteThingUseCase,
    required this.saveThingUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: ThingListScreen(
        viewModel: ThingListViewModel(getThingsUseCase, deleteThingUseCase),
        formScreenBuilder: (context, Thing? thing) {
          return ThingFormScreen(
            viewModel: ThingDetailViewModel(saveThingUseCase),
            thing: thing,
          );
        },
      ),
    );
  }
}
