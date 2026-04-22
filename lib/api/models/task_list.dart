import 'package:rdf_dart/rdf_dart.dart';
import 'vocab.dart';

class TaskList {
  final String name; // resource name: taskLists/L1
  final String displayName;
  final List<TaskListItem> items;

  const TaskList({
    required this.name,
    required this.displayName,
    this.items = const [],
  });

  factory TaskList.fromJson(Map<String, dynamic> json) {
    return TaskList(
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      items: (json['items'] as List? ?? [])
          .map((i) => TaskListItem.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  factory TaskList.fromDataset(Dataset dataset, String name) {
    final subject = Vocab.getResourceIri(name);
    final graphName = subject;

    final graph = dataset.getGraph(graphName);
    if (graph.isEmpty) {
      return TaskList(name: name, displayName: '');
    }

    // Verify type (schema:ItemList)
    final types = graph.match(
      subject: subject,
      predicate: Rdf.type,
      object: Vocab.itemListClass,
    );
    if (types.isEmpty) {
      throw Exception('Graph does not represent a TaskList (ItemList)');
    }

    final names = graph.match(subject: subject, predicate: Vocab.name);
    final displayName = names.isNotEmpty
        ? (names.first.object as Literal).value
        : '';

    // Extract items
    final itemElements = graph.match(
      subject: subject,
      predicate: Vocab.itemListElement,
    );
    final items = <TaskListItem>[];
    for (final element in itemElements) {
      final listItemNode = element.object;
      if (listItemNode is BlankNode || listItemNode is NamedNode) {
        final positionTriples = graph.match(
          subject: listItemNode,
          predicate: Vocab.position,
        );
        final itemTriples = graph.match(
          subject: listItemNode,
          predicate: Vocab.item,
        );

        if (positionTriples.isNotEmpty && itemTriples.isNotEmpty) {
          final position =
              int.tryParse((positionTriples.first.object as Literal).value) ?? 0;
          final itemIri = (itemTriples.first.object as NamedNode).value;
          final taskName = Vocab.getResourceName(NamedNode(itemIri));

          items.add(TaskListItem(position: position, taskName: taskName));
        }
      }
    }

    // Sort items by position
    items.sort((a, b) => a.position.compareTo(b.position));

    return TaskList(name: name, displayName: displayName, items: items);
  }

  Dataset toDataset() {
    final dataset = MemoryDataset();
    final subject = Vocab.getResourceIri(name);
    final graphName = subject;

    dataset.add(
      Quad(
        subject: subject,
        predicate: Rdf.type,
        object: Vocab.itemListClass,
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

    for (final item in items) {
      final listItemNode = BlankNode(); // Using blank nodes for ListItems
      dataset.add(
        Quad(
          subject: subject,
          predicate: Vocab.itemListElement,
          object: listItemNode,
          graph: graphName,
        ),
      );
      dataset.add(
        Quad(
          subject: listItemNode,
          predicate: Rdf.type,
          object: Vocab.listItemClass,
          graph: graphName,
        ),
      );
      dataset.add(
        Quad(
          subject: listItemNode,
          predicate: Vocab.position,
          object: Literal(item.position.toString(), datatype: Xsd.integer),
          graph: graphName,
        ),
      );
      dataset.add(
        Quad(
          subject: listItemNode,
          predicate: Vocab.item,
          object: Vocab.getResourceIri(item.taskName),
          graph: graphName,
        ),
      );
    }

    return dataset;
  }

  TaskList copyWith({
    String? name,
    String? displayName,
    List<TaskListItem>? items,
  }) {
    return TaskList(
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      items: items ?? this.items,
    );
  }
}

class TaskListItem {
  final int position;
  final String taskName; // resource name of the task

  const TaskListItem({required this.position, required this.taskName});

  factory TaskListItem.fromJson(Map<String, dynamic> json) {
    return TaskListItem(
      position: json['position'] as int,
      taskName: json['taskName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'position': position, 'taskName': taskName};
  }
}
