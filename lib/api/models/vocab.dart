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
  static final personClass = NamedNode('${schemaPrefix}Person');
  static final organizationClass = NamedNode('${schemaPrefix}Organization');
  static final ngoClass = NamedNode('${schemaPrefix}NGO');
  static final governmentOrganizationClass = NamedNode('${schemaPrefix}GovernmentOrganization');
  static final localBusinessClass = NamedNode('${schemaPrefix}LocalBusiness');
  static final onlineBusinessClass = NamedNode('${schemaPrefix}OnlineBusiness');

  // Properties
  static final name = NamedNode('${schemaPrefix}name');
  static final description = NamedNode('${schemaPrefix}description');
  static final itemListElement = NamedNode('${schemaPrefix}itemListElement');
  static final position = NamedNode('${schemaPrefix}position');
  static final item = NamedNode('${schemaPrefix}item');
  static final actionStatus = NamedNode('${schemaPrefix}actionStatus');
  static final endTime = NamedNode('${schemaPrefix}endTime');
  static final instrument = NamedNode('${schemaPrefix}instrument');
  static final givenName = NamedNode('${schemaPrefix}givenName');
  static final familyName = NamedNode('${schemaPrefix}familyName');
  static final jobTitle = NamedNode('${schemaPrefix}jobTitle');
  static final legalName = NamedNode('${schemaPrefix}legalName');
  static final url = NamedNode('${schemaPrefix}url');
  static final worksFor = NamedNode('${schemaPrefix}worksFor');
  static final employee = NamedNode('${schemaPrefix}employee');
  static final agent = NamedNode('${schemaPrefix}agent');

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
        case 'endTime':
          predicates.add(endTime);
          break;
        case 'instrument':
          predicates.add(instrument);
          break;
        case 'givenName':
          predicates.add(givenName);
          break;
        case 'familyName':
          predicates.add(familyName);
          break;
        case 'jobTitle':
          predicates.add(jobTitle);
          break;
        case 'legalName':
          predicates.add(legalName);
          break;
        case 'url':
          predicates.add(url);
          break;
        case 'worksFor':
          predicates.add(worksFor);
          break;
        case 'employee':
          predicates.add(employee);
          break;
        case 'agent':
          predicates.add(agent);
          break;
      }
    }
    return predicates;
  }
}
