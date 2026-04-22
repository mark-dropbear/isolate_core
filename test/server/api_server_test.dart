import 'package:flutter_test/flutter_test.dart';
import 'package:file/memory.dart';
import 'package:isolate_core/server/api_server.dart';
import 'package:isolate_core/server/data/rdf_resource_storage.dart';
import 'package:isolate_core/transport/transport_models.dart';
import 'package:isolate_core/api/models/thing.dart';
import 'package:isolate_core/api/models/vocab.dart';
import 'package:rdf_dart/rdf_dart.dart';

void main() {
  group('ApiServer End-to-End', () {
    late ApiServer apiServer;

    setUp(() {
      final fs = MemoryFileSystem();
      final file = fs.file('/things.nq');
      final storage = RdfResourceStorage(file);
      apiServer = ApiServer(storage: storage);
    });

    test('GET /things returns empty list initially', () async {
      final req = TransportRequest(method: 'GET', path: '/things');
      final response = await apiServer.handleRequest(req);

      expect(response.statusCode, 200);
      expect(
        response.body,
        '',
      ); // Empty memory dataset encoded returns empty string or empty quads
    });

    test('POST /things creates a thing with a generated name', () async {
      final thing = Thing(name: '', displayName: 'Test Thing');
      final req = TransportRequest(
        method: 'POST',
        path: '/things',
        body: nQuadsCodec.encode(thing.toDataset()),
      );
      final response = await apiServer.handleRequest(req);

      expect(response.statusCode, 201);
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      expect(dataset.isNotEmpty, isTrue);
      // Graph name should be generated
      final graphNames = dataset.map((q) => q.graph).whereType<NamedNode>();
      expect(graphNames.isNotEmpty, isTrue);
      expect(
        graphNames.first.value,
        startsWith('https://example.com/api/things/'),
      );
    });

    test('GET /things/{id} retrieves the created thing', () async {
      // 1. Create
      final thing = Thing(name: '', displayName: 'Test Thing');
      final createReq = TransportRequest(
        method: 'POST',
        path: '/things',
        body: nQuadsCodec.encode(thing.toDataset()),
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

      // 2. Fetch
      final getReq = TransportRequest(method: 'GET', path: '/$createdName');
      final getRes = await apiServer.handleRequest(getReq);

      expect(getRes.statusCode, 200);
      final getDataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(getRes.body as String),
      );
      expect(getDataset.isNotEmpty, isTrue);
    });

    test('PATCH /things/{id} updates only the display name', () async {
      // 1. Create
      final thing = Thing(name: '', displayName: 'Old Name');
      final createReq = TransportRequest(
        method: 'POST',
        path: '/things',
        body: nQuadsCodec.encode(thing.toDataset()),
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

      // 2. Patch
      final updateThing = Thing(name: createdName, displayName: 'New Name');
      final patchReq = TransportRequest(
        method: 'PATCH',
        path: '/$createdName?updateMask=name',
        body: nQuadsCodec.encode(updateThing.toDataset()),
      );
      final patchRes = await apiServer.handleRequest(patchReq);

      expect(patchRes.statusCode, 200);
      final patchDataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(patchRes.body as String),
      );
      final patchedThing = Thing.fromDataset(patchDataset, createdName);
      expect(patchedThing.displayName, 'New Name');
    });

    test('DELETE /things/{id} removes the thing', () async {
      // 1. Create
      final thing = Thing(name: '', displayName: 'To Delete');
      final createReq = TransportRequest(
        method: 'POST',
        path: '/things',
        body: nQuadsCodec.encode(thing.toDataset()),
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

    test('returns 404 for unknown routes', () async {
      final req = TransportRequest(method: 'GET', path: '/unknown');
      final response = await apiServer.handleRequest(req);
      expect(response.statusCode, 404);
    });

    test('returns 405 for unsupported methods', () async {
      final req = TransportRequest(method: 'PUT', path: '/things');
      final response = await apiServer.handleRequest(req);
      expect(response.statusCode, 405);
    });

    test('returns 400 for invalid resource names', () async {
      final req = TransportRequest(method: 'GET', path: '/things/123/extra');
      final response = await apiServer.handleRequest(req);
      expect(response.statusCode, 400);
    });
  });
}
