import 'package:companion_app/src/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes Indian mobile numbers to E.164', () {
    expect(normalizeIndianMobile('9000000201'), '+919000000201');
    expect(normalizeIndianMobile('+91 90000 00201'), '+919000000201');
    expect(normalizeIndianMobile('09000000201'), '+919000000201');
    expect(normalizeIndianMobile('12345'), isNull);
    expect(normalizeIndianMobile('5000000201'), isNull);
  });

  test('OTP codes are six digits', () {
    expect(isOtpCode('123456'), isTrue);
    expect(isOtpCode('12345'), isFalse);
    expect(isOtpCode('12a456'), isFalse);
  });

  test('India-time day boundaries', () {
    expect(istDay(DateTime.utc(2026, 10, 7, 19)), DateTime.utc(2026, 10, 8));
    expect(istDay(DateTime.utc(2026, 10, 7, 18)), DateTime.utc(2026, 10, 7));
    expect(toIst(DateTime.utc(2026, 10, 9, 1, 30)), DateTime.utc(2026, 10, 9, 7));
  });
}
