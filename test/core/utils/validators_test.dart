import 'package:flutter_test/flutter_test.dart';
import 'package:mpesa_lehulum/core/constants/app_strings.dart';
import 'package:mpesa_lehulum/core/utils/validators.dart';

void main() {
  group('Validators.pin', () {
    test('rejects empty input', () {
      expect(Validators.pin(''), AppStrings.pinRequired);
      expect(Validators.pin(null), AppStrings.pinRequired);
      expect(Validators.pin('   '), AppStrings.pinRequired);
    });

    test('rejects non-digit input', () {
      expect(Validators.pin('12a4'), AppStrings.pinDigitsOnly);
      expect(Validators.pin('abcd'), AppStrings.pinDigitsOnly);
    });

    test('rejects wrong length', () {
      expect(Validators.pin('123'), AppStrings.pinLength);
      expect(Validators.pin('12345'), AppStrings.pinLength);
    });

    test('accepts a valid 4-digit PIN', () {
      expect(Validators.pin('1111'), isNull);
      expect(Validators.pin('0000'), isNull);
    });
  });

  group('Validators.isPinComplete', () {
    test('true only for exactly 4 digits', () {
      expect(Validators.isPinComplete('1234'), isTrue);
      expect(Validators.isPinComplete('123'), isFalse);
      expect(Validators.isPinComplete('12345'), isFalse);
      expect(Validators.isPinComplete('12a4'), isFalse);
    });
  });
}
