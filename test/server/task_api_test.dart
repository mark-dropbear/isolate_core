import 'package:flutter_test/flutter_test.dart';
import 'package:file/memory.dart';
import 'package:isolate_core/server/api_server.dart';
import 'package:isolate_core/server/data/rdf_resource_storage.dart';
import 'package:isolate_core/transport/transport_models.dart';
import 'package:isolate_core/api/models/api_requests.dart';
import 'package:isolate_core/api/models/task.dart';
import 'package:isolate_core/api/models/task_list.dart';
import 'package:isolate_core/api/models/vocab.dart';
import 'package:rdf_dart/rdf_dart.dart';

void main() {
  group('Task API Server Integration', () {
    late ApiServer apiServer;

    setUp(() {
      final fs = MemoryFileSystem();
      final file = fs.file('/data.nq');
      final storage = RdfResourceStorage(file);
      apiServer = ApiServer(storage: storage);
    });

    test('Full lifecycle: Create Task, Create List, Add Task to List, Fetch Sub-collection', () async {
      // 1. Create a Task
      final task = Task(name: '', displayName: 'My Task');
      final createTaskRes = await apiServer.handleRequest(
        TransportRequest(
          method: 'POST',
          path: '/tasks',
          body: nQuadsCodec.encode(task.toDataset()),
        ),
      );
      expect(createTaskRes.statusCode, 201);
      final taskDataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(createTaskRes.body as String),
      );
      final taskName = Vocab.getResourceName(
        taskDataset.map((q) => q.graph).whereType<NamedNode>().first,
      );

      // 2. Create a TaskList
      final list = TaskList(name: '', displayName: 'My List');
      final createListRes = await apiServer.handleRequest(
        TransportRequest(
          method: 'POST',
          path: '/taskLists',
          body: nQuadsCodec.encode(list.toDataset()),
        ),
      );
      expect(createListRes.statusCode, 201);
      final listDataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(createListRes.body as String),
      );
      final listName = Vocab.getResourceName(
        listDataset.map((q) => q.graph).whereType<NamedNode>().first,
      );

      // 3. Update List to include Task
      final updatedList = TaskList(
        name: listName,
        displayName: 'My List',
        items: [TaskListItem(position: 1, taskName: taskName)],
      );
      final patchListRes = await apiServer.handleRequest(
        TransportRequest(
          method: 'PATCH',
          path: '/$listName',
          body: nQuadsCodec.encode(updatedList.toDataset()),
        ),
      );
      expect(patchListRes.statusCode, 200);

      // 4. Fetch Sub-collection: GET /taskLists/{id}/tasks
      final listTasksRes = await apiServer.handleRequest(
        TransportRequest(method: 'GET', path: '/$listName/tasks'),
      );
      expect(listTasksRes.statusCode, 200);
      final resultDataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(listTasksRes.body as String),
      );

      // Verify result contains both Task metadata and List membership info
      final resultTasks = ListTasksResponse.fromDataset(resultDataset).tasks;
      expect(resultTasks.length, 1);
      expect(resultTasks.first.displayName, 'My Task');

      // Verify position info is present in the dataset
      final listIri = Vocab.getResourceIri(listName);
      final positions = resultDataset.match(
        graph: listIri,
        predicate: Vocab.position,
      );
      expect(positions.isNotEmpty, isTrue);
      expect((positions.first.object as Literal).value, '1');
    });
  });
}

