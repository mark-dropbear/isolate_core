import 'package:rdf_dart/rdf_dart.dart';

class Vocab {
  static const apiPrefix = 'https://example.com/api/';
  static const vocabPrefix = 'https://example.com/vocab#';
  static const schemaPrefix = 'https://schema.org/';

  // Classes
  static final thingClass = NamedNode('${schemaPrefix}Thing');
  static final itemListClass = NamedNode('${schemaPrefix}ItemList');
  static final listItemClass = NamedNode('${schemaPrefix}ListItem');
  static final actionClass = NamedNode('${schemaPrefix}Action');

  // Properties
  static final name = NamedNode('${schemaPrefix}name');
  static final description = NamedNode('${schemaPrefix}description');
  static final itemListElement = NamedNode('${schemaPrefix}itemListElement');
  static final position = NamedNode('${schemaPrefix}position');
  static final item = NamedNode('${schemaPrefix}item');
  static final actionStatus = NamedNode('${schemaPrefix}actionStatus');
  static final endTime = NamedNode('${schemaPrefix}endTime');
  static final instrument = NamedNode('${schemaPrefix}instrument');

  // Action Statuses
  static final completedActionStatus =
      NamedNode('${schemaPrefix}CompletedActionStatus');
  static final potentialActionStatus =
      NamedNode('${schemaPrefix}PotentialActionStatus');

  // Helper methods
  static NamedNode getResourceIri(String resourceName) {
    return NamedNode('$apiPrefix$resourceName');
  }

  static String getResourceName(Term node) {
    if (node is! NamedNode) throw Exception('Node is not a NamedNode');
    if (!node.value.startsWith(apiPrefix)) {
      throw Exception('Node does not have api prefix');
    }
    return node.value.substring(apiPrefix.length);
  }

  static Set<NamedNode> mapFieldsToPredicates(Iterable<String> fields) {
    final predicates = <NamedNode>{};
    for (final field in fields) {
      switch (field) {
        case 'displayName':
        case 'name':
          predicates.add(name);
          break;
        case 'description':
          predicates.add(description);
          break;
        case 'actionStatus':
          predicates.add(actionStatus);
          break;
        case 'instrument':
          predicates.add(instrument);
          break;
      }
    }
    return predicates;
  }
}
