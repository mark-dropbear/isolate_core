import 'package:rdf_dart/rdf_dart.dart';

abstract class ThingStorage {
  Future<Dataset> getAllThings();
  Future<Dataset?> getThingByName(String name);
  Future<Dataset> createThing(String name, Dataset dataset);
  Future<Dataset> updateThing(String name, Dataset dataset, {List<String>? updateMask});
  Future<void> deleteThing(String name);
}
