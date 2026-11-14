import 'dart:ui' as ui;

import 'package:anugacare_app/l10n/generated/app_localizations.dart';
import 'package:anugacare_app/src/screens/welcome_screen.dart';
import 'package:family_app/family_app.dart' show familyTheme;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('${brightness.name} hero edges dissolve to the screen before the headline', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      const capture = Key('hero-capture');
      final theme = familyTheme(brightness);
      await tester.pumpWidget(
        RepaintBoundary(
          key: capture,
          child: MaterialApp(
            theme: theme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: WelcomeScreen(onStart: () {}, onLocaleChanged: (_) {}),
          ),
        ),
      );
      final illustration = find.byKey(const Key('welcome-illustration'));
      final provider = tester.widget<Image>(illustration).image;
      await tester.runAsync(() => precacheImage(provider, tester.element(illustration)));
      await tester.pumpAndSettle();
      final rect = tester.getRect(illustration);
      final headline = tester.getRect(find.text('A familiar face for every visit'));
      expect(headline.top, greaterThan(rect.bottom));
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(capture));
      final image = (await tester.runAsync(() => boundary.toImage(pixelRatio: 1)))!;
      final pixels = (await tester.runAsync(() => image.toByteData(format: ui.ImageByteFormat.rawRgba)))!;
      final background = theme.scaffoldBackgroundColor;
      for (final point in [
        Offset(rect.left + rect.width * .05, rect.top + rect.height * .05),
        Offset(rect.center.dx, rect.bottom - 2),
      ]) {
        final offset = (point.dy.floor() * image.width + point.dx.floor()) * 4;
        expect(
          [pixels.getUint8(offset), pixels.getUint8(offset + 1), pixels.getUint8(offset + 2)],
          [(background.r * 255).round(), (background.g * 255).round(), (background.b * 255).round()],
          reason: 'Hero transparency must reveal the active theme, without an image seam',
        );
      }
      image.dispose();
    });
  }
}
