import 'dart:ui' show SemanticsRole;

import 'package:anugacare_app/src/app.dart';
import 'package:family_app/family_app.dart' show Payments, PhotoSource, PickedPhoto, VaultFiles;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fakes.dart';

class _Files implements VaultFiles {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Photos implements PhotoSource {
  @override
  Future<PickedPhoto?> pick({required bool camera}) async => null;
}

class _Payments implements Payments {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  for (final level in AccessLevel.values) {
    testWidgets('unified Family shell follows ${level.dbValue} access without billing prefetch', (tester) async {
      usePhoneScreen(tester);
      final semantics = tester.ensureSemantics();
      final auth = FakeAccountAuth()..roles[familyPhone] = 'family';
      await auth.sendCode(familyPhone);
      await auth.verifyCode(familyPhone, '123456');
      final calls = <String>[];
      final api = FamilyApi((fn, params) async {
        calls.add(fn);
        return switch (fn) {
          'family_my_patients' => [
            {
              'patient_id': 'ravi',
              'full_name': 'Ravi Rao',
              'access_level': level.dbValue,
              'centre_name': 'City Dialysis Centre',
            },
          ],
          'family_trip_board' || 'family_care_requests' || 'my_notifications' => <Object?>[],
          _ => throw StateError('Unexpected initial read: $fn'),
        };
      });
      await tester.pumpWidget(
        AnugaCareApp(
          auth: auth,
          familyApi: api,
          companionApi: CompanionApi((fn, params) async => throw StateError('Companion read from Family')),
          files: _Files(),
          photos: _Photos(),
          payments: _Payments(),
        ),
      );
      await tester.pumpAndSettle();
      final nav = find.byType(NavigationBar);
      expect(nav, findsOneWidget);
      expect(tester.getSemantics(find.byKey(const Key('nav-visits'))).getSemanticsData().role, SemanticsRole.tab);
      expect(find.descendant(of: nav, matching: find.text('Home')), findsOneWidget);
      expect(find.descendant(of: nav, matching: find.text('Visits')), findsOneWidget);
      expect(
        find.descendant(of: nav, matching: find.text('Bills')),
        level == AccessLevel.owner ? findsOneWidget : findsNothing,
      );
      expect(
        find.descendant(of: nav, matching: find.text('More')),
        level == AccessLevel.patient ? findsNothing : findsOneWidget,
      );
      expect(
        find.descendant(of: nav, matching: find.text('Help')),
        level == AccessLevel.patient ? findsOneWidget : findsNothing,
      );
      expect(calls, isNot(contains('family_invoices')));
      expect(calls, isNot(contains('vault_list_documents')));
      expect(tester.takeException(), isNull);

      // Session loss still clears the signed-in screen through the existing root.
      await auth.signOut();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('expired')), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Ravi Rao'), findsNothing);
      semantics.dispose();
    });
  }
}
