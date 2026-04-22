import '../../api/models/task_list.dart';
import '../repositories/task_list_repository.dart';

class SaveTaskListUseCase {
  final TaskListRepository _repository;

  SaveTaskListUseCase(this._repository);

  Future<TaskList> call(TaskList taskList) async {
    if (taskList.name.isEmpty) {
      return _repository.createTaskList(taskList.displayName);
    } else {
      return _repository.updateTaskList(taskList);
    }
  }
}
