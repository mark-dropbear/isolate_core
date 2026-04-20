import 'package:file/file.dart';
import 'package:rdf_dart/rdf_dart.dart';
import '../../api/models/vocab.dart';
import 'thing_storage.dart';

class RdfThingStorage implements ThingStorage {
  final File _dataFile;

  RdfThingStorage(this._dataFile) {
    if (!_dataFile.existsSync()) {
      _dataFile.writeAsStringSync('');
    }
  }

  Dataset _readData() {
    final nqString = _dataFile.readAsStringSync();
    if (nqString.isEmpty) return MemoryDataset();
    try {
      final quads = nQuadsCodec.decode(nqString);
      return MemoryDataset.fromIterable(quads);
    } catch (e) {
      // Return empty if parsing fails
      return MemoryDataset();
    }
  }

  void _writeData(Dataset dataset) {
    final nqString = nQuadsCodec.encode(dataset);
    _dataFile.writeAsStringSync(nqString);
  }

  @override
  Future<Dataset> getAllThings() async {
    return _readData();
  }

  @override
  Future<Dataset?> getThingByName(String name) async {
    final dataset = _readData();
    final graphName = Vocab.getResourceIri(name);

    final graph = dataset.getGraph(graphName);
    if (graph.isEmpty) {
      return null;
    }

    final result = MemoryDataset();
    for (final t in graph) {
      result.add(
        Quad(
          subject: t.subject,
          predicate: t.predicate,
          object: t.object,
          graph: graphName,
        ),
      );
    }
    return result;
  }

  @override
  Future<Dataset> createThing(String name, Dataset thingDataset) async {
    final dataset = _readData();
    dataset.addAll(thingDataset);
    _writeData(dataset);
    return thingDataset;
  }

  @override
  Future<Dataset> updateThing(
    String name,
    Dataset thingDataset, {
    List<String>? updateMask,
  }) async {
    var dataset = _readData();
    final subject = Vocab.getResourceIri(name);
    final graphName = subject;

    final existingGraph = dataset.getGraph(graphName);
    if (existingGraph.isEmpty) {
      throw Exception('Thing not found');
    }

    if (updateMask == null || updateMask.isEmpty) {
      final updatedQuads = dataset.where((q) => q.graph != graphName).toList();
      dataset = MemoryDataset.fromIterable(updatedQuads);
      dataset.addAll(thingDataset);
    } else {
      final newGraph = thingDataset.getGraph(graphName);
      if (newGraph.isNotEmpty) {
        final predicatesToRemove = <NamedNode>{};
        for (final field in updateMask) {
          if (field == 'displayName') {
            predicatesToRemove.add(Vocab.displayName);
          }
        }

        final updatedQuads = dataset
            .where(
              (q) =>
                  !(q.graph == graphName &&
                      predicatesToRemove.contains(q.predicate)),
            )
            .toList();
        dataset = MemoryDataset.fromIterable(updatedQuads);

        for (final predicate in predicatesToRemove) {
          final newTriples = newGraph.match(predicate: predicate);
          for (final t in newTriples) {
            dataset.add(
              Quad(
                subject: t.subject,
                predicate: t.predicate,
                object: t.object,
                graph: graphName,
              ),
            );
          }
        }
      }
    }

    _writeData(dataset);

    final result = MemoryDataset();
    for (final t in dataset.getGraph(graphName)) {
      result.add(
        Quad(
          subject: t.subject,
          predicate: t.predicate,
          object: t.object,
          graph: graphName,
        ),
      );
    }
    return result;
  }

  @override
  Future<void> deleteThing(String name) async {
    var dataset = _readData();
    final graphName = Vocab.getResourceIri(name);
    final updatedQuads = dataset.where((q) => q.graph != graphName).toList();
    dataset = MemoryDataset.fromIterable(updatedQuads);
    _writeData(dataset);
  }
}
