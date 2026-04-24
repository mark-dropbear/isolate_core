import 'package:rdf_dart/rdf_dart.dart';
import 'vocab.dart';

class Task {
  final String name; // resource name: taskLists/L1/tasks/T1
  final String displayName;
  final String description;
  final String actionStatus; // schema:CompletedActionStatus or PotentialActionStatus
  final List<String> instruments; // List of Thing resource names
  final DateTime? endTime;
  final List<String> agents; // List of Person or Organization resource names

  const Task({
    required this.name,
    required this.displayName,
    this.description = '',
    this.actionStatus = 'https://schema.org/PotentialActionStatus',
    this.instruments = const [],
    this.endTime,
    this.agents = const [],
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
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      agents: (json['agents'] as List<dynamic>?)
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
      if (endTime != null) 'endTime': endTime!.toIso8601String(),
      'agents': agents,
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

    final endTimes = graph.match(
      subject: subject,
      predicate: Vocab.endTime,
    );
    final endTimeStr = endTimes.isNotEmpty
        ? (endTimes.first.object as Literal).value
        : null;
    final endTime = endTimeStr != null ? DateTime.tryParse(endTimeStr) : null;

    final agentTriples = graph.match(
      subject: subject,
      predicate: Vocab.agent,
    );
    final agents = agentTriples
        .map((t) => Vocab.getResourceName(t.object as NamedNode))
        .toList();

    return Task(
      name: name,
      displayName: displayName,
      description: description,
      actionStatus: actionStatus,
      instruments: instruments,
      endTime: endTime,
      agents: agents,
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

    if (endTime != null) {
      dataset.add(
        Quad(
          subject: subject,
          predicate: Vocab.endTime,
          object: Literal(endTime!.toUtc().toIso8601String(), datatype: Xsd.dateTime),
          graph: graphName,
        ),
      );
    }

    for (final agentName in agents) {
      dataset.add(
        Quad(
          subject: subject,
          predicate: Vocab.agent,
          object: Vocab.getResourceIri(agentName),
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
    DateTime? endTime,
    bool clearEndTime = false,
    List<String>? agents,
  }) {
    return Task(
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      actionStatus: actionStatus ?? this.actionStatus,
      instruments: instruments ?? this.instruments,
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      agents: agents ?? this.agents,
    );
  }
}
