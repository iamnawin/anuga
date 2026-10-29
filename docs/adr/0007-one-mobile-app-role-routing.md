# ADR 0007: One AnugaCare mobile app, home chosen by the database role

- Status: proposed (founder asked for the first unified app slice, 2026-10-26; accepted when the
  draft PR is approved)
- Date: 2026-10-26

## Context

`docs/PRODUCT_SPEC.md` §5a says "two apps in the monorepo": `apps/family_app` for owners, patients
and shared family members, and `apps/companion_app` for companions. ADR 0006 made AnugaCare a
mobile-first brand and deferred the final application id to app consolidation (X1 in
`docs/research/anugacare-mobile-analysis.md`). Two store listings for one small service would
confuse elderly users and their families, and companions are also recruited from the same
neighbourhoods as the families.

Both apps already sign in the same way (Supabase phone OTP with `shouldCreateUser: false`) and
read the role from `profiles.role` through `PhoneAuth.currentRole()`. The role is
database-authoritative: RLS lets users read only their own profile, and authenticated users can
update only `full_name`, `phone` and `preferred_language`, so nobody can change their own role
(allowed and denied tests in `supabase/tests/access.test.ts`). Every RPC re-checks access.

## Decision

1. **One entry app:** `apps/anugacare_app` is the single AnugaCare mobile app. It has one
   sign-in (phone, then SMS code) and no role picker.
2. **Routing:** after every sign-in and on launch with a stored session, the app reads
   `profiles.role`. `family` opens the existing family home, `companion` the existing companion
   trips screen. `ops_admin` is signed out and pointed to the ops web console. Any other value,
   or no profile, is signed out and refused. Nothing on screen chooses or changes the role, and
   the database still checks every RPC, so the routing only decides which screens appear.
3. **States:** checking (spinner), failed lookup (retry keeps the session, or sign out), expired
   session (cleared, asks to sign in again, also when the session ends while a home is open).
4. **Transition:** the family and companion screens stay in their own packages, unchanged, and are
   mounted through `lib/family_app.dart` and `lib/companion_app.dart`. Both apps still build and
   ship on their own until the unified app replaces them; then their `main.dart` entry points and
   Android projects can be removed in a separate change.
5. **Not changed:** database, RLS, RPCs, auth provider, consents, patient routing inside the family
   home, ops console. Application id stays `com.zeroorigins.anugacare_app` until the final id is
   chosen (ADR 0006 point 4; the research suggests `in.anugacare.app`).

## Spec changes

- §5a stack table: "two apps in the monorepo" becomes one AnugaCare app with family and companion
  views chosen by `profiles.role`.
- §5a repo layout: adds `apps/anugacare_app`.
- Where §2 and §3 say "Family app" or "Companion app", read the family or companion views of the
  AnugaCare app. Who sees what is unchanged.

## Consequences

- One store listing and one install for every mobile user. A person who is both family and
  companion still needs two accounts (one role per profile), as today.
- Companion-only device permissions (location during a trip) must be requested only in the
  companion view, never at install or sign-in.
- The unified app depends on the other two packages by path. Their localizations are generated
  and gitignored, so `flutter pub get` must run in `family_app` and `companion_app` first
  (`scripts/check-all.sh` and CI do this).
- Changes to the `HomeScreen` or `TripsScreen` constructors need a matching change in
  `apps/anugacare_app/lib/src/app.dart`; the `anugacare-app` CI job fails until it is made.
