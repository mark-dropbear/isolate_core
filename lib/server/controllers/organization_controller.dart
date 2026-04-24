import 'package:rdf_dart/rdf_dart.dart';
import '../../api/models/resource_name.dart';
import '../../api/models/vocab.dart';
import '../../transport/transport_models.dart';
import '../data/resource_storage.dart';
import '../utils/rdf_utils.dart';
import '../utils/link_sync_utils.dart';

class OrganizationController {
  final ResourceStorage _storage;

  OrganizationController(this._storage);

  Future<TransportResponse> handleList() async {
    try {
      // Fetch all types of organizations
      final dataset1 = await _storage.queryResources(type: Vocab.organizationClass);
      final dataset2 = await _storage.queryResources(type: Vocab.ngoClass);
      final dataset3 = await _storage.queryResources(type: Vocab.governmentOrganizationClass);
      final dataset4 = await _storage.queryResources(type: Vocab.localBusinessClass);
      final dataset5 = await _storage.queryResources(type: Vocab.onlineBusinessClass);
      
      final dataset = MemoryDataset()
        ..addAll(dataset1)
        ..addAll(dataset2)
        ..addAll(dataset3)
        ..addAll(dataset4)
        ..addAll(dataset5);
        
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
      final newName = ResourceName.generate('organizations').toString();
      final targetIri = Vocab.getResourceIri(newName);
      final oldIri = Vocab.getResourceIri('');

      final rewrittenDataset = RdfUtils.rewriteResourceIri(
        requestDataset,
        oldIri,
        targetIri,
      );

      final created = await _storage.saveResource(targetIri, rewrittenDataset);
      
      await LinkSyncUtils.syncBidirectionalLinks(
        storage: _storage,
        sourceIri: targetIri,
        oldDataset: MemoryDataset(),
        newDataset: created,
        forwardPredicate: Vocab.employee,
        reversePredicate: Vocab.worksFor,
      );

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
        // Special case: if updating the type, we need to allow Rdf.type
        if (updateMask.contains('type')) {
          updatePredicates.add(Rdf.type);
        }
      }

      final requestDataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(body),
      );

      final result = await _storage.updateResource(
        targetIri,
        requestDataset,
        updatePredicates: updatePredicates,
      );

      await LinkSyncUtils.syncBidirectionalLinks(
        storage: _storage,
        sourceIri: targetIri,
        oldDataset: existing,
        newDataset: result,
        forwardPredicate: Vocab.employee,
        reversePredicate: Vocab.worksFor,
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

      await LinkSyncUtils.syncBidirectionalLinks(
        storage: _storage,
        sourceIri: targetIri,
        oldDataset: existing,
        newDataset: MemoryDataset(), // Empty dataset means all removed
        forwardPredicate: Vocab.employee,
        reversePredicate: Vocab.worksFor,
      );

      return const TransportResponse(statusCode: 204);
    } catch (e) {
      return const TransportResponse(statusCode: 500);
    }
  }
}
