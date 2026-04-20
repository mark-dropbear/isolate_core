import 'package:uuid/uuid.dart';

class ResourceName {
  final String collection;
  final String id;

  const ResourceName(this.collection, this.id);

  factory ResourceName.parse(String name) {
    final parts = name.split('/');
    if (parts.length != 2) {
      throw FormatException('Invalid resource name format. Expected "collection/id", got "$name"');
    }
    return ResourceName(parts[0], parts[1]);
  }

  factory ResourceName.generate(String collection) {
    return ResourceName(collection, const Uuid().v4());
  }

  @override
  String toString() => '$collection/$id';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourceName &&
          runtimeType == other.runtimeType &&
          collection == other.collection &&
          id == other.id;

  @override
  int get hashCode => collection.hashCode ^ id.hashCode;
}
