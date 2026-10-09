import { DbError } from '@/lib/api';
import { describeError } from '@/lib/errors';

describe('describeError', () => {
  test('eligibility rejection keeps the database message and hint', () => {
    const view = describeError(new DbError({
      code: 'P0001',
      message: 'companion 3000 is not eligible for patient 7000',
      hint: 'must be verified, active, in the cluster and within its radius',
    }));
    expect(view.key).toBe('error.notEligible');
    expect(view.detail).toContain('not eligible');
    expect(view.detail).toContain('within its radius');
  });

  test.each([
    ['22023', 'primary and backup must be two different companions', 'error.sameCompanion'],
    ['22023', 'only scheduled trips can be reassigned', 'error.invalid'],
    ['42501', 'ops only', 'error.notAllowed'],
    ['P0002', 'trip x not found', 'error.notFound'],
    ['XX000', 'boom', 'error.generic'],
  ])('%s %s -> %s', (code, message, key) => {
    expect(describeError(new DbError({ code, message })).key).toBe(key);
  });

  test('non-database errors are generic', () => {
    expect(describeError(new Error('network down'))).toEqual({ key: 'error.generic', detail: 'network down' });
    expect(describeError('x')).toEqual({ key: 'error.generic', detail: null });
  });
});
