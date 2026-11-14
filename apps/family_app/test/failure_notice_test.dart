import 'dart:typed_data';

import 'package:family_app/l10n/generated/app_localizations.dart';
import 'package:family_app/src/app.dart';
import 'package:family_app/src/labels.dart';
import 'package:family_app/src/screens/family_ui.dart';
import 'package:family_app/src/screens/inbox_tab.dart';
import 'package:family_app/src/supabase_rpc.dart';
import 'package:family_app/src/vault_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_dart/shared_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'support/pump.dart';

const _secret = 'relation patients row 4f1c secret detail';

/// One error per kind, with the code the user should see.
const _cases = <(Object, String)>[
  (NetworkException(), 'NET'),
  (RequestTimeoutException(), 'TIM'),
  (RpcException('PGRST301', _secret), 'SES-PGRST301'),
  (RpcException('42501', _secret), 'DEN-42501'),
  (RpcException('22023', _secret), 'OLD-22023'),
  (RpcException('P0002', _secret), 'NFD-P0002'),
  (RpcException('23505', _secret), 'DUP-23505'),
  (RpcException('P0001', _secret), 'SRV-P0001'),
];

Widget _app(Widget home, {String code = 'en', Brightness brightness = Brightness.light}) => MaterialApp(
  locale: Locale(code),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  theme: familyTheme(brightness),
  builder: largeText,
  home: Scaffold(body: SingleChildScrollView(child: home)),
);

SupabaseClient _client(MockClientHandler handler) => SupabaseClient(
  'http://localhost:54321',
  'public-test-key',
  httpClient: MockClient(handler),
  authOptions: const AuthClientOptions(autoRefreshToken: false),
);

void main() {
  group('describeError', () {
    testWidgets('gives each kind its own sentence', (tester) async {
      await pumpLocalized(tester, const SizedBox());
      final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)));
      final sentences = {for (final (error, _) in _cases) describeError(l10n, error)};
      expect(sentences, hasLength(_cases.length));
      expect(describeError(l10n, const NetworkException()), contains('could not reach AnugaCare'));
      expect(describeError(l10n, const RequestTimeoutException()), contains('taking too long'));
      // Existing wording is unchanged.
      expect(describeError(l10n, const RpcException('42501', _secret)), 'You do not have permission for this.');
      expect(describeError(l10n, StateError('bug')), 'Something went wrong. Try again.');
    });
  });

  group('failure notice', () {
    for (final code in ['en', 'te', 'hi']) {
      for (final brightness in Brightness.values) {
        for (final scale in [1.0, 2.0]) {
          testWidgets('$code ${brightness.name} ${scale}x shows every kind with a code and no internal text', (
            tester,
          ) async {
            tester.view.physicalSize = const Size(360, 780);
            tester.view.devicePixelRatio = 1;
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(tester.view.reset);
            addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
            for (final (error, expected) in _cases) {
              var retried = 0;
              await tester.pumpWidget(
                _app(
                  FamilyFailureNotice(error, onRetry: () => retried++),
                  code: code,
                  brightness: brightness,
                ),
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull, reason: expected);
              expect(find.textContaining(expected), findsOneWidget);
              expect(find.textContaining('secret'), findsNothing);
              expect(find.textContaining('patients'), findsNothing);
              await tapVisible(tester, byKey('family-retry'));
              expect(retried, 1);
            }
          });
        }
      }
    }

    testWidgets('a screen shows the kind and code, not the database message', (tester) async {
      Object error = const NetworkException();
      final api = FamilyApi((fn, params) async => throw error);
      await pumpLocalized(tester, Scaffold(body: InboxTab(api: api)));
      expect(find.textContaining('could not reach AnugaCare'), findsOneWidget);
      expect(find.text('Code: NET'), findsOneWidget);
      error = const RpcException('P0001', _secret);
      await tapVisible(tester, byKey('updates-refresh'));
      expect(find.text('Something went wrong. Try again.'), findsOneWidget);
      expect(find.text('Code: SRV-P0001'), findsOneWidget);
      expect(find.textContaining('secret'), findsNothing);
    });
  });

  group('offline hint', () {
    testWidgets('appears only while the device reports no connection', (tester) async {
      final online = ValueNotifier(true);
      addTearDown(online.dispose);
      await pumpLocalized(tester, Scaffold(body: FamilyOfflineHint(online: online)));
      expect(byKey('family-offline'), findsNothing);
      online.value = false;
      await tester.pumpAndSettle();
      expect(byKey('family-offline'), findsOneWidget);
      expect(find.text('No internet. Your changes will not be saved.'), findsOneWidget);
      online.value = true;
      await tester.pumpAndSettle();
      expect(byKey('family-offline'), findsNothing);
    });
  });

  group('backend adapters', () {
    test('a transport failure becomes NetworkException', () async {
      final client = _client((request) async => throw http.ClientException('connection refused'));
      addTearDown(client.dispose);
      await expectLater(supabaseRpc(client)('family_my_patients', {}), throwsA(isA<NetworkException>()));
    });

    test('a database refusal is still an RpcException with its code', () async {
      final client = _client(
        (request) async => http.Response(
          '{"code":"42501","message":"denied","details":null,"hint":null}',
          403,
          request: request,
          headers: {'content-type': 'application/json'},
        ),
      );
      addTearDown(client.dispose);
      await expectLater(
        supabaseRpc(client)('family_my_patients', {}),
        throwsA(isA<RpcException>().having((e) => e.code, 'code', '42501')),
      );
    });

    test('a successful call is unchanged', () async {
      final client = _client(
        (request) async =>
            http.Response('[{"a":1}]', 200, request: request, headers: {'content-type': 'application/json'}),
      );
      addTearDown(client.dispose);
      expect(await supabaseRpc(client)('family_my_patients', {}), [
        {'a': 1},
      ]);
    });

    test('a failed file upload becomes NetworkException', () async {
      final client = _client((request) async => http.Response('{}', 200));
      addTearDown(client.dispose);
      final files = SupabaseVaultFiles(
        client,
        'http://localhost:54321',
        httpClient: MockClient((request) async => throw http.ClientException('reset')),
      );
      await expectLater(
        files.putFile(Uri.parse('http://localhost:54321/upload'), Uint8List(1), 'image/jpeg'),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
