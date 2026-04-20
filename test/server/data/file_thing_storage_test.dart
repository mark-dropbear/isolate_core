import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:file/memory.dart';
import 'package:isolate_core/api/models/thing.dart';
import 'package:isolate_core/server/data/file_thing_storage.dart';

void main() {
  group('FileThingStorage', () {
    late MemoryFileSystem fs;
    late FileThingStorage storage;

    setUp(() {
      fs = MemoryFileSystem();
      final file = fs.file('/things.json');
      storage = FileThingStorage(file);
    });

    test('initializes with an empty list', () async {
      final things = await storage.getAllThings();
      expect(things, isEmpty);
    });

    test('createThing() persists to file', () async {
      final thing = Thing(name: 'things/1', displayName: 'Test Thing');
      await storage.createThing(thing);

      final things = await storage.getAllThings();
      expect(things.length, 1);
      expect(things.first.name, 'things/1');
      expect(things.first.displayName, 'Test Thing');

      // Verify raw file contents
      final fileContent = fs.file('/things.json').readAsStringSync();
      final jsonList = jsonDecode(fileContent) as List;
      expect(jsonList.length, 1);
      expect(jsonList[0]['name'], 'things/1');
    });

    test('getThingByName() retrieves existing item', () async {
      final thing = Thing(name: 'things/1', displayName: 'Test Thing');
      await storage.createThing(thing);

      final retrieved = await storage.getThingByName('things/1');
      expect(retrieved, isNotNull);
      expect(retrieved?.displayName, 'Test Thing');

      final missing = await storage.getThingByName('things/2');
      expect(missing, isNull);
    });

    test('updateThing() applies partial updates', () async {
      final thing = Thing(name: 'things/1', displayName: 'Test Thing');
      await storage.createThing(thing);

      // Partial update
      final update = Thing(name: 'things/1', displayName: 'Updated Name');
      await storage.updateThing(update, updateMask: ['displayName']);

      final updated = await storage.getThingByName('things/1');
      expect(updated?.displayName, 'Updated Name');
    });

    test('deleteThing() removes item from file', () async {
      final thing = Thing(name: 'things/1', displayName: 'Test Thing');
      await storage.createThing(thing);

      await storage.deleteThing('things/1');

      final things = await storage.getAllThings();
      expect(things, isEmpty);
    });
  });
}
