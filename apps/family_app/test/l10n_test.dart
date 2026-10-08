import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> arb(String lang) =>
    jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync()) as Map<String, dynamic>;

Set<String> messages(Map<String, dynamic> file) => file.keys.where((k) => !k.startsWith('@')).toSet();

List<String> placeholders(String text) =>
    RegExp(r'\{(\w+)\}').allMatches(text).map((m) => m.group(1)!).toList()..sort();

void main() {
  test('Telugu and Hindi translate every English message with the same placeholders', () {
    final en = arb('en');
    for (final lang in ['te', 'hi']) {
      final other = arb(lang);
      expect(messages(other), messages(en), reason: lang);
      for (final key in messages(en)) {
        final text = other[key] as String;
        expect(text.trim(), isNotEmpty, reason: '$lang $key');
        expect(placeholders(text), placeholders(en[key] as String), reason: '$lang $key');
        if (key != '@@locale' && text.contains(RegExp('[a-zA-Z]{4,}')) && !key.startsWith('@')) {
          // Latin words are allowed only for proper nouns and numbers like "108".
          expect(text, isNot(en[key]), reason: '$lang $key is untranslated');
        }
      }
    }
  });
}
