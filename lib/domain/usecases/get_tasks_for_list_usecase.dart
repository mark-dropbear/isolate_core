import '../../api/models/task.dart';
import '../repositories/task_list_repository.dart';

class GetTasksForListUseCase {
  final TaskListRepository _repository;

  GetTasksForListUseCase(this._repository);

  Future<List<Task>> call(String listName) async {
    return _repository.getTasksForList(listName);
  }
}
