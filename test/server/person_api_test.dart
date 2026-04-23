import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_core/api/models/person.dart';
import 'package:isolate_core/api/models/vocab.dart';
import 'package:isolate_core/server/api_server.dart';
import 'package:isolate_core/server/data/rdf_resource_storage.dart';
import 'package:isolate_core/transport/transport_models.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'package:file/memory.dart';

void main() {
  group('Person API Integration Tests', () {
    late ApiServer apiServer;
    late MemoryFileSystem fs;

    setUp(() {
      fs = MemoryFileSystem();
      final storage = RdfResourceStorage(
        fs.file('/data.nq'),
      );
      apiServer = ApiServer(storage: storage);
    });

    test('POST /persons creates a new person', () async {
      final person = Person(name: '', givenName: 'John', familyName: 'Doe');
      final req = TransportRequest(
        method: 'POST',
        path: '/persons',
        body: nQuadsCodec.encode(person.toDataset()),
      );

      final response = await apiServer.handleRequest(req);

      expect(response.statusCode, 201);
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );

      final graphNameNode = dataset
          .map((q) => q.graph)
          .whereType<NamedNode>()
          .first;
      final createdName = Vocab.getResourceName(graphNameNode);
      expect(createdName, startsWith('persons/'));

      final createdPerson = Person.fromDataset(dataset, createdName);
      expect(createdPerson.givenName, 'John');
      expect(createdPerson.familyName, 'Doe');
    });

    test('GET /persons returns list of persons', () async {
      // Create a person
      final person = Person(name: '', jobTitle: 'Developer');
      final createReq = TransportRequest(
        method: 'POST',
        path: '/persons',
        body: nQuadsCodec.encode(person.toDataset()),
      );
      await apiServer.handleRequest(createReq);

      // Get list
      final req = TransportRequest(method: 'GET', path: '/persons');
      final response = await apiServer.handleRequest(req);

      expect(response.statusCode, 200);
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );

      // Verify dataset contains the person
      final subjects = dataset.match(
        predicate: Rdf.type,
        object: Vocab.personClass,
      ).map((q) => q.subject).toSet();
      
      expect(subjects.length, 1);
    });

    test('PATCH /persons/{id} updates only specified fields', () async {
      // 1. Create
      final person = Person(name: '', givenName: 'Old Given', familyName: 'Old Family');
      final createReq = TransportRequest(
        method: 'POST',
        path: '/persons',
        body: nQuadsCodec.encode(person.toDataset()),
      );
      final createRes = await apiServer.handleRequest(createReq);
      final createdDataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(createRes.body as String),
      );
      final graphNameNode = createdDataset
          .map((q) => q.graph)
          .whereType<NamedNode>()
          .first;
      final createdName = Vocab.getResourceName(graphNameNode);

      // 2. Patch givenName
      final updatePerson = Person(name: createdName, givenName: 'New Given');
      final patchReq = TransportRequest(
        method: 'PATCH',
        path: '/$createdName?updateMask=givenName',
        body: nQuadsCodec.encode(updatePerson.toDataset()),
      );
      final patchRes = await apiServer.handleRequest(patchReq);

      expect(patchRes.statusCode, 200);
      final patchDataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(patchRes.body as String),
      );
      final patchedPerson = Person.fromDataset(patchDataset, createdName);
      
      expect(patchedPerson.givenName, 'New Given');
      expect(patchedPerson.familyName, 'Old Family'); // Should be untouched
    });

    test('DELETE /persons/{id} removes the person', () async {
      // 1. Create
      final person = Person(name: '', givenName: 'To Delete');
      final createReq = TransportRequest(
        method: 'POST',
        path: '/persons',
        body: nQuadsCodec.encode(person.toDataset()),
      );
      final createRes = await apiServer.handleRequest(createReq);
      final createdDataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(createRes.body as String),
      );
      final graphNameNode = createdDataset
          .map((q) => q.graph)
          .whereType<NamedNode>()
          .first;
      final createdName = Vocab.getResourceName(graphNameNode);

      // 2. Delete
      final deleteReq = TransportRequest(
        method: 'DELETE',
        path: '/$createdName',
      );
      final deleteRes = await apiServer.handleRequest(deleteReq);

      expect(deleteRes.statusCode, 204);

      // 3. Verify it is gone
      final getReq = TransportRequest(method: 'GET', path: '/$createdName');
      final getRes = await apiServer.handleRequest(getReq);
      expect(getRes.statusCode, 404);
    });
  });
}
