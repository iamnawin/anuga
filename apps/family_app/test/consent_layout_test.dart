import 'package:family_app/l10n/generated/app_localizations.dart';
import 'package:family_app/src/app.dart';
import 'package:family_app/src/screens/consent_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fake_backend.dart';

void main() {
  for (final width in [360.0, 390.0]) {
    for (final brightness in Brightness.values) {
      for (final code in ['en', 'te', 'hi']) {
        for (final scale in [1.0, 2.0]) {
          testWidgets('$width ${brightness.name} $code ${scale}x consent wraps and Save stays reachable', (
            tester,
          ) async {
            tester.view.physicalSize = Size(width, 844);
            tester.view.devicePixelRatio = 1;
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(tester.view.reset);
            addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
            final backend = FakeFamilyBackend()..consentState[ConsentPurpose.vault] = false;
            final patient = (await backend.api.myPatients()).single;
            await tester.pumpWidget(
              MaterialApp(
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
                home: ConsentScreen(api: backend.api, patient: patient),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            final save = find.byKey(const Key('save-consents'));
            await tester.ensureVisible(save);
            await tester.pumpAndSettle();
            expect(save.hitTestable(), findsOneWidget);
            expect(tester.takeException(), isNull);
            expect(backend.calls, isNot(contains('set_consent')));
          });
        }
      }
    }
  }
}
