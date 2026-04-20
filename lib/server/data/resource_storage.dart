import 'package:rdf_dart/rdf_dart.dart';

abstract class ResourceStorage {
  Future<Dataset> getAllResources();
  Future<Dataset?> getResource(NamedNode graphIri);
  Future<Dataset> saveResource(NamedNode graphIri, Dataset dataset);
  Future<Dataset> updateResource(NamedNode graphIri, Dataset dataset, {Set<NamedNode>? updatePredicates});
  Future<void> deleteResource(NamedNode graphIri);
}
