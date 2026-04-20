import 'package:rdf_dart/rdf_dart.dart';
import '../../api/models/resource_name.dart';
import '../../api/models/vocab.dart';
import '../../transport/transport_models.dart';
import '../data/resource_storage.dart';
import '../utils/rdf_utils.dart';

typedef FieldMapper = Set<NamedNode> Function(Iterable<String> fields);

final class StandardResourceController {
  final ResourceStorage _storage;
  final String _collectionName;
  final NamedNode _resourceClass;
  final FieldMapper _fieldMapper;

  StandardResourceController({
    required ResourceStorage storage,
    required String collectionName,
    required NamedNode resourceClass,
    required FieldMapper fieldMapper,
  }) : _storage = storage,
       _collectionName = collectionName,
       _resourceClass = resourceClass,
       _fieldMapper = fieldMapper;

  Future<TransportResponse> handleList(Uri uri) async {
    try {
      final dataset = await _storage.queryResources(type: _resourceClass);
      // Pagination can be applied here using uri.queryParameters
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
      final newName = ResourceName.generate(_collectionName).toString();
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
        updatePredicates = _fieldMapper(updateMask);
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
}
