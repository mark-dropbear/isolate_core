import 'package:rdf_dart/rdf_dart.dart';
import 'vocab.dart';
import 'thing.dart';
import 'task.dart';
import 'task_list.dart';

// Thing Requests
class GetThingRequest {
  final String name;
  const GetThingRequest({required this.name});
}

class CreateThingRequest {
  final Thing thing;
  final String? thingId;
  const CreateThingRequest({required this.thing, this.thingId});
}

class UpdateThingRequest {
  final Thing thing;
  final List<String>? updateMask;
  const UpdateThingRequest({required this.thing, this.updateMask});
}

class DeleteThingRequest {
  final String name;
  const DeleteThingRequest({required this.name});
}

class ListThingsRequest {
  final int? pageSize;
  final String? pageToken;
  const ListThingsRequest({this.pageSize, this.pageToken});
}

class ListThingsResponse {
  final List<Thing> things;
  final String? nextPageToken;

  const ListThingsResponse({required this.things, this.nextPageToken});

  factory ListThingsResponse.fromDataset(Dataset dataset) {
    final List<Thing> things = [];
    final graphNames =
        dataset.map((q) => q.graph).whereType<NamedNode>().toSet();

    for (final graphName in graphNames) {
      final resourceName = Vocab.getResourceName(graphName);
      things.add(Thing.fromDataset(dataset, resourceName));
    }

    return ListThingsResponse(things: things);
  }
}

// Task Requests
class GetTaskRequest {
  final String name;
  const GetTaskRequest({required this.name});
}

class CreateTaskRequest {
  final Task task;
  final String? taskId;
  const CreateTaskRequest({required this.task, this.taskId});
}

class UpdateTaskRequest {
  final Task task;
  final List<String>? updateMask;
  const UpdateTaskRequest({required this.task, this.updateMask});
}

class DeleteTaskRequest {
  final String name;
  const DeleteTaskRequest({required this.name});
}

class ListTasksRequest {
  final String? parent; // taskLists/{id}
  final int? pageSize;
  final String? pageToken;
  const ListTasksRequest({this.parent, this.pageSize, this.pageToken});
}

class ListTasksResponse {
  final List<Task> tasks;
  final String? nextPageToken;

  const ListTasksResponse({required this.tasks, this.nextPageToken});

  factory ListTasksResponse.fromDataset(Dataset dataset) {
    final List<Task> tasks = [];

    // Find all subjects that are explicitly declared as Actions
    final actionSubjects = dataset
        .where((q) => q.predicate == Rdf.type && q.object == Vocab.actionClass)
        .map((q) => q.subject)
        .whereType<NamedNode>()
        .toSet();

    for (final subject in actionSubjects) {
      try {
        final resourceName = Vocab.getResourceName(subject);
        // We use the subject as the resource name since Task resources use their IRI as the graph name
        tasks.add(Task.fromDataset(dataset, resourceName));
      } catch (e) {
        // Skip graphs that fail validation
      }
    }

    return ListTasksResponse(tasks: tasks);
  }
}

// TaskList Requests
class GetTaskListRequest {
  final String name;
  const GetTaskListRequest({required this.name});
}

class CreateTaskListRequest {
  final TaskList taskList;
  final String? taskListId;
  const CreateTaskListRequest({required this.taskList, this.taskListId});
}

class UpdateTaskListRequest {
  final TaskList taskList;
  final List<String>? updateMask;
  const UpdateTaskListRequest({required this.taskList, this.updateMask});
}

class DeleteTaskListRequest {
  final String name;
  const DeleteTaskListRequest({required this.name});
}

class ListTaskListsRequest {
  final int? pageSize;
  final String? pageToken;
  const ListTaskListsRequest({this.pageSize, this.pageToken});
}

class ListTaskListsResponse {
  final List<TaskList> taskLists;
  final String? nextPageToken;

  const ListTaskListsResponse({required this.taskLists, this.nextPageToken});

  factory ListTaskListsResponse.fromDataset(Dataset dataset) {
    final List<TaskList> taskLists = [];
    final graphNames =
        dataset.map((q) => q.graph).whereType<NamedNode>().toSet();

    for (final graphName in graphNames) {
      final resourceName = Vocab.getResourceName(graphName);
      taskLists.add(TaskList.fromDataset(dataset, resourceName));
    }

    return ListTaskListsResponse(taskLists: taskLists);
  }
}
