// Normalizes an Indian mobile number to E.164 (+91XXXXXXXXXX) for Supabase Auth.
// Accepts 10 digits, or with a leading 0, 91 or +91, ignoring spaces and dashes.
export function normalizeIndianMobile(input: string): string | null {
  const digits = input.replace(/[\s-]/g, '');
  const match = /^(?:\+?91|0)?([6-9]\d{9})$/.exec(digits);
  return match ? `+91${match[1]}` : null;
}

export function isOtpCode(input: string): boolean {
  return /^\d{6}$/.test(input.trim());
}
