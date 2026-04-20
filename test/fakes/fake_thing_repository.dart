import 'package:isolate_core/api/models/resource_name.dart';
import 'package:isolate_core/api/models/thing.dart';
import 'package:isolate_core/domain/repositories/thing_repository.dart';

class FakeThingRepository implements ThingRepository {
  final List<Thing> _things = [];

  // Helper method for tests to seed data
  void seed(List<Thing> initialThings) {
    _things.clear();
    _things.addAll(initialThings);
  }

  @override
  Future<List<Thing>> getThings() async {
    // Return a copy to prevent external mutation
    return List.from(_things);
  }

  @override
  Future<Thing> getThing(String name) async {
    return _things.firstWhere(
      (t) => t.name == name,
      orElse: () => throw Exception('Thing not found'),
    );
  }

  @override
  Future<Thing> createThing(String displayName) async {
    final newThing = Thing(
      name: ResourceName.generate('things').toString(),
      displayName: displayName,
    );
    _things.add(newThing);
    return newThing;
  }

  @override
  Future<Thing> updateThing(Thing thing) async {
    final index = _things.indexWhere((t) => t.name == thing.name);
    if (index == -1) {
      throw Exception('Thing not found');
    }
    
    _things[index] = thing;
    return thing;
  }

  @override
  Future<void> deleteThing(String name) async {
    _things.removeWhere((t) => t.name == name);
  }
}
