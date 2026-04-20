import '../../api/models/resource_name.dart';
import '../../api/models/thing.dart';
import '../../transport/transport_models.dart';
import '../data/thing_storage.dart';

class ThingController {
  final ThingStorage _storage;

  ThingController(this._storage);

  Future<TransportResponse> handleList(Uri uri) async {
    try {
      final things = await _storage.getAllThings();
      // Pagination can be applied here using uri.queryParameters
      return TransportResponse(
        statusCode: 200,
        body: {'things': things.map((t) => t.toJson()).toList()},
      );
    } catch (e) {
      return const TransportResponse(statusCode: 500);
    }
  }

  Future<TransportResponse> handleCreate(TransportRequest request) async {
    try {
      final body = request.body;
      if (body == null) return const TransportResponse(statusCode: 400);

      final newThing = Thing(
        name: ResourceName.generate('things').toString(),
        displayName: body['displayName'] as String? ?? '',
      );

      final created = await _storage.createThing(newThing);
      return TransportResponse(statusCode: 201, body: created.toJson());
    } catch (e) {
      return const TransportResponse(statusCode: 500);
    }
  }

  Future<TransportResponse> handleGet(String name) async {
    try {
      final thing = await _storage.getThingByName(name);
      if (thing == null) {
        return const TransportResponse(statusCode: 404);
      }
      return TransportResponse(statusCode: 200, body: thing.toJson());
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
      
      // Merge body into existing representation just to form a Thing object,
      // the storage layer handles applying the specific updateMask.
      final updatedThing = Thing(
        name: name,
        displayName: body['displayName'] as String? ?? existing.displayName,
      );

      final result = await _storage.updateThing(updatedThing, updateMask: updateMask);
      return TransportResponse(statusCode: 200, body: result.toJson());
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
