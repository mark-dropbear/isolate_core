import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_core/api/models/resource_name.dart';

void main() {
  group('ResourceName', () {
    test('generate() creates a valid UUID resource name', () {
      final name = ResourceName.generate('things');
      expect(name.collection, 'things');
      expect(name.id, isNotEmpty);
      expect(name.toString(), 'things/${name.id}');
    });

    test('parse() successfully parses a valid string', () {
      final name = ResourceName.parse('things/123');
      expect(name.collection, 'things');
      expect(name.id, '123');
    });

    test('parse() throws FormatException on invalid format', () {
      expect(() => ResourceName.parse('things'), throwsFormatException);
      expect(() => ResourceName.parse('things/123/extra'), throwsFormatException);
    });

    test('equality and hashCode work as expected', () {
      const name1 = ResourceName('things/123');
      const name2 = ResourceName('things/123');
      const name3 = ResourceName('things/456');
      
      expect(name1, equals(name2));
      expect(name1.hashCode, equals(name2.hashCode));
      expect(name1, isNot(equals(name3)));
    });
  });
}
