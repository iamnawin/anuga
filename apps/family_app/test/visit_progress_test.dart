import 'dart:async';

import 'package:family_app/l10n/generated/app_localizations.dart';
import 'package:family_app/src/app.dart';
import 'package:family_app/src/screens/trip_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fake_backend.dart';
import 'support/pump.dart';

class _VisitBackend {
  final fake = FakeFamilyBackend()..addVisit(FakeVisit(id: 't1', pickupAt: DateTime.utc(2026, 10, 9, 1, 30)));
  final boardParams = <Map<String, Object?>>[];
  Future<Object?> Function(String, Map<String, Object?>)? intercept;

  FamilyApi get api => FamilyApi((fn, params) async {
    if (fn == 'family_trip_board') boardParams.add(params);
    return intercept == null ? fake.rpc(fn, params) : intercept!(fn, params);
  });

  Future<void> pump(WidgetTester tester, {String locale = 'en', double scale = 1}) async {
    final patient = (await fake.api.myPatients()).single;
    final booking = (await fake.api.tripBoard('p1')).single;
    tester.view.physicalSize = const Size(320, 1000);
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
        theme: familyTheme(Brightness.light),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: TripScreen(api: api, patient: patient, booking: booking),
      ),
    );
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('progress strip follows the exact nine-state visit lifecycle', (tester) async {
    final backend = _VisitBackend();
    await backend.pump(tester);
    expect(byKey('visit-progress'), findsOneWidget);
    for (var index = 0; index < 9; index++) {
      expect(byKey('visit-progress-stage-$index'), findsOneWidget);
    }
    expect(byKey('visit-progress-current-0'), findsOneWidget);

    backend.fake.addEvent(backend.fake.visits['t1']!, TripStatus.handedOver, TransitionActor.companion, 'Front desk');
    await tapVisible(tester, byKey('visit-refresh'));
    expect(byKey('visit-progress-current-4'), findsOneWidget);
    expect(byKey('visit-progress-current-0'), findsNothing);
  });

  testWidgets('service issue keeps the last persisted non-issue progress stage', (tester) async {
    final backend = _VisitBackend();
    final visit = backend.fake.visits['t1']!;
    backend.fake.addEvent(visit, TripStatus.companionEnRoute, TransitionActor.companion, null);
    backend.fake.addEvent(visit, TripStatus.pickedUp, TransitionActor.companion, 'pickup OTP verified');
    backend.fake.addEvent(visit, TripStatus.issueReported, TransitionActor.companion, 'private marker');
    await backend.pump(tester);
    expect(byKey('visit-progress-current-2'), findsOneWidget);
    expect(find.textContaining('private marker'), findsNothing);
  });

  for (final terminal in [TripStatus.cancelled, TripStatus.noShow]) {
    testWidgets('${terminal.dbValue} does not look like linear journey progress', (tester) async {
      final backend = _VisitBackend();
      backend.fake.visits['t1']!.status = terminal;
      await backend.pump(tester);
      expect(byKey('visit-progress'), findsNothing);
    });
  }

  testWidgets('refresh reads historical visit status, assignment and persisted completion milestone', (tester) async {
    final backend = _VisitBackend();
    await backend.pump(tester);
    expect(byKey('visit-latest-update'), findsNothing, reason: 'No invented timestamp before a milestone');
    final visit = backend.fake.visits['t1']!;
    visit.companionName = 'Ravi Companion (synthetic)';
    backend.fake.addEvent(visit, TripStatus.completed, TransitionActor.companion, 'Returned home (synthetic).');
    await tapVisible(tester, byKey('visit-refresh'));
    expect(find.descendant(of: byKey('status'), matching: find.text('Completed')), findsOneWidget);
    expect(find.textContaining('Ravi Companion'), findsOneWidget);
    expect(find.textContaining('Asha Companion'), findsNothing);
    expect(find.textContaining('Returned home (synthetic).'), findsOneWidget);
    expect(byKey('visit-latest-update'), findsOneWidget);
    expect(find.textContaining('9 Oct 2026, 06:31:00 IST'), findsNWidgets(2));
    expect(byKey('get-pickup-code'), findsNothing);
    expect(byKey('cancel-trip'), findsNothing);
    final range = backend.boardParams.last;
    expect(DateTime.parse(range['p_from']! as String).isBefore(visit.pickupAt), isTrue);
    expect(DateTime.parse(range['p_to']! as String).isAfter(visit.pickupAt), isTrue);
  });

  testWidgets('failed or denied refresh hides stale details and actions, then retries', (tester) async {
    final backend = _VisitBackend();
    await backend.pump(tester);
    backend.intercept = (fn, params) async => throw const RpcException('42501', 'not allowed');
    await tapVisible(tester, byKey('visit-refresh'));
    expect(byKey('status'), findsNothing);
    expect(byKey('visit-progress'), findsNothing);
    expect(find.textContaining('Asha Companion'), findsNothing);
    expect(byKey('get-pickup-code'), findsNothing);
    expect(byKey('cancel-trip'), findsNothing);
    expect(byKey('error'), findsOneWidget);
    backend.intercept = null;
    await tapVisible(tester, byKey('visit-refresh'));
    expect(byKey('status'), findsOneWidget);
    expect(byKey('error'), findsNothing);
  });

  testWidgets('a slow earlier refresh cannot replace newer persisted progress', (tester) async {
    final backend = _VisitBackend();
    await backend.pump(tester);
    final pending = <({Completer<Object?> result, Object? rows})>[];
    backend.intercept = (fn, params) async {
      final rows = await backend.fake.rpc(fn, params);
      final result = Completer<Object?>();
      pending.add((result: result, rows: rows));
      return result.future;
    };
    await tester.tap(byKey('visit-refresh'));
    await tester.pumpAndSettle();
    expect(byKey('status'), findsNothing);
    backend.fake.addEvent(backend.fake.visits['t1']!, TripStatus.pickedUp, TransitionActor.companion, null);
    await tester.tap(byKey('visit-refresh'));
    await tester.pumpAndSettle();
    expect(pending, hasLength(4));
    for (final call in pending.skip(2)) {
      call.result.complete(call.rows);
    }
    await tester.pumpAndSettle();
    for (final call in pending.take(2)) {
      call.result.complete(call.rows);
    }
    await tester.pumpAndSettle();
    expect(find.descendant(of: byKey('status'), matching: find.text('Picked up')), findsOneWidget);
    expect(byKey('event-1'), findsOneWidget);
    expect(byKey('get-pickup-code'), findsNothing);
  });

  testWidgets('resuming reloads persisted progress without polling', (tester) async {
    final backend = _VisitBackend();
    await backend.pump(tester);
    final calls = backend.boardParams.length;
    backend.fake.addEvent(backend.fake.visits['t1']!, TripStatus.handedOver, TransitionActor.companion, 'Front desk');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(backend.boardParams, hasLength(calls + 1));
    expect(find.descendant(of: byKey('status'), matching: find.text('Handed over to centre staff')), findsOneWidget);
    await tester.pump(const Duration(minutes: 1));
    expect(backend.boardParams, hasLength(calls + 1));
  });

  for (final locale in ['en', 'te', 'hi']) {
    testWidgets('$locale progress supports narrow 200% text', (tester) async {
      final backend = _VisitBackend();
      backend.fake.addEvent(
        backend.fake.visits['t1']!,
        TripStatus.completed,
        TransitionActor.companion,
        'Synthetic note',
      );
      await backend.pump(tester, locale: locale, scale: 2);
      expect(byKey('visit-latest-update'), findsOneWidget);
      expect(byKey('visit-progress'), findsOneWidget);
      expect(byKey('visit-progress-current-8'), findsOneWidget);
      await tester.ensureVisible(byKey('event-1'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
