import 'package:intl/intl.dart';

/// Trips are stored in UTC; companions work in India time (UTC+05:30, no DST).
const _istOffset = Duration(hours: 5, minutes: 30);

DateTime toIst(DateTime value) => value.toUtc().add(_istOffset);

/// Calendar day in India time, for grouping trips into "today" and "upcoming".
DateTime istDay(DateTime value) {
  final ist = toIst(value);
  return DateTime.utc(ist.year, ist.month, ist.day);
}

String formatIstTime(DateTime value, String locale) => DateFormat.jm(locale).format(toIst(value));

String formatIstDateTime(DateTime value, String locale) => DateFormat('EEE d MMM, HH:mm', locale).format(toIst(value));

/// Normalizes an Indian mobile number to E.164 (+91XXXXXXXXXX), or null.
String? normalizeIndianMobile(String input) {
  final digits = input.replaceAll(RegExp(r'[\s-]'), '');
  final match = RegExp(r'^(?:\+?91|0)?([6-9]\d{9})$').firstMatch(digits);
  return match == null ? null : '+91${match.group(1)}';
}

bool isOtpCode(String input) => RegExp(r'^\d{6}$').hasMatch(input.trim());
