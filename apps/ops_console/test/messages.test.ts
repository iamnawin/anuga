import { LANGUAGES, messages, translate } from '@/lib/messages';

const placeholders = (s: string) => [...s.matchAll(/\{(\w+)\}/g)].map((m) => m[1]).sort();

describe('messages', () => {
  test('every language has every key, non-empty, with the same placeholders', () => {
    const keys = Object.keys(messages.en);
    for (const lang of LANGUAGES) {
      expect(Object.keys(messages[lang]).sort()).toEqual([...keys].sort());
      for (const key of keys as (keyof typeof messages.en)[]) {
        expect(messages[lang][key].trim(), `${lang} ${key}`).not.toBe('');
        expect(placeholders(messages[lang][key]), `${lang} ${key}`).toEqual(placeholders(messages.en[key]));
      }
    }
  });

  test('Telugu and Hindi are actually translated', () => {
    expect(translate('te', 'nav.trips')).not.toBe(translate('en', 'nav.trips'));
    expect(translate('hi', 'nav.trips')).not.toBe(translate('en', 'nav.trips'));
  });

  test('interpolates variables and leaves unknown placeholders visible', () => {
    expect(translate('en', 'trips.assignBackup', { name: 'Ravi' })).toBe('Assign backup: Ravi');
    expect(translate('en', 'trips.assignBackup')).toBe('Assign backup: {name}');
  });
});
