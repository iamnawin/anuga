import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';
import 'src/auth.dart';
import 'src/payments.dart';
import 'src/photo_source.dart';
import 'src/supabase_rpc.dart';
import 'src/vault_files.dart';

// Configure with --dart-define (values from `supabase status -o env` for local):
//   flutter run --dart-define=SUPABASE_URL=http://10.0.2.2:54321 --dart-define=SUPABASE_PUBLISHABLE_KEY=...
// Only the public (publishable / anon) key belongs in an app; permissions are enforced by the database.
const _url = String.fromEnvironment('SUPABASE_URL');
const _publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_url.isEmpty || _publishableKey.isEmpty) {
    throw StateError('Pass --dart-define=SUPABASE_URL=... and --dart-define=SUPABASE_PUBLISHABLE_KEY=...');
  }
  await Supabase.initialize(
    url: _url,
    publishableKey: _publishableKey,
    authOptions: FlutterAuthClientOptions(
      localStorage: kIsWeb ? SharedPreferencesLocalStorage(persistSessionKey: 'anuga-family-auth') : null,
    ),
  );
  final client = Supabase.instance.client;
  final auth = SupabasePhoneAuth(client);
  runApp(
    FamilyApp(
      api: FamilyApi(supabaseRpc(client, onAccessDenied: auth.invalidateAccess)),
      auth: auth,
      files: SupabaseVaultFiles(client, _url, onAccessDenied: auth.invalidateAccess),
      photos: DevicePhotoSource(),
      payments: SupabasePayments(client, onAccessDenied: auth.invalidateAccess),
    ),
  );
}
