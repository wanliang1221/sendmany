import 'package:flutter_test/flutter_test.dart';
import 'package:sendmany/common/validator.dart';

void main() {
  group('Validator', () {
    test('should validate onion addresses', () {
      var v = Validator();

      var invalid1 = '';
      var result = v.onionAddress(invalid1);
      expect(result, false);

      var invalid2 = '1bcdefghijklmnop.onion'; // contains a 1
      result = v.onionAddress(invalid2);
      expect(result, false);

      var invalid3 = 'abcdefghijklmnopq.onion'; // not 16 or 56 chars
      result = v.onionAddress(invalid3);
      expect(result, false);

      var invalid4 = 'abcdefghijklmnopq'; // not 16 or 56 chars
      result = v.onionAddress(invalid4);
      expect(result, false);

      var onionv2Char = 'abcdefghijklmnop.onion';
      result = v.onionAddress(onionv2Char);
      expect(result, true);

      var onionv2Num = 'abcdefghijklmnop.onion';
      result = v.onionAddress(onionv2Num);
      expect(result, true);

      var onionv2Mix = 'a2c3e4g6i5k7mnop.onion';
      result = v.onionAddress(onionv2Mix);
      expect(result, true);

      var onionv3 =
          'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcd.onion';
      result = v.onionAddress(onionv3);
      expect(result, true);
    });
  });
}
