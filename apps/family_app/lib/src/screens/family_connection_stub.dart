import 'package:flutter/foundation.dart';

// Native transport failures are handled by each screen's retry state. No
// connectivity SDK or offline patient-data store is introduced.
ValueNotifier<bool> createOnline() => ValueNotifier(true);
