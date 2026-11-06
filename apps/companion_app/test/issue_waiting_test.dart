import 'package:companion_app/l10n/generated/app_localizations.dart';
import 'package:companion_app/src/app.dart';
import 'package:companion_app/src/screens/trip_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fake_backend.dart';
import 'support/pump.dart';

void main() {
  for (final locale in ['en', 'te', 'hi']) {
    testWidgets('$locale issue waits for Ops and refreshes safely at 200% text', (tester) async {
      final backend = FakeBackend()
        ..addTrip(FakeTrip(id: 't1', pickupAt: DateTime.now().toUtc(), status: TripStatus.issueReported));
      final trip = (await backend.api.myTrips()).single;
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(locale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: companionTheme(Brightness.light),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: TripScreen(api: backend.api, trip: trip),
        ),
      );
      await tester.pumpAndSettle();
      final waiting = find.byKey(const Key('issue-waiting'));
      await tester.ensureVisible(waiting);
      await tester.pumpAndSettle();
      expect(waiting, findsOneWidget);
      expect(find.byKey(const Key('action-dropped_home')), findsNothing);
      expect(tester.takeException(), isNull);
      backend.trips['t1']!.status = TripStatus.returning;
      await tapVisible(tester, find.byKey(const Key('visit-refresh')));
      expect(waiting, findsNothing);
      expect(find.byKey(const Key('action-dropped_home')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tapVisible(tester, find.byKey(const Key('action-reportIssue')));
      final help = find.byKey(const Key('issue-note-help'));
      await tester.ensureVisible(help);
      await tester.pumpAndSettle();
      expect(help, findsOneWidget);
      final l10n = AppLocalizations.of(tester.element(help));
      await tapVisible(tester, find.text(l10n.submit));
      expect(find.text(l10n.issueNoteRequired), findsOneWidget);
      expect(backend.trips['t1']!.status, TripStatus.returning);
      expect(tester.takeException(), isNull);
    });
  }
}
