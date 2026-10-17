# Family app product context

## Register

product

## Users and purpose

Family members and patient-level users follow scheduled hospital visits for linked
patients. Backend records determine owner/editor/patient/viewer access. Entry and
provisioning follow the committed ANU-002 contract; a normal empty home is not
setup pending. See [product requirements](../../docs/PRODUCT_SPEC.md) and
[access contract](../../docs/product/PILOT_ACCESS_CONTRACT.md).

## Established design direction

ANUGA wordmark, calm readable patient/visit panels, truthful states and existing
mint/teal/navy themes. Preserve system typography and shared CarePanel/CareHeading.
Sources: [tokens](../../docs/design/tokens.md),
[Family home specification](../../docs/product/screens/SCR-FAM-001.md).
No invented avatar, verification badge, patient, booking, help success or clinical
claim. The sketches are references, not permission or feature approval.

## Accessibility and scope

48px controls, high contrast, en/te/hi, keyboard access, dark theme and uncapped
large text. Preserve four Family destinations and current Patient routing.
Patient/schedule creation, owner consent and help destination remain separate
contracts; no app-only permission checks or implicit consent. Native device,
human-language and assistive-technology acceptance are separate from local tests.
