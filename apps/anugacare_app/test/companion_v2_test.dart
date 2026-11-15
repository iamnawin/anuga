import 'dart:async';

import 'package:anugacare_app/l10n/generated/app_localizations.dart';
import 'package:anugacare_app/src/screens/companion_home_screen.dart';
import 'package:anugacare_app/src/screens/companion_help_screen.dart';
import 'package:anugacare_app/src/screens/companion_trip_screen.dart';
import 'package:anugacare_app/src/screens/companion_ui.dart';
import 'package:companion_app/companion_app.dart' show companionTheme;
import 'package:family_app/l10n/generated/app_localizations.dart' as family_l10n;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

final _pickup = DateTime.utc(2026, 11, 12, 1, 30);
final _now = _pickup.subtract(const Duration(minutes: 30));

class _Backend {
  _Backend(this.status);
  TripStatus status;
  bool visible = true;
  bool missing = false;
  Object? readError;
  Object? writeError;
  Future<Object?>? delayedRead;
  List<Map<String, Object?>>? rows;
  DateTime? startAllowedAt;
  Map<String, Object?> otp = {'ok': true, 'status': 'picked_up'};
  final calls = <(String, Map<String, Object?>)>[];
  CompanionApi get api => CompanionApi(call);

  Map<String, Object?> get row => {
    'trip_id': 'synthetic-trip',
    'scheduled_pickup_at': _pickup.toIso8601String(),
    'scheduled_return_at': _pickup.add(const Duration(hours: 5)).toIso8601String(),
    'status': status.dbValue,
    'centre_name': 'City Dialysis Centre',
    'centre_address': 'Kukatpally (sample address)',
    'details_visible': visible,
    // Deliberately stale details when hidden: the presentation must honour the flag.
    'patient_name': 'Ravi Mehta',
    'home_address': '12 Lake View Road, Kukatpally',
    'mobility_notes': 'Uses a walking stick',
    'emergency_contacts': [
      {'name': 'Anita Mehta', 'phone': '+919000000101'},
    ],
    'start_allowed_at': startAllowedAt?.toIso8601String(),
  };

  Future<Object?> call(String function, Map<String, Object?> params) async {
    calls.add((function, {...params}));
    if (function == 'companion_my_trips') {
      if (readError != null) throw readError!;
      if (delayedRead != null) return delayedRead!;
      return missing ? <Object?>[] : rows ?? [row];
    }
    if (writeError != null) throw writeError!;
    if (function == 'verify_pickup_otp') {
      if (otp['ok'] == true) status = TripStatus.pickedUp;
      return otp;
    }
    if (function == 'advance_trip') {
      final next = TripStatus.fromDb(params['p_to_status']! as String);
      if (!TripStateMachine.instance.canAdvance(status, next, TransitionActor.companion)) {
        throw const RpcException('22023', 'synthetic transition denied');
      }
      status = next;
      return {
        'id': 'synthetic-trip',
        'patient_id': 'synthetic-patient',
        'status': status.dbValue,
        'scheduled_pickup_at': _pickup.toIso8601String(),
        'scheduled_return_at': _pickup.add(const Duration(hours: 5)).toIso8601String(),
      };
    }
    throw StateError('Forbidden RPC: $function');
  }

  List<(String, Map<String, Object?>)> get writes => calls.where((c) => c.$1 != 'companion_my_trips').toList();
}

Finder _key(String value) => find.byKey(Key(value));

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key));
  await tester.pumpAndSettle();
  await tester.tap(_key(key));
  await tester.pumpAndSettle();
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  Brightness brightness = Brightness.light,
  double scale = 1,
  bool settle = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(360, 780);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        family_l10n.AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: companionTheme(brightness),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: child,
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

Future<void> _trip(
  WidgetTester tester,
  _Backend backend, {
  Locale locale = const Locale('en'),
  Brightness brightness = Brightness.light,
  double scale = 1,
}) => _pump(
  tester,
  CompanionTripScreen(api: backend.api, trip: CompanionTrip.fromJson(backend.row), clock: () => _now),
  locale: locale,
  brightness: brightness,
  scale: scale,
);

