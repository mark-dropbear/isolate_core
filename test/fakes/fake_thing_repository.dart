import 'package:isolate_core/api/models/resource_name.dart';
import 'package:isolate_core/api/models/thing.dart';
import 'package:isolate_core/domain/repositories/standard_resource_repository.dart';

class FakeThingRepository implements StandardResourceRepository<Thing> {
  final List<Thing> _things = [];

  // Helper method for tests to seed data
  void seed(List<Thing> initialThings) {
    _things.clear();
    _things.addAll(initialThings);
  }

  @override
  Future<List<Thing>> listResources({int? pageSize, String? pageToken}) async {
    // Return a copy to prevent external mutation
    return List.from(_things);
  }

  @override
  Future<Thing> getResource(String name) async {
    return _things.firstWhere(
      (t) => t.name == name,
      orElse: () => throw Exception('Thing not found'),
    );
  }

  @override
  Future<Thing> createResource(Thing resource, {String? resourceId}) async {
    final newThing = Thing(
      name: resourceId ?? ResourceName.generate('things').toString(),
      displayName: resource.displayName,
    );
    _things.add(newThing);
    return newThing;
  }

  @override
  Future<Thing> updateResource(Thing resource, {List<String>? updateMask}) async {
    final index = _things.indexWhere((t) => t.name == resource.name);
    if (index == -1) {
      throw Exception('Thing not found');
    }

    _things[index] = resource;
    return resource;
  }

  @override
  Future<void> deleteResource(String name) async {
    _things.removeWhere((t) => t.name == name);
  }
}
