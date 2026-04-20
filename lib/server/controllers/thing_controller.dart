import 'package:rdf_dart/rdf_dart.dart';
import '../../api/models/resource_name.dart';
import '../../api/models/vocab.dart';
import '../../transport/transport_models.dart';
import '../data/thing_storage.dart';
import '../utils/rdf_utils.dart';

class ThingController {
  final ThingStorage _storage;

  ThingController(this._storage);

  Future<TransportResponse> handleList(Uri uri) async {
    try {
      final dataset = await _storage.getAllThings();
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

      final requestDataset = MemoryDataset.fromIterable(nQuadsCodec.decode(body));
      final newName = ResourceName.generate('things').toString();
      final targetIri = Vocab.getResourceIri(newName);

      final rewrittenDataset = RdfUtils.rewriteResourceIri(requestDataset, targetIri);
      
      final created = await _storage.createThing(newName, rewrittenDataset);
      return TransportResponse(statusCode: 201, body: nQuadsCodec.encode(created));
    } catch (e) {
      return const TransportResponse(statusCode: 500);
    }
  }

  Future<TransportResponse> handleGet(String name) async {
    try {
      final dataset = await _storage.getThingByName(name);
      if (dataset == null) {
        return const TransportResponse(statusCode: 404);
      }
      return TransportResponse(statusCode: 200, body: nQuadsCodec.encode(dataset));
    } catch (e) {
      return const TransportResponse(statusCode: 500);
    }
  }

  Future<TransportResponse> handleUpdate(String name, TransportRequest request, Uri uri) async {
    try {
      final body = request.body;
      if (body == null) return const TransportResponse(statusCode: 400);

      final existing = await _storage.getThingByName(name);
      if (existing == null) {
        return const TransportResponse(statusCode: 404);
      }

      final updateMask = uri.queryParameters['updateMask']?.split(',');
      final requestDataset = MemoryDataset.fromIterable(nQuadsCodec.decode(body));

      final result = await _storage.updateThing(name, requestDataset, updateMask: updateMask);
      return TransportResponse(statusCode: 200, body: nQuadsCodec.encode(result));
    } catch (e) {
      return const TransportResponse(statusCode: 500);
    }
  }

  Future<TransportResponse> handleDelete(String name) async {
    try {
      final existing = await _storage.getThingByName(name);
      if (existing == null) {
        return const TransportResponse(statusCode: 404);
      }

      await _storage.deleteThing(name);
      return const TransportResponse(statusCode: 204);
    } catch (e) {
      return const TransportResponse(statusCode: 500);
    }
  }
}
