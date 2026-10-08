/// India-specific input and time helpers shared by the apps.
library;

/// Trips are stored in UTC; users work in India time (UTC+05:30, no daylight saving).
const istOffset = Duration(hours: 5, minutes: 30);

/// [value] shifted to India wall-clock time (as a UTC DateTime, for formatting).
DateTime toIst(DateTime value) => value.toUtc().add(istOffset);

/// Calendar day in India time, for grouping trips into "today" and "upcoming".
DateTime istDay(DateTime value) {
  final ist = toIst(value);
  return DateTime.utc(ist.year, ist.month, ist.day);
}

/// Normalizes an Indian mobile number to E.164 (+91XXXXXXXXXX), or null.
/// Accepts 10 digits, or with a leading 0, 91 or +91, ignoring spaces and dashes.
String? normalizeIndianMobile(String input) {
  final digits = input.replaceAll(RegExp(r'[\s-]'), '');
  final match = RegExp(r'^(?:\+?91|0)?([6-9]\d{9})$').firstMatch(digits);
  return match == null ? null : '+91${match.group(1)}';
}

/// Six digits: the format of both the sign-in code and the pickup code.
bool isOtpCode(String input) => RegExp(r'^\d{6}$').hasMatch(input.trim());
