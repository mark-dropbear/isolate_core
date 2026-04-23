import 'package:rdf_dart/rdf_dart.dart';
import 'vocab.dart';

class Person {
  final String name; // resource name: persons/P1
  final String givenName;
  final String familyName;
  final String jobTitle;

  Person({
    required this.name,
    this.givenName = '',
    this.familyName = '',
    this.jobTitle = '',
  }) {
    if (givenName.isEmpty && familyName.isEmpty && jobTitle.isEmpty) {
      throw ArgumentError('A Person must have at least one field (givenName, familyName, or jobTitle) populated.');
    }
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['name'] as String,
      givenName: json['givenName'] as String? ?? '',
      familyName: json['familyName'] as String? ?? '',
      jobTitle: json['jobTitle'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'givenName': givenName,
      'familyName': familyName,
      'jobTitle': jobTitle,
    };
  }

  factory Person.fromDataset(Dataset dataset, String name) {
    final subject = Vocab.getResourceIri(name);
    final graphName = subject;

    final graph = dataset.getGraph(graphName);
    if (graph.isEmpty) {
      // Graceful fallback if no graph found, though it will fail validation if all empty.
      // We will return a placeholder that passes validation just for empty graphs 
      // (though an empty graph is technically invalid for a Person).
      throw ArgumentError('Graph is empty for Person $name');
    }

    // Verify type
    final types = graph.match(
      subject: subject,
      predicate: Rdf.type,
      object: Vocab.personClass,
    );
    if (types.isEmpty) {
      throw Exception('Graph does not represent a Person');
    }

    final givenNames = graph.match(subject: subject, predicate: Vocab.givenName);
    final givenName = givenNames.isNotEmpty
        ? (givenNames.first.object as Literal).value
        : '';

    final familyNames = graph.match(subject: subject, predicate: Vocab.familyName);
    final familyName = familyNames.isNotEmpty
        ? (familyNames.first.object as Literal).value
        : '';

    final jobTitles = graph.match(subject: subject, predicate: Vocab.jobTitle);
    final jobTitle = jobTitles.isNotEmpty
        ? (jobTitles.first.object as Literal).value
        : '';

    return Person(
      name: name,
      givenName: givenName,
      familyName: familyName,
      jobTitle: jobTitle,
    );
  }

  Dataset toDataset() {
    final dataset = MemoryDataset();
    final subject = Vocab.getResourceIri(name);
    final graphName = subject;

    dataset.add(
      Quad(
        subject: subject,
        predicate: Rdf.type,
        object: Vocab.personClass,
        graph: graphName,
      ),
    );

    if (givenName.isNotEmpty) {
      dataset.add(
        Quad(
          subject: subject,
          predicate: Vocab.givenName,
          object: Literal(givenName),
          graph: graphName,
        ),
      );
    }

    if (familyName.isNotEmpty) {
      dataset.add(
        Quad(
          subject: subject,
          predicate: Vocab.familyName,
          object: Literal(familyName),
          graph: graphName,
        ),
      );
    }

    if (jobTitle.isNotEmpty) {
      dataset.add(
        Quad(
          subject: subject,
          predicate: Vocab.jobTitle,
          object: Literal(jobTitle),
          graph: graphName,
        ),
      );
    }

    return dataset;
  }

  Person copyWith({
    String? name,
    String? givenName,
    String? familyName,
    String? jobTitle,
  }) {
    return Person(
      name: name ?? this.name,
      givenName: givenName ?? this.givenName,
      familyName: familyName ?? this.familyName,
      jobTitle: jobTitle ?? this.jobTitle,
    );
  }
}
