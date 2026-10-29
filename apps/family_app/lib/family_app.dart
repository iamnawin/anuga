/// What the unified AnugaCare app (`apps/anugacare_app`, ADR 0007) mounts from the family app.
/// Screens, adapters and rules stay here unchanged; this app still builds and ships on its own.
library;

export 'src/app.dart' show familyTheme, largeText, LanguageMenu;
export 'src/auth.dart' show SupabasePhoneAuth;
export 'src/payments.dart' show Payments, SupabasePayments;
export 'src/photo_source.dart' show PhotoSource, PickedPhoto, DevicePhotoSource;
export 'src/screens/care_ui.dart' show CareHeading, CarePanel;
export 'src/screens/home_screen.dart' show HomeScreen;
export 'src/supabase_rpc.dart' show supabaseRpc;
export 'src/vault_files.dart' show VaultFiles, SupabaseVaultFiles;
