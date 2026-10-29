/// What the unified AnugaCare app (`apps/anugacare_app`, ADR 0007) mounts from the companion app.
/// Screens and rules stay here unchanged; this app still builds and ships on its own.
library;

export 'src/app.dart' show companionTheme;
export 'src/screens/trips_screen.dart' show TripsScreen;
