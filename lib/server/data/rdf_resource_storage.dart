import 'package:file/file.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'resource_storage.dart';

class RdfResourceStorage implements ResourceStorage {
  final File _dataFile;

  RdfResourceStorage(this._dataFile) {
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
      return MemoryDataset();
    }
  }

  void _writeData(Dataset dataset) {
    final nqString = nQuadsCodec.encode(dataset);
    _dataFile.writeAsStringSync(nqString);
  }

  @override
  Future<Dataset> getAllResources() async {
    return _readData();
  }

  @override
  Future<Dataset?> getResource(NamedNode graphIri) async {
    final dataset = _readData();
    final graph = dataset.getGraph(graphIri);
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
          graph: graphIri,
        ),
      );
    }
    return result;
  }

  @override
  Future<Dataset> saveResource(NamedNode graphIri, Dataset dataset) async {
    final currentDataset = _readData();
    currentDataset.addAll(dataset);
    _writeData(currentDataset);
    return dataset;
  }

  @override
  Future<Dataset> updateResource(
    NamedNode graphIri,
    Dataset dataset, {
    Set<NamedNode>? updatePredicates,
  }) async {
    var currentDataset = _readData();
    
    final existingGraph = currentDataset.getGraph(graphIri);
    if (existingGraph.isEmpty) {
      throw Exception('Resource not found');
    }

    if (updatePredicates == null || updatePredicates.isEmpty) {
      final updatedQuads = currentDataset.where((q) => q.graph != graphIri).toList();
      currentDataset = MemoryDataset.fromIterable(updatedQuads);
      currentDataset.addAll(dataset);
    } else {
      final newGraph = dataset.getGraph(graphIri);
      if (newGraph.isNotEmpty) {
        final updatedQuads = currentDataset
            .where(
              (q) =>
                  !(q.graph == graphIri &&
                      updatePredicates.contains(q.predicate)),
            )
            .toList();
        currentDataset = MemoryDataset.fromIterable(updatedQuads);

        for (final predicate in updatePredicates) {
          final newTriples = newGraph.match(predicate: predicate);
          for (final t in newTriples) {
            currentDataset.add(
              Quad(
                subject: t.subject,
                predicate: t.predicate,
                object: t.object,
                graph: graphIri,
              ),
            );
          }
        }
      }
    }

    _writeData(currentDataset);

    final result = MemoryDataset();
    for (final t in currentDataset.getGraph(graphIri)) {
      result.add(
        Quad(
          subject: t.subject,
          predicate: t.predicate,
          object: t.object,
          graph: graphIri,
        ),
      );
    }
    return result;
  }

  @override
  Future<void> deleteResource(NamedNode graphIri) async {
    var currentDataset = _readData();
    final updatedQuads = currentDataset.where((q) => q.graph != graphIri).toList();
    currentDataset = MemoryDataset.fromIterable(updatedQuads);
    _writeData(currentDataset);
  }
}
