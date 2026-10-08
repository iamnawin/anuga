import 'package:intl/intl.dart';
import 'package:shared_dart/shared_dart.dart';

String formatIstTime(DateTime value, String locale) => DateFormat.jm(locale).format(toIst(value));

String formatIstDateTime(DateTime value, String locale) => DateFormat('EEE d MMM, HH:mm', locale).format(toIst(value));

/// Paise as rupees with Indian digit grouping (₹1,23,456.00).
String formatRupees(int paise, String locale) {
  final supported = locale == 'te' || locale == 'hi' ? locale : 'en_IN';
  return NumberFormat.currency(locale: supported, symbol: '₹', decimalDigits: 2).format(paise / 100);
}

String formatMonth(DateTime month, String locale) => DateFormat.yMMMM(locale).format(month);

String formatDay(DateTime day, String locale) => DateFormat('d MMM', locale).format(day);
