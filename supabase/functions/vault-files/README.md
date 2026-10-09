# vault-files (Edge Function)

Signed URLs for the private `vault` storage bucket. App roles have no storage policies, so
this function is the only way a file goes in or out. Every action first asks the database **as
the caller** (their JWT) and only then signs a URL with the service role for the path the
database returned:

| Action | Database check (caller's JWT) | Then (service role) |
| --- | --- | --- |
| `upload` | `vault_create_document`: owner/editor, owner's `vault` consent, type and size limits; generates the path | signed upload URL for that one path (no overwrite) |
| `confirm` | `vault_upload_target`: editor, document still pending | object exists? -> `vault_mark_uploaded` |
| `download` | `vault_document_download`: the audited vault read (family, or ops with the owner's `ops_vault_access` consent) | signed download URL, lifetime `app_settings.vault_signed_url_seconds` (60 s) |

Responses carry URL **paths** (`/storage/v1/...`); the app prefixes its own Supabase URL, because
inside the edge runtime `SUPABASE_URL` is an internal address.

Known limit: Supabase signs upload URLs for 2 hours (not configurable). The URL is for one
server-chosen path, cannot overwrite, and the document stays `pending_upload` until confirmed.

`handler.ts` is runtime-neutral (Node unit tests: `supabase/tests/vault_files_unit.test.ts`);
`index.ts` is the Deno entry. Real-Supabase test: `supabase/tests/vault_files_function.test.ts`.
After editing, restart the local edge runtime (`docker restart supabase_edge_runtime_companion`);
a new function folder needs `supabase stop` + `start`.
