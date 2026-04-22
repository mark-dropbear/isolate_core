import '../../api/models/task_list.dart';
import '../repositories/task_list_repository.dart';

class GetTaskListsUseCase {
  final TaskListRepository _repository;

  GetTaskListsUseCase(this._repository);

  Future<List<TaskList>> call() async {
    return _repository.getTaskLists();
  }
}
