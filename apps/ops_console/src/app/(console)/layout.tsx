'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useEffect, useState, type ReactNode } from 'react';
import { currentRole } from '../../lib/ops.ts';
import { opsClient, supabase } from '../../lib/supabase.ts';

const LINKS = [
  { href: '/trips', label: 'Trips' },
  { href: '/schedules', label: 'Schedules' },
  { href: '/exceptions', label: 'Exceptions' },
];

// Client-side gate for a usable UI only. The database rejects every read and
// write from a non-ops user regardless of what this layout renders.
export default function ConsoleLayout({ children }: { children: ReactNode }) {
  const router = useRouter();
  const pathname = usePathname();
  const [ready, setReady] = useState(false);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      const { data } = await supabase().auth.getSession();
      const userId = data.session?.user.id;
      const role = userId ? await currentRole(opsClient(), userId).catch(() => null) : null;
      if (cancelled) return;
      if (role === 'ops_admin') setReady(true);
      else {
        if (userId) await supabase().auth.signOut();
        router.replace('/login');
      }
    })();
    return () => { cancelled = true; };
  }, [router]);

  async function signOut() {
    await supabase().auth.signOut();
    router.replace('/login');
  }

  if (!ready) return <main><p className="muted">Checking sign-in...</p></main>;

  return (
    <>
      <nav className="nav" aria-label="Main">
        {LINKS.map((link) => (
          <Link key={link.href} href={link.href} aria-current={pathname === link.href ? 'page' : undefined}>
            {link.label}
          </Link>
        ))}
        <span className="spacer" />
        <button type="button" onClick={signOut}>Sign out</button>
      </nav>
      <main>{children}</main>
    </>
  );
}
