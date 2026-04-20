import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_core/api/models/resource_name.dart';

void main() {
  group('ResourceName', () {
    test('generate() creates a valid Base32 resource name', () {
      final name = ResourceName.generate('things');
      expect(name.collection, 'things');
      expect(name.id, isNotEmpty);
      expect(name.id.length, 27); // 26 base32 chars + 1 checksum
      expect(name.toString(), 'things/${name.id}');
    });

    test('generateChild() creates a valid nested resource name', () {
      final parent = ResourceName.generate('things');
      final child = ResourceName.generateChild(parent, 'tasks');
      expect(child.collection, 'tasks');
      expect(child.id.length, 27);
      expect(child.toString(), '${parent.path}/tasks/${child.id}');
    });

    test('parse() successfully parses a valid string', () {
      final original = ResourceName.generate('things');
      final parsed = ResourceName.parse(original.path);
      expect(parsed.collection, 'things');
      expect(parsed.id, original.id);
    });

    test('parse() throws FormatException on invalid format or checksum', () {
      expect(() => ResourceName.parse('things'), throwsFormatException);
      expect(
        () => ResourceName.parse('things/123/extra'),
        throwsFormatException, // invalid format length
      );
      expect(
        () => ResourceName.parse('things/INVALID123~'),
        throwsFormatException, // invalid checksum
      );
    });

    test('equality and hashCode work as expected', () {
      final name1Str = ResourceName.generate('things').path;
      final name1 = ResourceName(name1Str);
      final name2 = ResourceName(name1Str);
      final name3 = ResourceName.generate('things');

      expect(name1, equals(name2));
      expect(name1.hashCode, equals(name2.hashCode));
      expect(name1, isNot(equals(name3)));
    });
  });
}
