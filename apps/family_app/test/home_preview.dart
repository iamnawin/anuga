// Local visual fixture only. Build explicitly with --target=test/home_preview.dart.
// Production main.dart never imports this entry point or the synthetic backend.
import 'dart:async';

import 'package:family_app/l10n/generated/app_localizations.dart';
import 'package:family_app/src/app.dart';
import 'package:family_app/src/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fake_backend.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final query = Uri.base.queryParameters;
  final scenario = query['state'] ?? 'populated';
  final backend = FakeFamilyBackend(level: AccessLevel.fromDb(query['level'] ?? 'owner'));
  backend.patients['p1'] = 'Lakshmi Rao (synthetic)';
  if (scenario == 'empty') backend.patients.clear();
  if (scenario == 'populated' || scenario == 'multi' || scenario == 'revoked') {
    backend.addVisit(FakeVisit(id: 'upcoming', pickupAt: DateTime.now().toUtc().add(const Duration(days: 1))));
  }
  if (scenario == 'multi') {
    backend.patients['p2'] = 'Synthetic second patient';
    backend.addVisit(FakeVisit(id: 'second', patientId: 'p2', pickupAt: DateTime.now().toUtc()));
  }
  var patientLoads = 0;
  final api = FamilyApi((fn, args) async {
    if (fn == 'family_my_patients') {
      patientLoads++;
      if (scenario == 'loading') return Completer<Object?>().future;
      if (scenario == 'patients-error' && patientLoads == 1) throw Exception('synthetic offline fixture');
      if (scenario == 'patients-denied') throw const RpcException('42501', 'synthetic denied fixture');
      if (scenario == 'revoked' && patientLoads > 1) return <Object?>[];
    }
    if (fn == 'family_trip_board') {
      if (scenario == 'bookings-loading') return Completer<Object?>().future;
      if (scenario == 'bookings-denied') throw const RpcException('42501', 'synthetic denied fixture');
      if (scenario == 'bookings-error') throw Exception('synthetic offline fixture');
    }
    return backend.rpc(fn, args);
  });
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(query['locale'] ?? 'en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: familyTheme(query['dark'] == 'true' ? Brightness.dark : Brightness.light),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(double.parse(query['scale'] ?? '1.15'))),
        child: child!,
      ),
      home: Banner(
        message: 'UI fixture',
        location: BannerLocation.topStart,
        child: HomeScreen(
          api: api,
          files: FakeVaultFiles(backend),
          photos: FakePhotoSource(),
          payments: FakePayments(backend),
          onLocaleChanged: (_) {},
          onSignOut: () async {},
        ),
      ),
    ),
  );
}
