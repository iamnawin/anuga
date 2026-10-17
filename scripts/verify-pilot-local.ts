// Destructive ONLY to the dedicated disposable local synthetic stack. No hosted targets.
// node --env-file=artifacts/anu002-lifecycle/local.env scripts/verify-pilot-local.ts
import assert from 'node:assert/strict';
import { mkdir, writeFile } from 'node:fs/promises';
import pg from 'pg';
const base = process.env.API_URL;
const anon = process.env.ANON_KEY;
const service = process.env.SERVICE_ROLE_KEY;
if (!base || !anon || !service || new URL(base).hostname !== '127.0.0.1' || new URL(base).port !== '54321') throw Error('Dedicated loopback synthetic stack required');
const db = new pg.Client({ connectionString: 'postgresql://postgres:postgres@127.0.0.1:54322/postgres' });
await db.connect();
const results: Record<string, unknown>[] = [];
const output = 'artifacts/anu002-lifecycle';
await mkdir(output, { recursive: true });
const headers = (key:string) => ({apikey:anon!,Authorization:'Bearer '+key,'Content-Type':'application/json'});
async function call(path:string, key:string, body?:unknown, method='POST') {
  return fetch(base+path,{method,headers:headers(key),body:body===undefined?undefined:JSON.stringify(body)});
}
async function rpc(jwt:string,fn:string,body:object={}) {
  return call('/rest/v1/rpc/'+fn,jwt,body);
}
async function signIn(phone:string) {
  const send=await call('/auth/v1/otp',anon!,{phone,create_user:false});
  assert.ok(send.ok,'local test OTP send failed');
  const verify=await call('/auth/v1/verify',anon!,{phone,token:'123456',type:'sms'});
  assert.ok(verify.ok,'local test OTP verification failed');
  return (await verify.json()).access_token as string;
}
async function state(id:string,value:string,role:string|null=null) {
  await db.query(`select private.configure_pilot_account(id,account_state_version,$2,$3,
    'local synthetic verification','synthetic:local-harness','synthetic:provisional-defaults')
    from public.profiles where id=$1`,[id,value,role]);
}
try {
  const marker=await db.query("select full_name from public.profiles where id='20000000-0000-0000-0000-000000000001'");
  assert.equal(marker.rows[0]?.full_name,'Kiran Rao (synthetic)','Dedicated synthetic seed required');
  const unknown = await call('/auth/v1/otp',anon!,{phone:'+919000009999',create_user:false});
  assert.ok(!unknown.ok);
  const signup=await call('/auth/v1/otp',anon!,{phone:'+919000009999',create_user:true});
  assert.ok(!signup.ok,'public signup must remain disabled even when a client requests account creation');
  results.push({scenario:'unknown phone cannot self-register; explicit create_user=true also refused',status:unknown.status,explicitSignupStatus:signup.status});
  for (const [phone,role] of [['+919000009991','family'],['+919000009992','companion'],['+919000009993','ops_admin']]) {
    const created=await call('/auth/v1/admin/users',service!,{phone,phone_confirm:true,user_metadata:{full_name:'Synthetic lifecycle verification',role:'ops_admin',account_state:'active'}});
    assert.ok(created.ok,'synthetic Admin API creation failed');
    const user=await created.json(); const id=user.id as string;
    const jwt=await signIn(phone);
    assert.deepEqual(await (await rpc(jwt,'my_account_access')).json(),{state:'pending',role:null});
    const wrong=await call('/auth/v1/verify',anon!,{phone,token:'654321',type:'sms'});assert.ok(!wrong.ok);
    const manage=await rpc(jwt,'configure_pilot_account',{p_user_id:id});assert.ok(!manage.ok);
    for (const token of [jwt,service!]) {
      const direct=await fetch(base+'/rest/v1/profiles?id=eq.'+id,{method:'PATCH',headers:headers(token),body:JSON.stringify({account_state:'active'})});
      assert.ok(!direct.ok,'management escalation must fail');
    }
    await state(id,'active',role);
    assert.deepEqual(await (await rpc(jwt,'my_account_access')).json(),{state:'active',role});
    const fn=role==='family'?'family_my_patients':role==='companion'?'companion_my_trips':'ops_schedule_board';
    assert.ok((await rpc(jwt,fn)).ok);
    await state(id,'disabled');
    assert.deepEqual(await (await rpc(jwt,'my_account_access')).json(),{state:'disabled',role:null});
    const denied=await rpc(jwt,fn);assert.equal(denied.status,403);
    await state(id,'active');
    assert.ok((await rpc(jwt,fn)).ok);
    const counts=await db.query('select count(*)::int as count from public.patient_access where user_id=$1',[id]);
    assert.equal(counts.rows[0].count,0);
    results.push({scenario:'real Auth pending/active/disabled/reactivated with SAME JWT; no new grants',role,deniedStatus:denied.status,managementDenied:true});
  }
  const ownerId='20000000-0000-0000-0000-000000000001';
  const viewerId='20000000-0000-0000-0000-000000000002';
  const patientId='70000000-0000-0000-0000-000000000001';
  const owner=await signIn('+919000000101');
  const viewer=await signIn('+919000000102');
  await db.query('delete from public.patient_access where user_id=$1',[viewerId]);
  await state(viewerId,'disabled');await state(viewerId,'active');
  assert.deepEqual(await (await rpc(viewer,'family_my_patients')).json(),[]);
  await db.query(`update public.consents set withdrawn_at=now() where user_id=$1 and purpose='vault'`,[ownerId]);
  await state(ownerId,'disabled');await state(ownerId,'active');
  const consent=await db.query(`select count(*)::int as count from public.consents where user_id=$1 and purpose='vault' and withdrawn_at is null`,[ownerId]);
  assert.equal(consent.rows[0].count,0);
  results.push({scenario:'reactivation with old JWT does not restore deleted patient grants or withdrawn consent',passed:true});
  assert.ok((await rpc(owner,'set_consent',{p_patient_id:patientId,p_purpose:'vault',p_active:true})).ok,'synthetic owner explicitly consents for storage fixture');
  const png=Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Y9Zl1sAAAAASUVORK5CYII=','base64');
  async function vault(body:object) {return call('/functions/v1/vault-files',owner,body);}
  const started=await vault({action:'upload',patient_id:patientId,doc_type:'lab_report',title:'Synthetic lifecycle expiry',content_type:'image/png',size_bytes:png.length});
  assert.ok(started.ok,'vault upload authorisation failed: '+started.status); const doc=await started.json();
  const uploaded=await fetch(base+doc.upload_path,{method:'PUT',headers:{'Content-Type':'image/png'},body:png});assert.ok(uploaded.ok,'signed upload failed');
  assert.ok((await vault({action:'confirm',document_id:doc.document_id})).ok);
  const download=await vault({action:'download',document_id:doc.document_id});assert.ok(download.ok);const file=await download.json();
  const stillPending=await vault({action:'upload',patient_id:patientId,doc_type:'lab_report',title:'Synthetic preissued capability',content_type:'image/png',size_bytes:png.length});assert.ok(stillPending.ok);const preissued=await stillPending.json();
  const claims=(url:string)=>JSON.parse(Buffer.from(new URL(url,base).searchParams.get('token')!.split('.')[1],'base64url').toString());
  const uploadClaims=claims(preissued.upload_path), downloadClaims=claims(file.download_path);
  await state(ownerId,'disabled');
  assert.equal((await vault({action:'download',document_id:doc.document_id})).status,403);
  assert.equal((await vault({action:'upload',patient_id:patientId,doc_type:'lab_report',title:'Synthetic denied',content_type:'image/png',size_bytes:png.length})).status,403);
  const readable=await fetch(base+file.download_path);assert.equal(readable.status,200);
  const writable=await fetch(base+preissued.upload_path,{method:'PUT',headers:{'Content-Type':'image/png'},body:png});assert.ok(writable.ok);
  assert.equal((await vault({action:'confirm',document_id:preissued.document_id})).status,403);
  const expiry={scenario:'issued Storage URLs after disable',downloadTokenLifetimeSeconds:downloadClaims.exp-downloadClaims.iat,
    uploadTokenLifetimeSeconds:uploadClaims.exp-uploadClaims.iat,preissuedDownloadAfterDisable:readable.status,
    preissuedUploadAfterDisable:writable.status,newURLRequestsDenied:true,confirmationDenied:true,downloadAfterExpiry:null as number|null};
  console.log('Storage lifetime measurement: '+JSON.stringify(expiry));
  const waitMs=Math.max(0,(downloadClaims.exp+2)*1000-Date.now());
  if(waitMs>120000)throw Error('Unexpected download lifetime; do not wait unbounded');
  await new Promise(resolve=>setTimeout(resolve,waitMs));
  expiry.downloadAfterExpiry=(await fetch(base+file.download_path,{cache:'no-store'})).status;
  assert.notEqual(expiry.downloadAfterExpiry,200);
  results.push(expiry);
  await state(ownerId,'active');
  // Remove fixture-only suppression for later browser verification using existing records,
  // not by granting anything in the activation function.
  await db.query(`insert into public.patient_access(patient_id,user_id,access_level) values($1,$2,'viewer')`,[patientId,viewerId]);
  await writeFile(output+'/real-auth-storage.json',JSON.stringify({provisionalAssumptions:true,rolloutApproved:false,environment:'dedicated local synthetic Supabase',results},null,2));
  console.log(JSON.stringify(results));
} finally {await db.end();}
