import 'dart:js_interop';

import 'package:flutter/foundation.dart';

@JS('navigator.onLine')
external bool get _online;

@JS('window.addEventListener')
external void _listen(String event, JSFunction callback);

ValueNotifier<bool> createOnline() {
  final notifier = ValueNotifier(_online);
  _listen('online', (() => notifier.value = true).toJS);
  _listen('offline', (() => notifier.value = false).toJS);
  return notifier;
}
