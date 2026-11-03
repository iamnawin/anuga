import 'dart:async';

import 'package:companion_app/src/screens/trip_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fake_backend.dart';
import 'support/pump.dart';

final pickup = DateTime.utc(2026, 10, 9, 1, 30);
Finder byKey(String key) => find.byKey(Key(key));

Future<FakeBackend> openVisit(WidgetTester tester, {RpcCaller? rpc}) async {
  final backend = FakeBackend()..addTrip(FakeTrip(id: 't1', pickupAt: pickup));
  final trip = (await backend.api.myTrips()).single;
  await pumpLocalized(tester, TripScreen(api: rpc == null ? backend.api : CompanionApi(rpc), trip: trip));
  return backend;
}

void main() {
  testWidgets('Refresh reads the exact visit and replaces externally persisted status', (tester) async {
    final calls = <Map<String, Object?>>[];
    final backend = FakeBackend()..addTrip(FakeTrip(id: 't1', pickupAt: pickup));
    final trip = (await backend.api.myTrips()).single;
    await pumpLocalized(
      tester,
      TripScreen(
        api: CompanionApi((fn, params) {
          calls.add(params);
          return backend.rpc(fn, params);
        }),
        trip: trip,
      ),
    );
    backend.trips['t1']!.status = TripStatus.completed;
    await tapVisible(tester, byKey('visit-refresh'));
    expect(find.text('Completed'), findsOneWidget);
    expect(byKey('action-companion_en_route'), findsNothing);
    expect(calls.single['p_from'], pickup.subtract(const Duration(seconds: 1)).toIso8601String());
    expect(calls.single['p_to'], pickup.add(const Duration(seconds: 1)).toIso8601String());
  });

  testWidgets('Refresh clears patient fields and actions when visit is reassigned', (tester) async {
    final backend = await openVisit(tester);
    backend.trips['t1']!.companionId = 'ravi';
    await tapVisible(tester, byKey('visit-refresh'));
    expect(find.textContaining('Lakshmi Rao'), findsNothing);
    expect(find.textContaining('22 Sample Colony'), findsNothing);
    expect(byKey('action-companion_en_route'), findsNothing);
    expect(find.text('Not allowed. This trip may have been reassigned.'), findsOneWidget);
  });

  testWidgets('Refresh uses masked patient projection when detail window closes', (tester) async {
    final backend = await openVisit(tester);
    backend.trips['t1']!.detailsVisible = false;
    await tapVisible(tester, byKey('visit-refresh'));
    expect(find.textContaining('Lakshmi Rao'), findsNothing);
    expect(find.textContaining('22 Sample Colony'), findsNothing);
    expect(find.text('Patient details appear closer to pickup time.'), findsOneWidget);
  });

  testWidgets('Failed refresh hides stale fields and recovers using Refresh', (tester) async {
    var fail = true;
    final fresh = FakeTrip(id: 't1', pickupAt: pickup, status: TripStatus.returning);
    await openVisit(
      tester,
      rpc: (_, _) async {
        if (fail) throw const RpcException('08006', 'connection lost');
        return [fresh.toCompanionRow()];
      },
    );
    await tapVisible(tester, byKey('visit-refresh'));
    expect(find.textContaining('Lakshmi Rao'), findsNothing);
    expect(byKey('action-companion_en_route'), findsNothing);
    expect(find.text('Something went wrong. Try again.'), findsOneWidget);
    fail = false;
    await tapVisible(tester, byKey('visit-refresh'));
    expect(find.text('Returning'), findsOneWidget);
    expect(byKey('action-dropped_home'), findsOneWidget);
  });

  testWidgets('Loading clears details and older response cannot replace newer status', (tester) async {
    final responses = <Completer<Object?>>[];
    await openVisit(
      tester,
      rpc: (_, _) {
        final response = Completer<Object?>();
        responses.add(response);
        return response.future;
      },
    );
    await tester.tap(byKey('visit-refresh'));
    await tester.pump();
    expect(find.textContaining('Lakshmi Rao'), findsNothing);
    expect(byKey('action-companion_en_route'), findsNothing);
    await tester.tap(byKey('visit-refresh'));
    await tester.pump();
    responses[1].complete([FakeTrip(id: 't1', pickupAt: pickup, status: TripStatus.completed).toCompanionRow()]);
    await tester.pumpAndSettle();
    responses[0].complete([FakeTrip(id: 't1', pickupAt: pickup).toCompanionRow()]);
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);
    expect(byKey('action-companion_en_route'), findsNothing);
  });

  testWidgets('Resuming reloads persisted completion without reopening visit', (tester) async {
    final backend = await openVisit(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    backend.trips['t1']!.status = TripStatus.completed;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);
  });

  testWidgets('Refresh recovers an unknown mutation result without replaying action', (tester) async {
    final backend = FakeBackend()..addTrip(FakeTrip(id: 't1', pickupAt: pickup));
    final trip = (await backend.api.myTrips()).single;
    await pumpLocalized(
      tester,
      TripScreen(
        api: CompanionApi((fn, params) async {
          final result = await backend.rpc(fn, params);
          if (fn == 'advance_trip') throw const RpcException('08006', 'response lost after commit');
          return result;
        }),
        trip: trip,
      ),
    );
    await tapVisible(tester, byKey('action-companion_en_route'));
    expect(backend.trips['t1']!.status, TripStatus.companionEnRoute);
    await tapVisible(tester, byKey('visit-refresh'));
    expect(find.text('On the way'), findsOneWidget);
    expect(byKey('action-picked_up'), findsOneWidget);
    expect(backend.calls.where((fn) => fn == 'advance_trip'), hasLength(1));
  });
}
