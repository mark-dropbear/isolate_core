import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_core/api/models/task_list.dart';

void main() {
  group('TaskList', () {
    test('toJson and fromJson work correctly', () {
      const taskList = TaskList(
        name: 'taskLists/L1',
        displayName: 'My List',
        items: [
          TaskListItem(position: 1, taskName: 'tasks/T1'),
          TaskListItem(position: 2, taskName: 'tasks/T2'),
        ],
      );

      final json = taskList.toJson();
      final fromJson = TaskList.fromJson(json);

      expect(fromJson.name, taskList.name);
      expect(fromJson.displayName, taskList.displayName);
      expect(fromJson.items.length, 2);
      expect(fromJson.items[0].taskName, 'tasks/T1');
    });

    test('toDataset and fromDataset work correctly', () {
      const taskList = TaskList(
        name: 'taskLists/L1',
        displayName: 'My List',
        items: [
          TaskListItem(position: 2, taskName: 'tasks/T2'),
          TaskListItem(position: 1, taskName: 'tasks/T1'),
        ],
      );

      final dataset = taskList.toDataset();
      final fromDataset = TaskList.fromDataset(dataset, 'taskLists/L1');

      expect(fromDataset.name, taskList.name);
      expect(fromDataset.displayName, taskList.displayName);
      expect(fromDataset.items.length, 2);
      // Verify ordering
      expect(fromDataset.items[0].position, 1);
      expect(fromDataset.items[0].taskName, 'tasks/T1');
      expect(fromDataset.items[1].position, 2);
      expect(fromDataset.items[1].taskName, 'tasks/T2');
    });
  });
}
