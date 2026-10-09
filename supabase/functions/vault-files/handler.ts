// vault-files: signed URLs for the private `vault` bucket. Runtime-neutral (the
// Deno entry is index.ts; Node tests call handleVaultRequest with fakes).
//
// Every action first asks the database, with the caller's own JWT, whether the
// caller may do it (the same functions apps call); only then does it use the
// service role to sign a URL for the path the database returned:
//   upload   -> vault_create_document          -> signed upload URL (one path, no overwrite)
//   confirm  -> vault_upload_target            -> object exists? -> vault_mark_uploaded (service)
//   download -> vault_document_download (audited vault read) -> signed URL (short-lived)
// URLs are returned as paths ("/storage/v1/..."): the app prefixes its own Supabase URL.

export interface RpcFailure { status: number; code: string; message: string }

export class RpcError extends Error implements RpcFailure {
  readonly status: number;
  readonly code: string;

  constructor(failure: RpcFailure) {
    super(failure.message);
    this.name = 'RpcError';
    this.status = failure.status;
    this.code = failure.code;
  }
}

export interface VaultDeps {
  /** Calls a database function as the user whose JWT is given. Throws RpcError. */
  userRpc(jwt: string, fn: string, args: Record<string, unknown>): Promise<unknown>;
  /** Calls a database function as the service role. Throws RpcError. */
  serviceRpc(fn: string, args: Record<string, unknown>): Promise<unknown>;
  /** Service role: signed upload URL path for exactly this object path. */
  signUpload(path: string): Promise<string>;
  /** Service role: signed download URL path valid for `seconds`. */
  signDownload(path: string, seconds: number): Promise<string>;
  /** Service role: the stored object's size, or null when it does not exist. */
  objectSize(path: string): Promise<number | null>;
}

const json = (body: unknown, status = 200) => Response.json(body, { status });

function bearer(request: Request): string | null {
  const value = request.headers.get('Authorization') ?? '';
  const match = /^Bearer\s+(\S+)$/i.exec(value);
  return match ? match[1] : null;
}

function claims(jwt: string): Record<string, unknown> | null {
  try {
    const part = jwt.split('.')[1];
    return JSON.parse(atob(part.replace(/-/g, '+').replace(/_/g, '/'))) as Record<string, unknown>;
  } catch {
    return null;
  }
}

function errorResponse(error: unknown): Response {
  if (error instanceof RpcError) {
    if (error.code === '42501') return json({ error: 'not_allowed', message: error.message }, 403);
    if (error.code === '22023' || error.code === 'P0002') return json({ error: 'invalid', message: error.message }, 400);
    return json({ error: 'database', message: error.message }, 502);
  }
  // Server log only (no request body, so no patient data); the client gets a generic error.
  console.error('vault-files:', error instanceof Error ? error.message : String(error));
  return json({ error: 'internal', message: 'unexpected error' }, 500);
}

