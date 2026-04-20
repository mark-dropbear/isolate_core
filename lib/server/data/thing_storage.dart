import '../../api/models/thing.dart';

abstract class ThingStorage {
  Future<List<Thing>> getAllThings();
  Future<Thing?> getThingByName(String name);
  Future<Thing> createThing(Thing thing);
  Future<Thing> updateThing(Thing thing, {List<String>? updateMask});
  Future<void> deleteThing(String name);
}
