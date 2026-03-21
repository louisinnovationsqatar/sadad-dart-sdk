// SADAD Payment Gateway SDK for Dart
// Built by Louis Innovations (www.louis-innovations.com)

import 'package:sadad_qatar/sadad_qatar.dart';
import 'package:test/test.dart';

void main() {
  group('SaltGenerator', () {
    const charset =
        'AbcDE123IJKLMN67QRSTUVWXYZaBCdefghijklmn123opq45rs67tuv89wxyz0FGH45OP89';

    test('generates salt of default length 4', () {
      final salt = SaltGenerator.generate();
      expect(salt.length, 4);
    });

    test('generates salt of custom length', () {
      expect(SaltGenerator.generate(8).length, 8);
      expect(SaltGenerator.generate(1).length, 1);
      expect(SaltGenerator.generate(16).length, 16);
    });

    test('only uses characters from the SADAD charset', () {
      for (var i = 0; i < 100; i++) {
        final salt = SaltGenerator.generate(4);
        for (final char in salt.split('')) {
          expect(charset.contains(char), isTrue,
              reason: 'Unexpected char "$char" in salt "$salt"');
        }
      }
    });

    test('generates different salts on repeated calls (randomness check)', () {
      final salts = {for (var i = 0; i < 50; i++) SaltGenerator.generate()};
      // With a 72-char charset and length 4, collision probability is extremely low
      expect(salts.length, greaterThan(1));
    });

    test('generates salt of length 0', () {
      expect(SaltGenerator.generate(0), '');
    });
  });
}
