import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_core/api/models/task.dart';
import 'package:isolate_core/domain/usecases/save_task_usecase.dart';

import '../../fakes/fake_task_repository.dart';

void main() {
  group('SaveTaskUseCase', () {
    late FakeTaskRepository repository;
    late SaveTaskUseCase useCase;

    setUp(() {
      repository = FakeTaskRepository();
      useCase = SaveTaskUseCase(repository);
    });

    test('creates task when name is empty', () async {
      final task = const Task(name: '', displayName: 'New Task');
      final result = await useCase(task);

      expect(result.name, isNotEmpty);
      expect(result.displayName, 'New Task');
      
      final savedTasks = await repository.getTasks();
      expect(savedTasks.length, 1);
      expect(savedTasks.first.displayName, 'New Task');
    });

    test('updates task when name is populated', () async {
      repository.seed([
        const Task(name: 'tasks/1', displayName: 'Old Task'),
      ]);

      final task = const Task(name: 'tasks/1', displayName: 'Updated Task');
      final result = await useCase(task);

      expect(result.name, 'tasks/1');
      expect(result.displayName, 'Updated Task');

      final savedTasks = await repository.getTasks();
      expect(savedTasks.length, 1);
      expect(savedTasks.first.displayName, 'Updated Task');
    });
  });
}
