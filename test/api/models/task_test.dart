import 'package:flutter_test/flutter_test.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'package:isolate_core/api/models/task.dart';

void main() {
  group('Task', () {
    test('toJson and fromJson work correctly', () {
      final task = Task(
        name: 'tasks/T1',
        displayName: 'My Task',
        description: 'Test description',
        actionStatus: 'https://schema.org/CompletedActionStatus',
        instruments: const ['things/1'],
        agents: const ['persons/1'],
        endTime: DateTime.utc(2023, 1, 1),
      );

      final json = task.toJson();
      final fromJson = Task.fromJson(json);

      expect(fromJson.name, task.name);
      expect(fromJson.displayName, task.displayName);
      expect(fromJson.description, task.description);
      expect(fromJson.actionStatus, task.actionStatus);
      expect(fromJson.instruments, contains('things/1'));
      expect(fromJson.agents, contains('persons/1'));
      expect(fromJson.endTime, DateTime.utc(2023, 1, 1));
      expect(fromJson.isCompleted, isTrue);
    });

    test('toDataset and fromDataset work correctly', () {
      final task = Task(
        name: 'tasks/T1',
        displayName: 'My Task',
        description: 'Test description',
        instruments: const ['things/1'],
        agents: const ['organizations/1'],
        endTime: DateTime.utc(2023, 1, 1),
      );

      final dataset = task.toDataset();
      final fromDataset = Task.fromDataset(dataset, 'tasks/T1');

      expect(fromDataset.name, task.name);
      expect(fromDataset.displayName, task.displayName);
      expect(fromDataset.description, task.description);
      expect(fromDataset.actionStatus, task.actionStatus);
      expect(fromDataset.instruments, contains('things/1'));
      expect(fromDataset.agents, contains('organizations/1'));
      expect(fromDataset.endTime, DateTime.utc(2023, 1, 1));
    });

    test('fromDataset handles empty graph gracefully', () {
      final dataset = MemoryDataset();
      final task = Task.fromDataset(dataset, 'tasks/T1');
      expect(task.displayName, '');
    });
  });
}
