import { DbError } from './api';
import type { MessageKey } from './messages';

export interface ErrorView {
  key: MessageKey;
  // The database's own message (and hint), shown verbatim so ops sees why.
  detail: string | null;
}

// Maps a database error (SQLSTATE) to a translated summary plus the raw detail.
export function describeError(error: unknown): ErrorView {
  if (!(error instanceof DbError)) {
    return { key: 'error.generic', detail: error instanceof Error ? error.message : null };
  }
  const detail = [error.message, error.hint].filter(Boolean).join(' — ') || null;
  switch (error.code) {
    case 'P0001':
      return { key: /not eligible/i.test(error.message) ? 'error.notEligible' : 'error.invalid', detail };
    case '22023':
      return {
        key: /different companions/i.test(error.message) ? 'error.sameCompanion' : 'error.invalid',
        detail,
      };
    case '42501':
      return { key: 'error.notAllowed', detail };
    case 'P0002':
      return { key: 'error.notFound', detail };
    default:
      return { key: 'error.generic', detail };
  }
}
