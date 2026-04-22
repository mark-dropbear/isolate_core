import '../../api/models/task.dart';
import '../repositories/task_repository.dart';

class SaveTaskUseCase {
  final TaskRepository _repository;

  SaveTaskUseCase(this._repository);

  Future<Task> call(Task task) async {
    if (task.name.isEmpty) {
      return _repository.createTask(
        task.displayName,
        description: task.description,
      );
    } else {
      return _repository.updateTask(task);
    }
  }
}