Future<void> _home(WidgetTester tester, _Backend backend, {bool settle = true}) => _pump(
  tester,
  CompanionHomeScreen(api: backend.api, onLocaleChanged: (_) {}, onSignOut: () async {}, clock: () => _now),
  settle: settle,
);

void main() {
  setUp(() => companionNetworkOnline.value = true);
  tearDown(() => companionNetworkOnline.value = true);

  test('web navigation uses an encoded HTTPS directions URL on every browser platform', () {
    const destination = '17.4,78.4';
    for (final platform in [TargetPlatform.windows, TargetPlatform.android, TargetPlatform.iOS]) {
      final uri = companionMapUri(destination, isWeb: true, platform: platform);
      expect(uri.scheme, 'https');
      expect(uri.host, 'www.google.com');
      expect(uri.path, '/maps/dir/');
      expect(uri.queryParameters, {'api': '1', 'destination': destination});
    }
    final address = companionMapUri('Lake View & Main Road, హైదరాబాద్', isWeb: true, platform: TargetPlatform.windows);
    expect(address.queryParameters['destination'], 'Lake View & Main Road, హైదరాబాద్');
  });

  test('native Android and iOS retain their map app links', () {
    final android = companionMapUri('17.4,78.4', isWeb: false, platform: TargetPlatform.android);
    final ios = companionMapUri('17.4,78.4', isWeb: false, platform: TargetPlatform.iOS);
    expect(android.scheme, 'geo');
    expect(ios.scheme, 'maps');
    expect(android.queryParameters['q'], '17.4,78.4');
    expect(ios.queryParameters['q'], '17.4,78.4');
  });

  testWidgets('hidden stale home coordinates do not enable navigation', (tester) async {
    final backend = _Backend(TripStatus.scheduled)..visible = false;
    final trip = CompanionTrip.fromJson({...backend.row, 'home_lat': 17.4, 'home_lng': 78.4});
    await _pump(tester, CompanionTripScreen(api: backend.api, trip: trip, clock: () => _now));
    expect(tester.widget<OutlinedButton>(_key('navigate')).onPressed, isNull);
    expect(backend.writes, isEmpty);
  });

  testWidgets('visit cards expose their persisted ID for browser journeys', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await _home(tester, _Backend(TripStatus.scheduled));
      expect(find.bySemanticsIdentifier('companion-trip-synthetic-trip'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('C14 shows the next assigned pickup only when supplied', (tester) async {
    final backend = _Backend(TripStatus.completed);
    await _trip(tester, backend);
    expect(find.text('Next visit'), findsNothing);
    final next = _pickup.add(const Duration(days: 1));
    await _pump(
      tester,
      CompanionTripScreen(api: backend.api, trip: CompanionTrip.fromJson(backend.row), nextPickupAt: next),
    );
    expect(find.text('Next visit'), findsOneWidget);
    expect(find.text(companionDate(next, tester.element(find.byType(CompanionTripScreen)))), findsOneWidget);
  });

  testWidgets('C5 shows first names and essentials without surnames or contact numbers', (tester) async {
    await _trip(tester, _Backend(TripStatus.scheduled));
    expect(find.text('Ravi'), findsOneWidget);
    expect(find.text('Anita'), findsOneWidget);
    expect(find.textContaining('Mehta'), findsNothing);
    expect(find.textContaining('+919000000101'), findsNothing);
    expect(find.text('12 Lake View Road, Kukatpally'), findsOneWidget);
    expect(find.textContaining('Uses a walking stick'), findsOneWidget);
    for (final forbidden in ['Records', 'Billing', 'Diagnosis', 'Verified', 'ETA']) {
      expect(find.text(forbidden), findsNothing);
    }
  });

  testWidgets('C5 hides stale patient and family data outside the access window', (tester) async {
    final backend = _Backend(TripStatus.scheduled)..visible = false;
    await _trip(tester, backend);
    for (final text in ['Ravi', 'Anita', '12 Lake View Road, Kukatpally']) {
      expect(find.text(text), findsNothing);
    }
    expect(find.textContaining('walking stick'), findsNothing);
    expect(tester.widget<OutlinedButton>(_key('navigate')).onPressed, isNull);
  });

  final actionByStatus = <TripStatus, String>{
    TripStatus.scheduled: 'start-journey',
    TripStatus.companionEnRoute: 'open-pickup',
    TripStatus.pickedUp: 'arrive-centre',
    TripStatus.atCentre: 'open-handover',
    TripStatus.handedOver: 'session-finished',
    TripStatus.sessionDone: 'start-return',
    TripStatus.returning: 'arrive-home',
    TripStatus.droppedHome: 'add-visit-note',
  };
  for (final entry in actionByStatus.entries) {
    testWidgets('C5–C13 ${entry.key.dbValue} exposes its next step and eight-stage progress', (tester) async {
      await _trip(tester, _Backend(entry.key));
      for (final key in actionByStatus.values) {
        expect(_key(key), key == entry.value ? findsOneWidget : findsNothing);
      }
      final progress = tester.widget<Row>(_key('visit-progress'));
      expect(progress.children, hasLength(8));
      expect(_key('report-issue'), entry.key == TripStatus.scheduled ? findsNothing : findsOneWidget);
    });
  }

  for (final status in [TripStatus.completed, TripStatus.cancelled, TripStatus.noShow, TripStatus.issueReported]) {
    testWidgets('C14 or exception ${status.dbValue} cannot advance a visit', (tester) async {
      final backend = _Backend(status);
      await _trip(tester, backend);
      for (final key in actionByStatus.values) {
        expect(_key(key), findsNothing);
      }
      expect(_key('report-issue'), findsNothing);
      expect(backend.writes, isEmpty);
    });
  }

  testWidgets('C5 uses the returned start window and makes no premature write', (tester) async {
    final backend = _Backend(TripStatus.scheduled)..startAllowedAt = _now.add(const Duration(minutes: 20));
    await _trip(tester, backend);
    expect(tester.widget<FilledButton>(_key('start-journey')).onPressed, isNull);
    expect(backend.writes, isEmpty);
    await tester.pumpWidget(const SizedBox()); // Dispose the future start timer.
  });

  testWidgets('C5 future start message includes the opening date, not only a clock time', (tester) async {
    final backend = _Backend(TripStatus.scheduled)..startAllowedAt = _now.add(const Duration(days: 1));
    await _trip(tester, backend);
    expect(find.textContaining('You can start from Fri, Nov 13, 2026'), findsOneWidget);
    expect(tester.widget<FilledButton>(_key('start-journey')).onPressed, isNull);
    expect(backend.writes, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Navigate prefers authorized home coordinates over an unresolvable sample address', (tester) async {
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    Uri? destination;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      destination = Uri.parse((call.arguments as Map<Object?, Object?>)['url']! as String);
      return true;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));
    final backend = _Backend(TripStatus.scheduled);
    final trip = CompanionTrip.fromJson({...backend.row, 'home_lat': 17.4, 'home_lng': 78.4});
    await _pump(tester, CompanionTripScreen(api: backend.api, trip: trip, clock: () => _now));
    await _tap(tester, 'navigate');
    expect(destination!.queryParameters['q'], '17.4,78.4');
  });

  testWidgets('C7 validates six digits, handles server attempts and locks at zero', (tester) async {
    final backend = _Backend(TripStatus.companionEnRoute)
      ..otp = {'ok': false, 'reason': 'wrong_code', 'attempts_left': 3};
    await _trip(tester, backend);
    await _tap(tester, 'open-pickup');
    expect(tester.widget<TextField>(_key('pickup-code')).controller!.text, isEmpty);
    await tester.enterText(_key('pickup-code'), '12');
    await _tap(tester, 'verify-pickup');
    expect(backend.writes, isEmpty);
    await tester.enterText(_key('pickup-code'), '123456');
    await _tap(tester, 'verify-pickup');
    expect(find.textContaining('3'), findsWidgets);
    expect(backend.status, TripStatus.companionEnRoute);
    backend.otp = {'ok': false, 'reason': 'wrong_code', 'attempts_left': 0};
    await tester.enterText(_key('pickup-code'), '111111');
    await _tap(tester, 'verify-pickup');
    expect(tester.widget<FilledButton>(_key('verify-pickup')).onPressed, isNull);
    expect(tester.widget<TextField>(_key('pickup-code')).controller!.text, isEmpty);
    expect(backend.writes.map((c) => c.$1), everyElement('verify_pickup_otp'));
  });

  testWidgets('C7 describes unavailable codes without inventing expiry versus lockout', (tester) async {
    final backend = _Backend(TripStatus.companionEnRoute)
      ..otp = {'ok': false, 'reason': 'no_valid_code', 'attempts_left': 0};
    await _trip(tester, backend);
    await _tap(tester, 'open-pickup');
    await tester.enterText(_key('pickup-code'), '123456');
    await _tap(tester, 'verify-pickup');
    final l = AppLocalizations.of(tester.element(_key('pickup-code')));
    expect(find.text(l.cCodeUnavailable), findsOneWidget);
    expect(backend.status, TripStatus.companionEnRoute);
  });

  testWidgets('C9 staff receipt gates handover and retains note on action failure', (tester) async {
    final backend = _Backend(TripStatus.atCentre)..writeError = StateError('synthetic connection failure');
    await _trip(tester, backend);
    await _tap(tester, 'open-handover');
    expect(tester.widget<FilledButton>(_key('confirm-handover')).onPressed, isNull);
    await tester.enterText(_key('handover-note'), 'Belongings left with staff.');
    await _tap(tester, 'staff-received');
    await _tap(tester, 'confirm-handover');
    expect(tester.widget<TextField>(_key('handover-note')).controller!.text, 'Belongings left with staff.');
    expect(find.text('Ravi'), findsOneWidget);
    backend.writeError = null;
    await _tap(tester, 'confirm-handover');
    expect(backend.status, TripStatus.handedOver);
    expect(backend.writes.last.$2['p_note'], 'Belongings left with staff.');
  });

  testWidgets('C12–C14 completion requires a note and retains its draft on failure', (tester) async {
    final backend = _Backend(TripStatus.droppedHome)..writeError = StateError('synthetic transport failure');
    await _trip(tester, backend);
    await _tap(tester, 'add-visit-note');
    expect(tester.widget<TextField>(_key('visit-note')).controller!.text, isEmpty);
    await _tap(tester, 'complete-visit');
    expect(backend.writes, isEmpty);
    await tester.enterText(_key('visit-note'), 'Ravi reached home comfortably.');
    await _tap(tester, 'complete-visit');
    expect(tester.widget<TextField>(_key('visit-note')).controller!.text, 'Ravi reached home comfortably.');
    backend.writeError = null;
    await _tap(tester, 'complete-visit');
    expect(backend.status, TripStatus.completed);
    expect(backend.writes.last.$2['p_note'], contains('Ravi reached home comfortably.'));
  });

  testWidgets('every persisted journey step remains distinct including session done and home', (tester) async {
    final backend = _Backend(TripStatus.scheduled);
    await _trip(tester, backend);
    await _tap(tester, 'start-journey');
    expect(backend.status, TripStatus.companionEnRoute);
    await _tap(tester, 'open-pickup');
    await tester.enterText(_key('pickup-code'), '123456');
    await _tap(tester, 'verify-pickup');
    expect(backend.status, TripStatus.pickedUp);
    await _tap(tester, 'arrive-centre');
    await _tap(tester, 'open-handover');
    await _tap(tester, 'staff-received');
    await _tap(tester, 'confirm-handover');
    await _tap(tester, 'session-finished');
    expect(backend.status, TripStatus.sessionDone);
    await _tap(tester, 'start-return');
    expect(backend.status, TripStatus.returning);
    await _tap(tester, 'arrive-home');
    expect(backend.status, TripStatus.droppedHome);
    await _tap(tester, 'add-visit-note');
    await tester.enterText(_key('visit-note'), 'Visit completed safely.');
    await _tap(tester, 'complete-visit');
    expect(backend.status, TripStatus.completed);
    expect(backend.writes.map((c) => c.$1), [
      'advance_trip',
      'verify_pickup_otp',
      'advance_trip',
      'advance_trip',
      'advance_trip',
      'advance_trip',
      'advance_trip',
      'advance_trip',
    ]);
  });

  testWidgets('Navigate hands off the current destination as trip state changes without reopening', (tester) async {
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    final destinations = <Uri>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      final args = call.arguments as Map<Object?, Object?>;
      destinations.add(Uri.parse(args['url']! as String));
      expect(args['useWebView'], isFalse, reason: 'No in-app map or web view');
      return true;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));
    final backend = _Backend(TripStatus.scheduled);
    await _trip(tester, backend);
    await _tap(tester, 'navigate');
    expect(destinations.last.scheme, 'geo');
    expect(destinations.last.queryParameters['q'], '12 Lake View Road, Kukatpally');
    await _tap(tester, 'start-journey');
    await _tap(tester, 'open-pickup');
    await tester.enterText(_key('pickup-code'), '123456');
    await _tap(tester, 'verify-pickup');
    await _tap(tester, 'navigate');
    expect(destinations.last.queryParameters['q'], 'Kukatpally (sample address)');
    await _tap(tester, 'arrive-centre');
    await _tap(tester, 'open-handover');
    await _tap(tester, 'staff-received');
    await _tap(tester, 'confirm-handover');
    await _tap(tester, 'session-finished');
    await _tap(tester, 'start-return');
    await _tap(tester, 'navigate');
    expect(destinations.last.queryParameters['q'], '12 Lake View Road, Kukatpally');
    expect(destinations, hasLength(3));
  });

  testWidgets('C15 requires issue details and persists only the existing operational note', (tester) async {
    final backend = _Backend(TripStatus.companionEnRoute);
    await _trip(tester, backend);
    await _tap(tester, 'report-issue');
    await _tap(tester, 'send-issue');
    expect(backend.writes, isEmpty);
    await tester.enterText(_key('issue-note'), 'Cannot find the entrance.');
    await _tap(tester, 'send-issue');
    expect(backend.status, TripStatus.issueReported);
    expect(backend.writes.single.$2['p_note'], 'Cannot find the entrance.');
    expect(_key('report-issue'), findsNothing);
  });

  testWidgets('C15 keeps typed issue details when report fails and retry uses the same note', (tester) async {
    final backend = _Backend(TripStatus.pickedUp)..writeError = StateError('synthetic transport failure');
    await _trip(tester, backend);
    await _tap(tester, 'report-issue');
    await tester.enterText(_key('issue-note'), 'Centre entrance temporarily closed.');
    await _tap(tester, 'send-issue');
    expect(tester.widget<TextField>(_key('issue-note')).controller!.text, 'Centre entrance temporarily closed.');
    expect(backend.status, TripStatus.pickedUp);
    backend.writeError = null;
    await _tap(tester, 'send-issue');
    expect(backend.status, TripStatus.issueReported);
    expect(backend.writes.last.$2['p_note'], 'Centre entrance temporarily closed.');
  });

  testWidgets('C16 requires explicit confirmation before marking no-show', (tester) async {
    final backend = _Backend(TripStatus.companionEnRoute);
    await _trip(tester, backend);
    await _tap(tester, 'patient-unavailable');
    expect(backend.writes, isEmpty);
    await _tap(tester, 'confirm-no-show');
    expect(backend.status, TripStatus.noShow);
    expect(find.text('Ravi'), findsNothing, reason: 'No-show ends access to patient details');
  });

  testWidgets('a denied issue submission closes and clears the private issue draft', (tester) async {
    final backend = _Backend(TripStatus.pickedUp)..writeError = const RpcException('42501', 'synthetic access revoked');
    await _trip(tester, backend);
    await _tap(tester, 'report-issue');
    await tester.enterText(_key('issue-note'), 'Private operational context.');
    await _tap(tester, 'send-issue');
    expect(find.text('Ravi'), findsNothing);
    expect(_key('issue-note'), findsNothing);
    expect(find.text('Private operational context.'), findsNothing);
    expect(_key('visit-refresh'), findsOneWidget, reason: 'The denied sheet must not pop the visit underneath');
    expect(find.text('You cannot open this visit.'), findsOneWidget);
  });

  for (final revoked in ['hidden', 'missing', 'denied']) {
    testWidgets('lifecycle refresh $revoked closes an open private issue draft', (tester) async {
      final backend = _Backend(TripStatus.pickedUp);
      await _trip(tester, backend);
      await _tap(tester, 'report-issue');
      await tester.enterText(_key('issue-note'), 'Private operational context.');
      if (revoked == 'hidden') backend.visible = false;
      if (revoked == 'missing') backend.missing = true;
      if (revoked == 'denied') backend.readError = const RpcException('42501', 'synthetic revoked');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(_key('issue-note'), findsNothing);
      expect(find.text('Private operational context.'), findsNothing);
      expect(find.text('Ravi'), findsNothing);
      backend.visible = true;
      backend.missing = false;
      backend.readError = null;
      await _tap(tester, 'visit-refresh');
      await _tap(tester, 'report-issue');
      expect(tester.widget<TextField>(_key('issue-note')).controller!.text, isEmpty);
    });
  }

  for (final pickup in [true, false]) {
    testWidgets('${pickup ? 'pickup' : 'handover'} form opens from the top of the task', (tester) async {
      await _trip(tester, _Backend(pickup ? TripStatus.companionEnRoute : TripStatus.atCentre));
      await _tap(tester, pickup ? 'open-pickup' : 'open-handover');
      expect(find.text('Ravi').hitTestable(), findsOneWidget);
      expect(_key('visit-progress').hitTestable(), findsOneWidget);
    });
  }

  for (final notePage in [true, false]) {
    testWidgets('refresh hiding patient details clears ${notePage ? 'visit' : 'handover'} draft', (tester) async {
      final backend = _Backend(notePage ? TripStatus.droppedHome : TripStatus.atCentre);
      await _trip(tester, backend);
      final open = notePage ? 'add-visit-note' : 'open-handover';
      final field = notePage ? 'visit-note' : 'handover-note';
      await _tap(tester, open);
      await tester.enterText(_key(field), 'Private patient draft.');
      backend.visible = false;
      await _tap(tester, 'visit-refresh');
      expect(find.text('Ravi'), findsNothing);
      expect(_key(field), findsNothing);
      backend.visible = true;
      await _tap(tester, 'visit-refresh');
      await _tap(tester, open);
      expect(tester.widget<TextField>(_key(field)).controller!.text, isEmpty);
    });
  }

  testWidgets('refresh hides details while loading and clears access after reassignment', (tester) async {
    final backend = _Backend(TripStatus.scheduled);
    await _trip(tester, backend);
    final delayed = Completer<Object?>();
    backend.delayedRead = delayed.future;
    await tester.tap(_key('visit-refresh'));
    await tester.pump();
    expect(find.text('Ravi'), findsNothing);
    expect(_key('start-journey'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    delayed.complete(<Object?>[]);
    await tester.pumpAndSettle();
    expect(find.text('Ravi'), findsNothing);
    expect(_key('visit-progress'), findsNothing);
    expect(find.textContaining('cannot open'), findsOneWidget);
  });

  testWidgets('a denied action immediately removes authorized details and drafts', (tester) async {
    final backend = _Backend(TripStatus.droppedHome)..writeError = const RpcException('42501', 'synthetic denied');
    await _trip(tester, backend);
    await _tap(tester, 'add-visit-note');
    await tester.enterText(_key('visit-note'), 'Private draft.');
    await _tap(tester, 'complete-visit');
    expect(find.text('Ravi'), findsNothing);
    expect(_key('visit-note'), findsNothing);
    expect(_key('visit-progress'), findsNothing);
  });

  testWidgets('offline trip disables mutations and offers no queued writes', (tester) async {
    final backend = _Backend(TripStatus.scheduled);
    await _trip(tester, backend);
    companionNetworkOnline.value = false;
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(_key('start-journey')).onPressed, isNull);
    expect(find.textContaining('No internet'), findsOneWidget);
    expect(backend.writes, isEmpty);
  });

  testWidgets('C3 Today empty and loading/error retry use the existing restricted read', (tester) async {
    final backend = _Backend(TripStatus.scheduled)..readError = StateError('synthetic offline');
    await _home(tester, backend);
    expect(find.text('Try again'), findsOneWidget);
    backend.readError = null;
    backend.missing = true;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No visit'), findsWidgets);
    expect(backend.calls.map((c) => c.$1), everyElement('companion_my_trips'));
  });

  testWidgets('C3 loading waits for the actual assignment read without synthetic visits', (tester) async {
    final result = Completer<Object?>();
    final backend = _Backend(TripStatus.scheduled)..delayedRead = result.future;
    await _home(tester, backend, settle: false);
    await tester.pump();
    expect(_key('trips-loading'), findsOneWidget);
    expect(find.text('Ravi'), findsNothing);
    result.complete(<Object?>[]);
    await tester.pumpAndSettle();
    expect(_key('trips-loading'), findsNothing);
  });

  testWidgets('C4 groups upcoming visits by date and labels Drop and Return on the same visit', (tester) async {
    final backend = _Backend(TripStatus.scheduled);
    final tomorrow = _pickup.add(const Duration(days: 1));
    backend.rows = [
      {
        ...backend.row,
        'scheduled_pickup_at': tomorrow.toIso8601String(),
        'scheduled_return_at': tomorrow.add(const Duration(hours: 5)).toIso8601String(),
      },
    ];
    await _home(tester, backend);
    final l = AppLocalizations.of(tester.element(find.byType(CompanionHomeScreen)));
    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pumpAndSettle();
    expect(_key('trip-synthetic-trip'), findsOneWidget);
    final context = tester.element(find.byType(CompanionHomeScreen));
    expect(find.text(l.cDrop(companionTime(tomorrow, context))), findsOneWidget);
    expect(find.text(l.cReturn(companionTime(tomorrow.add(const Duration(hours: 5)), context))), findsOneWidget);
    expect(find.text('Ravi'), findsOneWidget);
    expect(find.textContaining('Mehta'), findsNothing);
    expect(backend.writes, isEmpty);
  });

  testWidgets('C17 shows both emergency numbers and honest non-clinical guidance', (tester) async {
    await _pump(tester, const CompanionHelpScreen());
    final l = AppLocalizations.of(tester.element(find.byType(CompanionHelpScreen)));
    expect(find.text(l.cCall112), findsOneWidget);
    expect(find.text(l.cCall108), findsOneWidget);
    expect(find.text(l.cEmergency), findsOneWidget);
    await tester.scrollUntilVisible(find.text(l.cNonClinical), 200);
    expect(find.text(l.cNonClinical), findsOneWidget);
    expect(find.textContaining('Verified'), findsNothing);
  });

  testWidgets('C18 Me offers language and help, and sign out needs confirmation', (tester) async {
    var signOuts = 0;
    final backend = _Backend(TripStatus.scheduled);
    await _pump(
      tester,
      CompanionHomeScreen(
        api: backend.api,
        onLocaleChanged: (_) {},
        onSignOut: () async => signOuts++,
        clock: () => _now,
      ),
    );
    final l = AppLocalizations.of(tester.element(find.byType(CompanionHomeScreen)));
    await tester.tap(find.byType(NavigationDestination).at(2));
    await tester.pumpAndSettle();
    expect(find.text(l.cHelp), findsOneWidget);
    expect(find.text('Suresh Kumar'), findsNothing, reason: 'No profile contract; never invent a greeting identity');
    await _tap(tester, 'companion-sign-out');
    expect(signOuts, 0);
    await tester.tap(find.widgetWithText(FilledButton, l.signOut));
    await tester.pumpAndSettle();
    expect(signOuts, 1);
  });

  for (final locale in const [Locale('en'), Locale('te'), Locale('hi')]) {
    for (final brightness in Brightness.values) {
      testWidgets('all journey states fit 360px at 200% ${locale.languageCode} ${brightness.name}', (tester) async {
        for (final status in TripStatus.values) {
          await tester.pumpWidget(const SizedBox());
          await _trip(tester, _Backend(status), locale: locale, brightness: brightness, scale: 2);
          expect(tester.takeException(), isNull, reason: status.dbValue);
        }
      });
      testWidgets('C3 C4 C17 C18 fit 360px at 200% ${locale.languageCode} ${brightness.name}', (tester) async {
        final backend = _Backend(TripStatus.scheduled);
        await _pump(
          tester,
          CompanionHomeScreen(api: backend.api, onLocaleChanged: (_) {}, onSignOut: () async {}, clock: () => _now),
          locale: locale,
          brightness: brightness,
          scale: 2,
        );
        for (final tab in [0, 1, 2]) {
          await tester.tap(find.byType(NavigationDestination).at(tab));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'Home tab $tab');
        }
        await tester.pumpWidget(const SizedBox());
        await _pump(tester, const CompanionHelpScreen(), locale: locale, brightness: brightness, scale: 2);
        expect(tester.takeException(), isNull, reason: 'Help screen');
      });
      testWidgets('C7 C9 C13 C15 C16 forms remain reachable at 200% ${locale.languageCode} ${brightness.name}', (
        tester,
      ) async {
        await _trip(tester, _Backend(TripStatus.companionEnRoute), locale: locale, brightness: brightness, scale: 2);
        await _tap(tester, 'open-pickup');
        await tester.ensureVisible(_key('pickup-code'));
        await tester.enterText(_key('pickup-code'), '123456');
        await tester.ensureVisible(_key('verify-pickup'));
        expect(_key('verify-pickup').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'Pickup');
        await _tap(tester, 'patient-unavailable');
        await tester.ensureVisible(_key('confirm-no-show'));
        expect(_key('confirm-no-show').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'No-show sheet');
        await tester.pumpWidget(const SizedBox());

        await _trip(tester, _Backend(TripStatus.atCentre), locale: locale, brightness: brightness, scale: 2);
        await _tap(tester, 'open-handover');
        await _tap(tester, 'staff-received');
        await tester.ensureVisible(_key('handover-note'));
        await tester.enterText(_key('handover-note'), 'Belongings handed to staff.');
        await tester.ensureVisible(_key('confirm-handover'));
        expect(_key('confirm-handover').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'Handover');
        await tester.pumpWidget(const SizedBox());

        await _trip(tester, _Backend(TripStatus.droppedHome), locale: locale, brightness: brightness, scale: 2);
        await _tap(tester, 'add-visit-note');
        await tester.ensureVisible(_key('visit-note'));
        await tester.enterText(_key('visit-note'), 'Patient reached home safely.');
        await tester.ensureVisible(_key('complete-visit'));
        expect(_key('complete-visit').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'Visit note');
        await tester.pumpWidget(const SizedBox());

        await _trip(tester, _Backend(TripStatus.companionEnRoute), locale: locale, brightness: brightness, scale: 2);
        await _tap(tester, 'report-issue');
        await tester.ensureVisible(_key('issue-note'));
        await tester.enterText(_key('issue-note'), 'Entrance temporarily closed.');
        await tester.ensureVisible(_key('send-issue'));
        expect(_key('send-issue').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'Issue sheet');
      });
    }
  }
}
