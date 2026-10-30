import 'dart:async';

import 'package:companion_app/src/screens/trips_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fake_backend.dart';
import 'support/pump.dart';

final now = DateTime.utc(2026, 10, 19, 6);

List<Object?> rows(String id, {DateTime? pickup, bool visible = true}) => [
  FakeTrip(id: id, pickupAt: pickup ?? now, detailsVisible: visible).toCompanionRow(),
];

Widget screen(CompanionApi api) =>
    TripsScreen(api: api, clock: () => now, onLocaleChanged: (_) {}, onSignOut: () async {});

void main() {
  testWidgets('refresh immediately hides old cards; failure offers visible retry', (tester) async {
    var calls = 0;
    final refresh = Completer<Object?>();
    final api = CompanionApi((_, _) async {
      calls++;
      if (calls == 1) return rows('old');
      if (calls == 2) return refresh.future;
      return <Object?>[];
    });
    await pumpLocalized(tester, screen(api));
    expect(find.byKey(const Key('trip-old')), findsOneWidget);
    await tester.tap(find.byTooltip('Refresh'));
    await tester.pump();
    expect(find.byKey(const Key('trip-old')), findsNothing);
    refresh.completeError(const RpcException('42501', 'not allowed'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('trip-old')), findsNothing);
    expect(find.byKey(const Key('trips-retry')), findsOneWidget);
    await tester.tap(find.byKey(const Key('trips-retry')));
    await tester.pumpAndSettle();
    expect(find.text('No trips assigned yet.'), findsOneWidget);
    expect(find.byKey(const Key('trips-retry')), findsNothing);
  });

  testWidgets('older refresh cannot replace a newer assignment result', (tester) async {
    var calls = 0;
    final older = Completer<Object?>();
    final newer = Completer<Object?>();
    final api = CompanionApi((_, _) async {
      calls++;
      if (calls == 1) return rows('initial');
      if (calls == 2) return await older.future;
      return await newer.future;
    });
    await pumpLocalized(tester, screen(api));
    tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.refresh)).onPressed!();
    await tester.pump();
    tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.refresh)).onPressed!();
    await tester.pump();
    expect(calls, 3);
    newer.complete(rows('new'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('trip-new')),
      findsOneWidget,
      reason: tester.widgetList<Text>(find.byType(Text)).map((text) => text.data).join(' | '),
    );
    older.complete(rows('stale'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('trip-new')), findsOneWidget);
    expect(find.byKey(const Key('trip-stale')), findsNothing);
  });

  testWidgets('previous trips have a separate heading from today and upcoming', (tester) async {
    final api = CompanionApi(
      (_, _) async => [
        ...rows('yesterday', pickup: now.subtract(const Duration(days: 1))),
        ...rows('today'),
        ...rows('tomorrow', pickup: now.add(const Duration(days: 1))),
      ],
    );
    await pumpLocalized(tester, screen(api));
    // A past trip must not be listed under Today (the old filter put it there).
    double y(Finder f) => tester.getTopLeft(f).dy;
    expect(y(find.byKey(const Key('trip-today'))), lessThan(y(find.text('Upcoming'))));
    expect(find.byKey(const Key('trip-yesterday')), findsNothing, reason: 'only today is above the fold');
    final scroll = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.byKey(const Key('trip-yesterday')), 100, scrollable: scroll);
    expect(find.text('Previous'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Previous')).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('trip-yesterday'))).dy),
    );
  });

  testWidgets('masked and empty assignments preserve restricted projection', (tester) async {
    var empty = false;
    final api = CompanionApi((_, _) async => empty ? <Object?>[] : rows('masked', visible: false));
    await pumpLocalized(tester, screen(api));
    expect(find.text('Patient details appear closer to pickup time.'), findsOneWidget);
    expect(find.textContaining('Lakshmi'), findsNothing);
    empty = true;
    await tester.tap(find.byTooltip('Refresh'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('trip-masked')), findsNothing);
    expect(find.text('No trips assigned yet.'), findsOneWidget);
    expect(tester.widget<ListView>(find.byType(ListView)).physics, isA<AlwaysScrollableScrollPhysics>());
  });
}
