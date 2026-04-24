import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_core/api/models/organization.dart';
import 'package:isolate_core/api/models/vocab.dart';
import 'package:isolate_core/server/api_server.dart';
import 'package:isolate_core/server/data/rdf_resource_storage.dart';
import 'package:isolate_core/transport/transport_models.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'package:file/memory.dart';

void main() {
  group('Organization API Integration Tests', () {
    late ApiServer apiServer;
    late MemoryFileSystem fs;

    setUp(() {
      fs = MemoryFileSystem();
      final storage = RdfResourceStorage(fs.file('/data.nq'));
      apiServer = ApiServer(storage: storage);
    });

    test('POST /organizations creates a new organization', () async {
      final org = Organization(name: '', displayName: 'Acme', type: OrganizationType.localBusiness);
      final req = TransportRequest(
        method: 'POST',
        path: '/organizations',
        body: nQuadsCodec.encode(org.toDataset()),
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
      expect(createdName, startsWith('organizations/'));

      final createdOrg = Organization.fromDataset(dataset, createdName);
      expect(createdOrg.displayName, 'Acme');
      expect(createdOrg.type, OrganizationType.localBusiness);
    });

    test('GET /organizations returns list of organizations', () async {
      final org = Organization(name: '', displayName: 'Acme', type: OrganizationType.ngo);
      final createReq = TransportRequest(
        method: 'POST',
        path: '/organizations',
        body: nQuadsCodec.encode(org.toDataset()),
      );
      await apiServer.handleRequest(createReq);

      final req = TransportRequest(method: 'GET', path: '/organizations');
      final response = await apiServer.handleRequest(req);

      expect(response.statusCode, 200);
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );

      final subjects = dataset.match(
        predicate: Rdf.type,
        object: Vocab.ngoClass,
      ).map((q) => q.subject).toSet();
      
      expect(subjects.length, 1);
    });

    test('PATCH /organizations/{id} updates only specified fields', () async {
      final org = Organization(name: '', displayName: 'Old Name', legalName: 'Old Legal');
      final createReq = TransportRequest(
        method: 'POST',
        path: '/organizations',
        body: nQuadsCodec.encode(org.toDataset()),
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

      final updateOrg = Organization(name: createdName, displayName: 'New Name');
      final patchReq = TransportRequest(
        method: 'PATCH',
        path: '/$createdName?updateMask=name',
        body: nQuadsCodec.encode(updateOrg.toDataset()),
      );
      final patchRes = await apiServer.handleRequest(patchReq);

      expect(patchRes.statusCode, 200);
      final patchDataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(patchRes.body as String),
      );
      final patchedOrg = Organization.fromDataset(patchDataset, createdName);
      
      expect(patchedOrg.displayName, 'New Name');
      expect(patchedOrg.legalName, 'Old Legal'); // Untouched
    });

    test('DELETE /organizations/{id} removes the organization', () async {
      final org = Organization(name: '', displayName: 'To Delete');
      final createReq = TransportRequest(
        method: 'POST',
        path: '/organizations',
        body: nQuadsCodec.encode(org.toDataset()),
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

      final deleteReq = TransportRequest(
        method: 'DELETE',
        path: '/$createdName',
      );
      final deleteRes = await apiServer.handleRequest(deleteReq);

      expect(deleteRes.statusCode, 204);

      final getReq = TransportRequest(method: 'GET', path: '/$createdName');
      final getRes = await apiServer.handleRequest(getReq);
      expect(getRes.statusCode, 404);
    });
  });
}
