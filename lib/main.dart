import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'dart:developer' as developer;

import 'api/models/thing.dart';
import 'core/di/injection_container.dart';
import 'transport/isolate_transport_client.dart';
import 'transport/transport_client.dart';
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

  // Initialize Dependency Injection
  setupDependencies();

  // Initialize transport layer
  final transportClient = getIt<TransportClient>() as IsolateTransportClient;
  await transportClient.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        viewModel: ThingListViewModel(),
        formScreenBuilder: (context, Thing? thing) {
          return ThingFormScreen(
            viewModel: ThingDetailViewModel(),
            thing: thing,
          );
        },
      ),
    );
  }
}
