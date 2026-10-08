import 'package:companion_app/src/format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting());

  test('times are shown in India time', () {
    final pickup = DateTime.utc(2026, 10, 9, 1, 30); // 07:00 IST
    expect(formatIstDateTime(pickup, 'en'), 'Fri 9 Oct, 07:00');
    // ICU puts a narrow no-break space before AM.
    expect(formatIstTime(pickup, 'en').replaceAll('\u202f', ' '), '7:00 AM');
  });
}
