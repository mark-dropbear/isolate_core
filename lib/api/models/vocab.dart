import 'package:rdf_dart/rdf_dart.dart';

class Vocab {
  static const apiPrefix = 'https://example.com/api/';
  static const vocabPrefix = 'https://example.com/vocab#';

  // Classes
  static final thingClass = NamedNode('${vocabPrefix}Thing');

  // Properties
  static final displayName = NamedNode('${vocabPrefix}displayName');

  // Helper methods
  static NamedNode getResourceIri(String resourceName) {
    return NamedNode('$apiPrefix$resourceName');
  }

  static String getResourceName(Term node) {
    if (node is! NamedNode) throw Exception('Node is not a NamedNode');
    if (!node.value.startsWith(apiPrefix)) throw Exception('Node does not have api prefix');
    return node.value.substring(apiPrefix.length);
  }
  static Set<NamedNode> mapFieldsToPredicates(Iterable<String> fields) {
    final predicates = <NamedNode>{};
    for (final field in fields) {
      switch (field) {
        case 'displayName':
          predicates.add(displayName);
          break;
      }
    }
    return predicates;
  }
}
