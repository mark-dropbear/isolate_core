import 'package:flutter_test/flutter_test.dart';
import 'package:file/memory.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'package:isolate_core/api/models/thing.dart';
import 'package:isolate_core/server/data/rdf_resource_storage.dart';
import 'package:isolate_core/api/models/vocab.dart';

void main() {
  group('RdfResourceStorage', () {
    late MemoryFileSystem fs;
    late RdfResourceStorage storage;

    setUp(() {
      fs = MemoryFileSystem();
      final file = fs.file('/things.nq');
      storage = RdfResourceStorage(file);
    });

    test('initializes with an empty dataset', () async {
      final dataset = await storage.getAllResources();
      expect(dataset.isEmpty, isTrue);
    });

    test('saveResource() persists to file', () async {
      final thing = Thing(name: 'things/1', displayName: 'Test Thing');
      await storage.saveResource(
        Vocab.getResourceIri('things/1'),
        thing.toDataset(),
      );

      final dataset = await storage.getAllResources();
      expect(dataset.isNotEmpty, isTrue);

      final graph = dataset.getGraph(Vocab.getResourceIri('things/1'));
      expect(graph, isNotNull);

      final triples = graph.match(predicate: Vocab.displayName);
      expect(triples.isNotEmpty, isTrue);
      expect((triples.first.object as Literal).value, 'Test Thing');
    });

    test('getResource() retrieves existing dataset', () async {
      final thing = Thing(name: 'things/1', displayName: 'Test Thing');
      await storage.saveResource(
        Vocab.getResourceIri('things/1'),
        thing.toDataset(),
      );

      final retrieved = await storage.getResource(
        Vocab.getResourceIri('things/1'),
      );
      expect(retrieved, isNotNull);

      final displayNames = retrieved!.match(predicate: Vocab.displayName);
      expect((displayNames.first.object as Literal).value, 'Test Thing');

      final missing = await storage.getResource(
        Vocab.getResourceIri('things/2'),
      );
      expect(missing, isNull);
    });

    test('updateResource() applies partial updates', () async {
      final thing = Thing(name: 'things/1', displayName: 'Test Thing');
      await storage.saveResource(
        Vocab.getResourceIri('things/1'),
        thing.toDataset(),
      );

      // Partial update
      final update = Thing(name: 'things/1', displayName: 'Updated Name');
      await storage.updateResource(
        Vocab.getResourceIri('things/1'),
        update.toDataset(),
        updatePredicates: {Vocab.displayName},
      );

      final updated = await storage.getResource(
        Vocab.getResourceIri('things/1'),
      );
      final displayNames = updated!.match(predicate: Vocab.displayName);
      expect((displayNames.first.object as Literal).value, 'Updated Name');
    });

    test('deleteResource() removes item from file', () async {
      final thing = Thing(name: 'things/1', displayName: 'Test Thing');
      await storage.saveResource(
        Vocab.getResourceIri('things/1'),
        thing.toDataset(),
      );

      await storage.deleteResource(Vocab.getResourceIri('things/1'));

      final dataset = await storage.getAllResources();
      expect(dataset.isEmpty, isTrue);
    });
  });
}
