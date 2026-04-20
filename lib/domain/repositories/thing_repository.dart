import '../../api/models/thing.dart';

abstract class ThingRepository {
  Future<List<Thing>> getThings();
  Future<Thing> getThing(String name);
  Future<Thing> createThing(String displayName);
  Future<Thing> updateThing(Thing thing);
  Future<void> deleteThing(String name);
}
