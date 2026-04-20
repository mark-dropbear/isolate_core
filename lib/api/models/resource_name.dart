import 'package:uuid/uuid.dart';
import 'package:base32_codec/base32_codec.dart';

class ResourceName {
  final String path;

  const ResourceName(this.path);

  static const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ*~\$=U';

  static int _calculateChecksum(List<int> bytes) {
    final hexStr = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final intValue = BigInt.parse(hexStr, radix: 16);
    return (intValue % BigInt.from(37)).toInt();
  }

  static String _getChecksumCharacter(int value) {
    return _alphabet[value.abs()];
  }

  static String _generateId() {
    final bytes = const Uuid().v4obj().toBytes();
    final checksum = _calculateChecksum(bytes);
    final checksumChar = _getChecksumCharacter(checksum);
    final encoded = Base32Codec.crockford().encode(bytes);
    return encoded + checksumChar;
  }

  static bool _verifyId(String identifier) {
    if (identifier.isEmpty) return false;
    final value = identifier.substring(0, identifier.length - 1);
    final checksumChar = identifier[identifier.length - 1].toUpperCase();

    try {
      final bytes = Base32Codec.crockford().decode(value);
      final checksum = _calculateChecksum(bytes);
      return _getChecksumCharacter(checksum) == checksumChar;
    } catch (e) {
      return false;
    }
  }

  factory ResourceName.parse(String name) {
    final parts = name.split('/');
    if (parts.length < 2 || parts.length % 2 != 0) {
      throw FormatException(
        'Invalid resource name format. Expected alternating collections and ids, got "$name"',
      );
    }

    for (int i = 1; i < parts.length; i += 2) {
      if (!_verifyId(parts[i])) {
        throw FormatException(
          'Invalid identifier checksum in segment: "${parts[i]}"',
        );
      }
    }

    return ResourceName(name);
  }

  factory ResourceName.generate(String collection) {
    return ResourceName('$collection/${_generateId()}');
  }

  factory ResourceName.generateChild(
    ResourceName parent,
    String childCollection,
  ) {
    return ResourceName('${parent.path}/$childCollection/${_generateId()}');
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
