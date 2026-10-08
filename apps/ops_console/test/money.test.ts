import { formatRupees, monthStart, parseRupees } from '@/lib/money';

describe('money', () => {
  test.each([
    ['180', 18000], ['180.5', 18050], ['180.50', 18050], ['1,250.75', 125075], ['₹ 99', 9900], ['0', 0],
  ])('parses %s rupees as %i paise', (input, paise) => {
    expect(parseRupees(input)).toBe(paise);
  });

  test.each(['', 'abc', '-5', '1.234', '12.3.4'])('rejects %s', (input) => {
    expect(parseRupees(input)).toBeNull();
  });

  test('formats paise as rupees with Indian grouping', () => {
    expect(formatRupees(12345600)).toBe('₹1,23,456.00');
  });

  test('month start', () => {
    expect(monthStart('2026-09')).toBe('2026-09-01');
    expect(() => monthStart('Sept')).toThrow();
  });
});
