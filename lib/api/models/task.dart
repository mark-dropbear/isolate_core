import 'package:rdf_dart/rdf_dart.dart';
import 'vocab.dart';

class Task {
  final String name; // resource name: taskLists/L1/tasks/T1
  final String displayName;
  final String description;
  final String actionStatus; // schema:CompletedActionStatus or PotentialActionStatus
  final List<String> instruments; // List of Thing resource names

  const Task({
    required this.name,
    required this.displayName,
    this.description = '',
    this.actionStatus = 'https://schema.org/PotentialActionStatus',
    this.instruments = const [],
  });

  bool get isCompleted =>
      actionStatus == 'https://schema.org/CompletedActionStatus';

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String? ?? '',
      actionStatus: json['actionStatus'] as String? ??
          'https://schema.org/PotentialActionStatus',
      instruments: (json['instruments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
      'description': description,
      'actionStatus': actionStatus,
      'instruments': instruments,
    };
  }

  factory Task.fromDataset(Dataset dataset, String name) {
    final subject = Vocab.getResourceIri(name);
    final graphName = subject;

    final graph = dataset.getGraph(graphName);
    if (graph.isEmpty) {
      return Task(name: name, displayName: '');
    }

    // Verify type (schema:Action)
    final types = graph.match(
      subject: subject,
      predicate: Rdf.type,
      object: Vocab.actionClass,
    );
    if (types.isEmpty) {
      throw Exception('Graph does not represent a Task (Action)');
    }

    final names = graph.match(subject: subject, predicate: Vocab.name);
    final displayName = names.isNotEmpty
        ? (names.first.object as Literal).value
        : '';

    final descriptions = graph.match(
      subject: subject,
      predicate: Vocab.description,
    );
    final description = descriptions.isNotEmpty
        ? (descriptions.first.object as Literal).value
        : '';

    final statuses = graph.match(
      subject: subject,
      predicate: Vocab.actionStatus,
    );
    final actionStatus = statuses.isNotEmpty
        ? (statuses.first.object as NamedNode).value
        : 'https://schema.org/PotentialActionStatus';

    final instrumentTriples = graph.match(
      subject: subject,
      predicate: Vocab.instrument,
    );
    final instruments = instrumentTriples
        .map((t) => Vocab.getResourceName(t.object as NamedNode))
        .toList();

    return Task(
      name: name,
      displayName: displayName,
      description: description,
      actionStatus: actionStatus,
      instruments: instruments,
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
        object: Vocab.actionClass,
        graph: graphName,
      ),
    );

    dataset.add(
      Quad(
        subject: subject,
        predicate: Vocab.name,
        object: Literal(displayName),
        graph: graphName,
      ),
    );

    if (description.isNotEmpty) {
      dataset.add(
        Quad(
          subject: subject,
          predicate: Vocab.description,
          object: Literal(description),
          graph: graphName,
        ),
      );
    }

    dataset.add(
      Quad(
        subject: subject,
        predicate: Vocab.actionStatus,
        object: NamedNode(actionStatus),
        graph: graphName,
      ),
    );

    for (final instrumentName in instruments) {
      dataset.add(
        Quad(
          subject: subject,
          predicate: Vocab.instrument,
          object: Vocab.getResourceIri(instrumentName),
          graph: graphName,
        ),
      );
    }

    return dataset;
  }

  Task copyWith({
    String? name,
    String? displayName,
    String? description,
    String? actionStatus,
    List<String>? instruments,
  }) {
    return Task(
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      actionStatus: actionStatus ?? this.actionStatus,
      instruments: instruments ?? this.instruments,
    );
  }
}
