import 'package:rdf_dart/rdf_dart.dart';
import 'vocab.dart';

class Thing {
  final String name;
  final String displayName;

  const Thing({
    required this.name,
    required this.displayName,
  });

  factory Thing.fromJson(Map<String, dynamic> json) {
    return Thing(
      name: json['name'] as String,
      displayName: json['displayName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
    };
  }

  factory Thing.fromDataset(Dataset dataset, String name) {
    final subject = Vocab.getResourceIri(name);
    final graphName = subject;
    
    final graph = dataset.getGraph(graphName);
    if (graph.isEmpty) {
       // Graceful fallback if no graph found
       return Thing(name: name, displayName: '');
    }

    final displayNames = graph.match(subject: subject, predicate: Vocab.displayName);
    final displayName = displayNames.isNotEmpty ? (displayNames.first.object as Literal).value : '';

    return Thing(
      name: name,
      displayName: displayName,
    );
  }

  Dataset toDataset() {
    final dataset = MemoryDataset();
    final subject = Vocab.getResourceIri(name);
    final graphName = subject;

    dataset.add(Quad(
      subject: subject,
      predicate: NamedNode('http://www.w3.org/1999/02/22-rdf-syntax-ns#type'),
      object: Vocab.thingClass,
      graph: graphName,
    ));

    dataset.add(Quad(
      subject: subject,
      predicate: Vocab.displayName,
      object: Literal(displayName),
      graph: graphName,
    ));

    return dataset;
  }

  Thing copyWith({
    String? name,
    String? displayName,
  }) {
    return Thing(
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
    );
  }
}
