import 'package:intl/intl.dart';
import 'package:shared_dart/shared_dart.dart';

String formatIstTime(DateTime value, String locale) => DateFormat.jm(locale).format(toIst(value));

String formatIstDateTime(DateTime value, String locale) => DateFormat('EEE d MMM, HH:mm', locale).format(toIst(value));
