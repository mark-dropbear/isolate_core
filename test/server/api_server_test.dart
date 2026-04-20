import 'package:flutter_test/flutter_test.dart';
import 'package:file/memory.dart';
import 'package:isolate_core/server/api_server.dart';
import 'package:isolate_core/server/data/file_thing_storage.dart';
import 'package:isolate_core/transport/transport_models.dart';
import 'dart:convert';

void main() {
  group('ApiServer End-to-End', () {
    late ApiServer apiServer;

    setUp(() {
      final fs = MemoryFileSystem();
      final file = fs.file('/things.json');
      final storage = FileThingStorage(file);
      apiServer = ApiServer(storage: storage);
    });

    test('GET /things returns empty list initially', () async {
      final req = TransportRequest(method: 'GET', path: '/things');
      final response = await apiServer.handleRequest(req);

      expect(response.statusCode, 200);
      expect(response.body, {'things': []});
    });

    test('POST /things creates a thing with a generated name', () async {
      final req = TransportRequest(
        method: 'POST',
        path: '/things',
        body: {'displayName': 'Test Thing'},
      );
      final response = await apiServer.handleRequest(req);

      expect(response.statusCode, 201);
      final body = response.body as Map<String, dynamic>;
      expect(body['name'], startsWith('things/'));
      expect(body['displayName'], 'Test Thing');
    });

    test('GET /things/{id} retrieves the created thing', () async {
      // 1. Create
      final createReq = TransportRequest(
        method: 'POST',
        path: '/things',
        body: {'displayName': 'Test Thing'},
      );
      final createRes = await apiServer.handleRequest(createReq);
      final createdName = (createRes.body as Map<String, dynamic>)['name'] as String;

      // 2. Fetch
      final getReq = TransportRequest(method: 'GET', path: '/$createdName');
      final getRes = await apiServer.handleRequest(getReq);

      expect(getRes.statusCode, 200);
      expect((getRes.body as Map<String, dynamic>)['displayName'], 'Test Thing');
    });

    test('PATCH /things/{id} updates only the display name', () async {
      // 1. Create
      final createReq = TransportRequest(
        method: 'POST',
        path: '/things',
        body: {'displayName': 'Old Name'},
      );
      final createRes = await apiServer.handleRequest(createReq);
      final createdName = (createRes.body as Map<String, dynamic>)['name'] as String;

      // 2. Patch
      final patchReq = TransportRequest(
        method: 'PATCH',
        path: '/$createdName?updateMask=displayName',
        body: {'displayName': 'New Name'},
      );
      final patchRes = await apiServer.handleRequest(patchReq);

      expect(patchRes.statusCode, 200);
      expect((patchRes.body as Map<String, dynamic>)['displayName'], 'New Name');
    });

    test('DELETE /things/{id} removes the thing', () async {
      // 1. Create
      final createReq = TransportRequest(
        method: 'POST',
        path: '/things',
        body: {'displayName': 'To Delete'},
      );
      final createRes = await apiServer.handleRequest(createReq);
      final createdName = (createRes.body as Map<String, dynamic>)['name'] as String;

      // 2. Delete
      final deleteReq = TransportRequest(method: 'DELETE', path: '/$createdName');
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
