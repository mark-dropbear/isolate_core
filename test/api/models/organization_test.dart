import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_core/api/models/organization.dart';
import 'package:isolate_core/api/models/vocab.dart';
import 'package:rdf_dart/rdf_dart.dart';

void main() {
  group('Organization', () {
    test('throws ArgumentError if displayName is empty', () {
      expect(
        () => Organization(name: 'organizations/1', displayName: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('creates successfully', () {
      final org = Organization(
        name: 'organizations/1',
        displayName: 'Acme',
        type: OrganizationType.localBusiness,
      );
      expect(org.displayName, 'Acme');
      expect(org.type, OrganizationType.localBusiness);
    });

    test('fromJson and toJson', () {
      final json = {
        'name': 'organizations/1',
        'displayName': 'Global NGO',
        'type': 'ngo',
        'legalName': 'Global NGO Inc.',
        'description': 'Helps people.',
        'url': 'https://globalngo.org',
      };
      
      final org = Organization.fromJson(json);
      expect(org.name, 'organizations/1');
      expect(org.displayName, 'Global NGO');
      expect(org.type, OrganizationType.ngo);
      expect(org.legalName, 'Global NGO Inc.');
      expect(org.description, 'Helps people.');
      expect(org.url, 'https://globalngo.org');

      expect(org.toJson(), json);
    });

    test('toDataset generates correct N-Quads', () {
      final org = Organization(
        name: 'organizations/1',
        displayName: 'Acme',
        type: OrganizationType.onlineBusiness,
        legalName: 'Acme Corp',
      );

      final dataset = org.toDataset();
      final subject = Vocab.getResourceIri('organizations/1');
      final graphName = subject;

      final types = dataset.match(
        subject: subject,
        predicate: Rdf.type,
        object: Vocab.onlineBusinessClass,
        graph: graphName,
      );
      expect(types.length, 1);

      final names = dataset.match(
        subject: subject,
        predicate: Vocab.name,
        object: Literal('Acme'),
        graph: graphName,
      );
      expect(names.length, 1);

      final legalNames = dataset.match(
        subject: subject,
        predicate: Vocab.legalName,
        object: Literal('Acme Corp'),
        graph: graphName,
      );
      expect(legalNames.length, 1);
    });

    test('fromDataset parses dataset correctly', () {
      final org = Organization(
        name: 'organizations/1',
        displayName: 'Acme',
        type: OrganizationType.governmentOrganization,
        legalName: 'Dept of Things',
        description: 'Does things',
        url: 'https://gov.things',
      );
      final dataset = org.toDataset();

      final parsed = Organization.fromDataset(dataset, 'organizations/1');
      expect(parsed.name, 'organizations/1');
      expect(parsed.displayName, 'Acme');
      expect(parsed.type, OrganizationType.governmentOrganization);
      expect(parsed.legalName, 'Dept of Things');
      expect(parsed.description, 'Does things');
      expect(parsed.url, 'https://gov.things');
    });

    test('fromDataset throws if empty graph or invalid type', () {
      final dataset = MemoryDataset();

      expect(
        () => Organization.fromDataset(dataset, 'organizations/1'),
        throwsA(isA<ArgumentError>()),
      );

      final subject = Vocab.getResourceIri('organizations/1');
      dataset.add(Quad(
        subject: subject,
        predicate: Vocab.description,
        object: Literal('Missing type'),
        graph: subject,
      ));

      expect(
        () => Organization.fromDataset(dataset, 'organizations/1'),
        throwsA(isA<Exception>()), // Throws Exception('Graph does not represent an Organization')
      );
    });
  });
}
