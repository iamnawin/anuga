import { formatClock, formatKm, istDayStart, istRange, istToday } from '@/lib/format';
import { isOtpCode, normalizeIndianMobile } from '@/lib/phone';

describe('normalizeIndianMobile', () => {
  test.each([
    ['9000000001', '+919000000001'],
    ['+91 90000 00001', '+919000000001'],
    ['919000000001', '+919000000001'],
    ['09000000001', '+919000000001'],
    ['90000-00001', '+919000000001'],
  ])('%s -> %s', (input, expected) => {
    expect(normalizeIndianMobile(input)).toBe(expected);
  });

  test.each(['', '12345', '5000000001', '+1 4152127777', '90000000011'])('rejects %s', (input) => {
    expect(normalizeIndianMobile(input)).toBeNull();
  });

  test('OTP must be exactly six digits', () => {
    expect(isOtpCode('123456')).toBe(true);
    expect(isOtpCode(' 123456 ')).toBe(true);
    expect(isOtpCode('12345')).toBe(false);
    expect(isOtpCode('12a456')).toBe(false);
  });
});

describe('India-time ranges', () => {
  test('a day starts at 00:00 IST = 18:30 UTC the previous day', () => {
    expect(istDayStart('2026-10-08').toISOString()).toBe('2026-10-07T18:30:00.000Z');
  });

  test('a 7-day range ends one millisecond before the 8th day', () => {
    const { from, to } = istRange('2026-10-08', 7);
    expect(from.toISOString()).toBe('2026-10-07T18:30:00.000Z');
    expect(to.toISOString()).toBe('2026-10-14T18:29:59.999Z');
  });

  test('today follows the India date, not UTC', () => {
    expect(istToday(new Date('2026-10-07T19:00:00Z'))).toBe('2026-10-08');
    expect(istToday(new Date('2026-10-07T18:00:00Z'))).toBe('2026-10-07');
  });

  test('rejects malformed days', () => {
    expect(() => istDayStart('08/10/2026')).toThrow();
  });

  test('clock and distance formatting', () => {
    expect(formatClock('07:00:00')).toBe('07:00');
    expect(formatKm(1940)).toBe('1.9');
  });
});
