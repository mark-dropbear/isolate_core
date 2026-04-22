import 'package:rdf_dart/rdf_dart.dart';
import '../../api/models/resource_name.dart';
import '../../api/models/vocab.dart';
import '../../transport/transport_models.dart';
import '../data/resource_storage.dart';
import '../utils/rdf_utils.dart';

class TaskListController {
  final ResourceStorage _storage;

  TaskListController(this._storage);

  Future<TransportResponse> handleList(Uri uri) async {
    try {
      final dataset = await _storage.queryResources(type: Vocab.itemListClass);
      return TransportResponse(
        statusCode: 200,
        body: nQuadsCodec.encode(dataset),
      );
    } catch (e) {
      return const TransportResponse(statusCode: 500);
    }
  }

  Future<TransportResponse> handleCreate(TransportRequest request) async {
    try {
      final body = request.body;
      if (body == null) return const TransportResponse(statusCode: 400);

      final requestDataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(body),
      );
      final newName = ResourceName.generate('taskLists').toString();
      final targetIri = Vocab.getResourceIri(newName);
      final oldIri = Vocab.getResourceIri('');

      final rewrittenDataset = RdfUtils.rewriteResourceIri(
        requestDataset,
        oldIri,
        targetIri,
      );

      final created = await _storage.saveResource(targetIri, rewrittenDataset);
      return TransportResponse(
        statusCode: 201,
        body: nQuadsCodec.encode(created),
      );
    } catch (e) {
      return const TransportResponse(statusCode: 500);
    }
  }

  Future<TransportResponse> handleGet(String name) async {
    try {
      final targetIri = Vocab.getResourceIri(name);
      final dataset = await _storage.getResource(targetIri);
      if (dataset == null) {
        return const TransportResponse(statusCode: 404);
      }
      return TransportResponse(
        statusCode: 200,
        body: nQuadsCodec.encode(dataset),
      );
    } catch (e) {
      return const TransportResponse(statusCode: 500);
    }
  }

  Future<TransportResponse> handleUpdate(
    String name,
    TransportRequest request,
    Uri uri,
  ) async {
    try {
      final body = request.body;
      if (body == null) return const TransportResponse(statusCode: 400);

      final targetIri = Vocab.getResourceIri(name);
      final existing = await _storage.getResource(targetIri);
      if (existing == null) {
        return const TransportResponse(statusCode: 404);
      }

      final updateMask = uri.queryParameters['updateMask']?.split(',');
      Set<NamedNode>? updatePredicates;
      if (updateMask != null && updateMask.isNotEmpty) {
        updatePredicates = Vocab.mapFieldsToPredicates(updateMask);
      }

      final requestDataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(body),
      );

      final result = await _storage.updateResource(
        targetIri,
        requestDataset,
        updatePredicates: updatePredicates,
      );
      return TransportResponse(
        statusCode: 200,
        body: nQuadsCodec.encode(result),
      );
    } catch (e) {
      return const TransportResponse(statusCode: 500);
    }
  }

  Future<TransportResponse> handleDelete(String name) async {
    try {
      final targetIri = Vocab.getResourceIri(name);
      final existing = await _storage.getResource(targetIri);
      if (existing == null) {
        return const TransportResponse(statusCode: 404);
      }

      await _storage.deleteResource(targetIri);
      return const TransportResponse(statusCode: 204);
    } catch (e) {
      return const TransportResponse(statusCode: 500);
    }
  }

  /// Returns the entire dataset for debugging
  Future<TransportResponse> handleDump() async {
    try {
      final dataset = await _storage.getAllResources();
      return TransportResponse(
        statusCode: 200,
        body: nQuadsCodec.encode(dataset),
      );
    } catch (e) {
      return const TransportResponse(statusCode: 500);
    }
  }

  /// Handles GET /taskLists/{id}/tasks
  Future<TransportResponse> handleListTasks(String listName) async {
    try {
      final listIri = Vocab.getResourceIri(listName);
      final listDataset = await _storage.getResource(listIri);
      if (listDataset == null) {
        return const TransportResponse(statusCode: 404);
      }

      final resultDataset = MemoryDataset();

      // Find all ListItems in this list
      final listGraph = listDataset.getGraph(listIri);
      final itemElements = listGraph.match(
        subject: listIri,
        predicate: Vocab.itemListElement,
      );

      for (final element in itemElements) {
        final listItemNode = element.object;
        if (listItemNode is BlankNode || listItemNode is NamedNode) {
          // Copy ListItem triples to result
          final listItemTriples = listGraph.match(subject: listItemNode);
          for (final t in listItemTriples) {
            resultDataset.add(
              Quad(
                subject: t.subject,
                predicate: t.predicate,
                object: t.object,
                graph: listIri, // Keeping them in the list's graph for simplicity
              ),
            );
          }

          // Fetch the actual Task details
          final itemTriples = listGraph.match(
            subject: listItemNode,
            predicate: Vocab.item,
          );
          if (itemTriples.isNotEmpty) {
            final taskIri = itemTriples.first.object as NamedNode;
            final taskDataset = await _storage.getResource(taskIri);
            if (taskDataset != null) {
              // We must ensure the quads from taskDataset keep their original graph name
              // (which should be taskIri) so Task.fromDataset can find them.
              resultDataset.addAll(taskDataset);
            }
          }
        }
      }

      return TransportResponse(
        statusCode: 200,
        body: nQuadsCodec.encode(resultDataset),
      );
    } catch (e) {
      return const TransportResponse(statusCode: 500);
    }
  }
}
