import 'package:uuid/uuid.dart';

class ResourceName {
  final String path;

  const ResourceName(this.path);

  factory ResourceName.parse(String name) {
    final parts = name.split('/');
    if (parts.length < 2 || parts.length % 2 != 0) {
      throw FormatException(
        'Invalid resource name format. Expected alternating collections and ids, got "$name"',
      );
    }
    return ResourceName(name);
  }

  factory ResourceName.generate(String collection) {
    return ResourceName('$collection/${const Uuid().v4()}');
  }

  factory ResourceName.generateChild(
    ResourceName parent,
    String childCollection,
  ) {
    return ResourceName('${parent.path}/$childCollection/${const Uuid().v4()}');
  }

  String get collection {
    final parts = path.split('/');
    return parts[parts.length - 2];
  }

  String get id {
    final parts = path.split('/');
    return parts.last;
  }

  @override
  String toString() => path;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourceName &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;
}
