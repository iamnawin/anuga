# Role-home specification index

The first design slice ends at an existing role-specific home, including first-use
states. These are separate app widgets/routes, not a new unified role router.

- [SCR-FAM-001 Family home](SCR-FAM-001.md), including SCR-FAM-002 bookings entry.
- [SCR-FAM-032 Patient-home concept 25](SCR-FAM-032.md): separate simplified
  destination is not implemented; current patient accounts use Family home.
- [SCR-COMP-001 Companion trip home](SCR-COMP-001.md).
- [SCR-OPS-002 Ops trips home](SCR-OPS-002.md), reached through SCR-OPS-001 redirect.

Design 13 maps to Family home; 31 to Companion home. Design 41 is an Ops overview
concept whose table vocabulary maps to the current trips board; the pictured
overview metrics and additional destinations are not implemented. Design 04
[consent](SCR-FAM-010.md) has a separate specification; making it a mandatory
post-login step needs the patient/owner/consent decision D2.

Existing-home specs are Spec ready for review; the separate Patient-home spec is
Concept/pending decision. No complete screen spec is newly Approved or implemented.
The welcome and Ops user-provisioning direction is accepted in ADR 0006; readiness
mechanism and patient/consent details remain D2, companion verification remains D3. This index
is coordinator-owned; contributors edit only their explicitly reserved spec paths.
