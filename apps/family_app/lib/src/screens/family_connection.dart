import 'package:flutter/foundation.dart';

import 'family_connection_stub.dart' if (dart.library.js_interop) 'family_connection_web.dart' as platform;

/// A connectivity hint only; the server remains authoritative for every action.
final ValueListenable<bool> familyOnline = platform.createOnline();
