import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_core/api/models/person.dart';
import 'package:isolate_core/api/models/vocab.dart';
import 'package:rdf_dart/rdf_dart.dart';

void main() {
  group('Person', () {
    test('throws ArgumentError if all fields are empty', () {
      expect(
        () => Person(name: 'persons/1'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('creates successfully if at least one field is provided', () {
      final person1 = Person(name: 'persons/1', givenName: 'John');
      expect(person1.givenName, 'John');

      final person2 = Person(name: 'persons/1', familyName: 'Doe');
      expect(person2.familyName, 'Doe');

      final person3 = Person(name: 'persons/1', jobTitle: 'Developer');
      expect(person3.jobTitle, 'Developer');
    });

    test('fromJson and toJson', () {
      final json = {
        'name': 'persons/1',
        'givenName': 'Alice',
        'familyName': 'Smith',
        'jobTitle': 'Manager',
        'worksFor': <String>[],
      };
      
      final person = Person.fromJson(json);
      expect(person.name, 'persons/1');
      expect(person.givenName, 'Alice');
      expect(person.familyName, 'Smith');
      expect(person.jobTitle, 'Manager');

      expect(person.toJson(), json);
    });

    test('toDataset generates correct N-Quads', () {
      final person = Person(
        name: 'persons/1',
        givenName: 'Bob',
        familyName: 'Jones',
        jobTitle: 'Analyst',
      );

      final dataset = person.toDataset();
      final subject = Vocab.getResourceIri('persons/1');
      final graphName = subject;

      final types = dataset.match(
        subject: subject,
        predicate: Rdf.type,
        object: Vocab.personClass,
        graph: graphName,
      );
      expect(types.length, 1);

      final givenNames = dataset.match(
        subject: subject,
        predicate: Vocab.givenName,
        object: Literal('Bob'),
        graph: graphName,
      );
      expect(givenNames.length, 1);

      final familyNames = dataset.match(
        subject: subject,
        predicate: Vocab.familyName,
        object: Literal('Jones'),
        graph: graphName,
      );
      expect(familyNames.length, 1);

      final jobTitles = dataset.match(
        subject: subject,
        predicate: Vocab.jobTitle,
        object: Literal('Analyst'),
        graph: graphName,
      );
      expect(jobTitles.length, 1);
    });

    test('fromDataset parses dataset correctly', () {
      final person = Person(
        name: 'persons/1',
        givenName: 'Charlie',
        familyName: 'Brown',
        jobTitle: 'Designer',
      );
      final dataset = person.toDataset();

      final parsed = Person.fromDataset(dataset, 'persons/1');
      expect(parsed.name, 'persons/1');
      expect(parsed.givenName, 'Charlie');
      expect(parsed.familyName, 'Brown');
      expect(parsed.jobTitle, 'Designer');
    });

    test('fromDataset gracefully handles missing optional fields', () {
      final person = Person(name: 'persons/1', givenName: 'Eve');
      final dataset = person.toDataset();

      final parsed = Person.fromDataset(dataset, 'persons/1');
      expect(parsed.name, 'persons/1');
      expect(parsed.givenName, 'Eve');
      expect(parsed.familyName, '');
      expect(parsed.jobTitle, '');
    });

    test('fromDataset throws if empty graph or invalid type', () {
      final dataset = MemoryDataset();

      expect(
        () => Person.fromDataset(dataset, 'persons/1'),
        throwsA(isA<ArgumentError>()),
      );

      final subject = Vocab.getResourceIri('persons/1');
      dataset.add(Quad(
        subject: subject,
        predicate: Rdf.type,
        object: NamedNode('http://example.com/Other'),
        graph: subject,
      ));

      expect(
        () => Person.fromDataset(dataset, 'persons/1'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
