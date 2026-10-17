// Probe an isolated Storage copy with UPLOAD_SIGNED_URL_EXPIRATION_TIME=5.
// The primary local Storage retains its actual 7200-second default.
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { writeFile } from 'node:fs/promises';
const base='http://127.0.0.1:55001';
const key=process.env.SERVICE_ROLE_KEY;
if(!key || process.env.API_URL!=='http://127.0.0.1:54321') throw Error('Dedicated local synthetic environment only');
const path='/object/upload/sign/vault/70000000-0000-0000-0000-000000000001/'+randomUUID()+'.png';
const response=await fetch(base+path,{method:'POST',headers:{Authorization:'Bearer '+key,'Content-Type':'application/json'},body:'{}'});
assert.ok(response.ok,'local Storage signing failed');
const {url}=await response.json();
const claims=JSON.parse(Buffer.from(new URL(url,base).searchParams.get('token')!.split('.')[1],'base64url').toString());
assert.equal(claims.exp-claims.iat,5);
const remainingMs=Math.max(0,(claims.exp+2)*1000-Date.now());
assert.ok(remainingMs<10000);
await new Promise(resolve=>setTimeout(resolve,remainingMs));
const upload=await fetch(base+url,{method:'PUT',headers:{'Content-Type':'image/png'},body:Buffer.from('synthetic expired upload')});
assert.ok(!upload.ok);
const result={environment:'isolated local Storage expiry probe',uploadLifetimeSeconds:claims.exp-claims.iat,
  requestAfterExpiryStatus:upload.status,primaryDefaultUploadLifetimeSeconds:7200,primaryConfigurationChanged:false,
  limitation:'Primary 7200-second token expiry was measured from signed claims, not waited two hours; server expiry rejection verified with 5-second configuration on the same image.'};
await writeFile('artifacts/anu002-lifecycle/upload-expiry.json',JSON.stringify(result,null,2));console.log(JSON.stringify(result));
