import 'package:rdf_dart/rdf_dart.dart';
import 'vocab.dart';

enum OrganizationType {
  organization('Organization'),
  ngo('NGO'),
  governmentOrganization('GovernmentOrganization'),
  localBusiness('LocalBusiness'),
  onlineBusiness('OnlineBusiness');

  final String schemaName;
  const OrganizationType(this.schemaName);

  NamedNode get toNamedNode => NamedNode('${Vocab.schemaPrefix}$schemaName');

  static OrganizationType fromNamedNode(NamedNode node) {
    return OrganizationType.values.firstWhere(
      (type) => type.toNamedNode.value == node.value,
      orElse: () => OrganizationType.organization, // default fallback
    );
  }
}

class Organization {
  final String name; // resource name: organizations/O1
  final OrganizationType type;
  final String displayName; // maps to schema:name
  final String legalName;
  final String description;
  final String url;

  Organization({
    required this.name,
    required this.displayName,
    this.type = OrganizationType.organization,
    this.legalName = '',
    this.description = '',
    this.url = '',
  }) {
    if (displayName.isEmpty) {
      throw ArgumentError('An Organization must have a name (displayName).');
    }
  }

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      type: OrganizationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => OrganizationType.organization,
      ),
      legalName: json['legalName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
      'type': type.name,
      'legalName': legalName,
      'description': description,
      'url': url,
    };
  }

  factory Organization.fromDataset(Dataset dataset, String name) {
    final subject = Vocab.getResourceIri(name);
    final graphName = subject;

    final graph = dataset.getGraph(graphName);
    if (graph.isEmpty) {
      throw ArgumentError('Graph is empty for Organization $name');
    }

    // Determine type
    final types = graph.match(subject: subject, predicate: Rdf.type);
    if (types.isEmpty) {
      throw Exception('Graph does not represent an Organization');
    }
    
    // Find the most specific OrganizationType
    OrganizationType? orgType;
    for (final t in types) {
      if (t.object is NamedNode) {
        try {
          orgType = OrganizationType.fromNamedNode(t.object as NamedNode);
          if (orgType != OrganizationType.organization) {
            break; // found a specific type
          }
        } catch (_) {
          // Ignore unrelated types
        }
      }
    }
    orgType ??= OrganizationType.organization;

    final names = graph.match(subject: subject, predicate: Vocab.name);
    final displayName = names.isNotEmpty
        ? (names.first.object as Literal).value
        : '';
        
    if (displayName.isEmpty) {
      throw ArgumentError('Organization must have a name.');
    }

    final legalNames = graph.match(subject: subject, predicate: Vocab.legalName);
    final legalName = legalNames.isNotEmpty
        ? (legalNames.first.object as Literal).value
        : '';

    final descriptions = graph.match(subject: subject, predicate: Vocab.description);
    final description = descriptions.isNotEmpty
        ? (descriptions.first.object as Literal).value
        : '';

    final urls = graph.match(subject: subject, predicate: Vocab.url);
    final url = urls.isNotEmpty
        ? (urls.first.object as NamedNode).value
        : '';

    return Organization(
      name: name,
      displayName: displayName,
      type: orgType,
      legalName: legalName,
      description: description,
      url: url,
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
        object: type.toNamedNode,
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

    if (legalName.isNotEmpty) {
      dataset.add(
        Quad(
          subject: subject,
          predicate: Vocab.legalName,
          object: Literal(legalName),
          graph: graphName,
        ),
      );
    }

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

    if (url.isNotEmpty) {
      dataset.add(
        Quad(
          subject: subject,
          predicate: Vocab.url,
          object: NamedNode(url),
          graph: graphName,
        ),
      );
    }

    return dataset;
  }

  Organization copyWith({
    String? name,
    String? displayName,
    OrganizationType? type,
    String? legalName,
    String? description,
    String? url,
  }) {
    return Organization(
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      type: type ?? this.type,
      legalName: legalName ?? this.legalName,
      description: description ?? this.description,
      url: url ?? this.url,
    );
  }
}
