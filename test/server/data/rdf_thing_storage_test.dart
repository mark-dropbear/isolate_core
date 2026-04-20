import 'package:flutter_test/flutter_test.dart';
import 'package:file/memory.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'package:isolate_core/api/models/thing.dart';
import 'package:isolate_core/server/data/rdf_thing_storage.dart';
import 'package:isolate_core/api/models/vocab.dart';

void main() {
  group('RdfThingStorage', () {
    late MemoryFileSystem fs;
    late RdfThingStorage storage;

    setUp(() {
      fs = MemoryFileSystem();
      final file = fs.file('/things.nq');
      storage = RdfThingStorage(file);
    });

    test('initializes with an empty dataset', () async {
      final dataset = await storage.getAllThings();
      expect(dataset.isEmpty, isTrue);
    });

    test('createThing() persists to file', () async {
      final thing = Thing(name: 'things/1', displayName: 'Test Thing');
      await storage.createThing('things/1', thing.toDataset());

      final dataset = await storage.getAllThings();
      expect(dataset.isNotEmpty, isTrue);

      final graph = dataset.getGraph(Vocab.getResourceIri('things/1'));
      expect(graph, isNotNull);
      
      final triples = graph.match(predicate: Vocab.displayName);
      expect(triples.isNotEmpty, isTrue);
      expect((triples.first.object as Literal).value, 'Test Thing');
    });

    test('getThingByName() retrieves existing dataset', () async {
      final thing = Thing(name: 'things/1', displayName: 'Test Thing');
      await storage.createThing('things/1', thing.toDataset());

      final retrieved = await storage.getThingByName('things/1');
      expect(retrieved, isNotNull);
      
      final displayNames = retrieved!.match(predicate: Vocab.displayName);
      expect((displayNames.first.object as Literal).value, 'Test Thing');

      final missing = await storage.getThingByName('things/2');
      expect(missing, isNull);
    });

    test('updateThing() applies partial updates', () async {
      final thing = Thing(name: 'things/1', displayName: 'Test Thing');
      await storage.createThing('things/1', thing.toDataset());

      // Partial update
      final update = Thing(name: 'things/1', displayName: 'Updated Name');
      await storage.updateThing('things/1', update.toDataset(), updateMask: ['displayName']);

      final updated = await storage.getThingByName('things/1');
      final displayNames = updated!.match(predicate: Vocab.displayName);
      expect((displayNames.first.object as Literal).value, 'Updated Name');
    });

    test('deleteThing() removes item from file', () async {
      final thing = Thing(name: 'things/1', displayName: 'Test Thing');
      await storage.createThing('things/1', thing.toDataset());

      await storage.deleteThing('things/1');

      final dataset = await storage.getAllThings();
      expect(dataset.isEmpty, isTrue);
    });
  });
}