export async function handleVaultRequest(request: Request, deps: VaultDeps): Promise<Response> {
  if (request.method !== 'POST') return json({ error: 'method_not_allowed' }, 405);
  const jwt = bearer(request);
  // Only signed-in users; the platform has already verified the signature (verify_jwt).
  if (!jwt || claims(jwt)?.role !== 'authenticated' || typeof claims(jwt)?.sub !== 'string') {
    return json({ error: 'sign_in_required' }, 401);
  }

  let body: Record<string, unknown>;
  try {
    body = (await request.json()) as Record<string, unknown>;
  } catch {
    return json({ error: 'invalid', message: 'JSON body required' }, 400);
  }

  try {
    switch (body.action) {
      case 'upload': {
        const rows = (await deps.userRpc(jwt, 'vault_create_document', {
          p_patient_id: body.patient_id,
          p_doc_type: body.doc_type,
          p_title: body.title,
          p_content_type: body.content_type,
          p_size_bytes: body.size_bytes,
        })) as { document_id: string; storage_path: string }[];
        const doc = rows[0];
        return json({ document_id: doc.document_id, upload_path: await deps.signUpload(doc.storage_path) });
      }
      case 'confirm': {
        const path = (await deps.userRpc(jwt, 'vault_upload_target', { p_document_id: body.document_id })) as string;
        const size = await deps.objectSize(path);
        if (size === null) return json({ error: 'invalid', message: 'file not uploaded yet' }, 400);
        await deps.serviceRpc('vault_mark_uploaded', { p_document_id: body.document_id, p_size_bytes: size });
        return json({ document_id: body.document_id, status: 'uploaded', size_bytes: size });
      }
      case 'download': {
        const rows = (await deps.userRpc(jwt, 'vault_document_download', {
          p_document_id: body.document_id,
          p_purpose: typeof body.purpose === 'string' ? body.purpose : 'view in app',
        })) as { storage_path: string; content_type: string; url_seconds: number }[];
        const doc = rows[0];
        return json({
          download_path: await deps.signDownload(doc.storage_path, doc.url_seconds),
          content_type: doc.content_type,
          expires_in: doc.url_seconds,
        });
      }
      default:
        return json({ error: 'invalid', message: 'action must be upload, confirm or download' }, 400);
    }
  } catch (error) {
    return errorResponse(error);
  }
}

/** VaultDeps over Supabase REST (PostgREST + Storage). Server side only. */
export function supabaseVaultDeps(
  supabaseUrl: string, anonKey: string, serviceRoleKey: string, fetchImpl: typeof fetch = fetch,
): VaultDeps {
  const base = supabaseUrl.replace(/\/$/, '');

  async function rpc(authorization: string, apikey: string, fn: string, args: Record<string, unknown>): Promise<unknown> {
    const response = await fetchImpl(`${base}/rest/v1/rpc/${fn}`, {
      method: 'POST',
      headers: { apikey, Authorization: `Bearer ${authorization}`, 'Content-Type': 'application/json' },
      body: JSON.stringify(args),
    });
    const text = await response.text();
    const data = text ? JSON.parse(text) : null;
    if (!response.ok) {
      throw new RpcError({ status: response.status, code: data?.code ?? String(response.status), message: data?.message ?? text });
    }
    return data;
  }

  async function storage(path: string, init: RequestInit = {}): Promise<Response> {
    return fetchImpl(`${base}/storage/v1${path}`, {
      ...init,
      headers: { apikey: serviceRoleKey, Authorization: `Bearer ${serviceRoleKey}`, 'Content-Type': 'application/json' },
    });
  }

  const objectPath = (path: string) => path.split('/').map(encodeURIComponent).join('/');

  return {
    userRpc: (jwt, fn, args) => rpc(jwt, anonKey, fn, args),
    serviceRpc: (fn, args) => rpc(serviceRoleKey, serviceRoleKey, fn, args),
    async signUpload(path) {
      // Storage rejects an empty body sent as JSON, so send an empty object.
      const response = await storage(`/object/upload/sign/vault/${objectPath(path)}`, { method: 'POST', body: '{}' });
      if (!response.ok) throw new Error(`sign upload: HTTP ${response.status}`);
      return `/storage/v1${((await response.json()) as { url: string }).url}`;
    },
    async signDownload(path, seconds) {
      const response = await storage(`/object/sign/vault/${objectPath(path)}`, {
        method: 'POST', body: JSON.stringify({ expiresIn: seconds }),
      });
      if (!response.ok) throw new Error(`sign download: HTTP ${response.status}`);
      return `/storage/v1${((await response.json()) as { signedURL: string }).signedURL}`;
    },
    async objectSize(path) {
      const response = await storage(`/object/info/vault/${objectPath(path)}`);
      if (response.status === 400 || response.status === 404) return null;
      if (!response.ok) throw new Error(`object info: HTTP ${response.status}`);
      return ((await response.json()) as { size: number }).size;
    },
  };
}
