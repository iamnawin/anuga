import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {seed,handle} from './demo-core.mjs';
const {transitions}=JSON.parse(await readFile(new URL('../packages/shared_dart/test/fixtures/trip_contract.json',import.meta.url)));
const base='https://synthetic-anuga.invalid';
async function call(s,path,body,jwt) {const r=await handle(s,new Request(base+path,{method:body===undefined?'GET':'POST',headers:{'Content-Type':'application/json',...(jwt?{Authorization:'Bearer '+jwt}:{})},body:body===undefined?undefined:JSON.stringify(body)}));return {status:r.status,data:await r.json()};}
async function login(s,phone) {const r=await call(s,'/auth/v1/verify',{phone:'+91'+phone,token:'123456'});assert.equal(r.status,200);return r.data.access_token;}
const rpc=(s,j,fn,b={})=>call(s,'/rest/v1/rpc/'+fn,b,j);

test('simulated login validates known accounts/code; roles and lifecycle states are separate',async()=>{
 const s=seed(transitions);assert.equal((await call(s,'/auth/v1/otp',{phone:'+919999999999'})).status,422);
 assert.equal((await call(s,'/auth/v1/verify',{phone:'+919000000101',token:'000000'})).status,403);
 for(const phone of ['9000000101','9000000201','9000000001','9000000901','9000000902','9000000903']){
  const j=await login(s,phone),a=s.accounts.find(a=>a.phone==='91'+phone),r=await rpc(s,j,'my_account_access');
  assert.deepEqual(r.data,{state:a.state,role:a.state==='active'?a.role:null});
  if(a.state!=='active')assert.equal((await rpc(s,j,'family_my_patients')).status,403);
 }
});
test('one demo visit persists across Family, Companion and Ops views; pickup code is separate from login',async()=>{
 const s=seed(transitions),f=await login(s,'9000000101'),c=await login(s,'9000000201'),o=await login(s,'9000000001');
 const trip=s.trips[0],pid=trip.patient_id;
 assert.equal((await rpc(s,f,'family_trip_board',{p_patient_id:pid})).data[0].status,'scheduled');
 await rpc(s,c,'advance_trip',{p_trip_id:trip.id,p_to_status:'companion_en_route'});
 assert.equal((await rpc(s,f,'issue_pickup_otp',{p_trip_id:trip.id})).data,'482913');
 assert.equal((await rpc(s,c,'companion_my_trips')).data[0].otp,undefined);
 assert.equal((await rpc(s,c,'verify_pickup_otp',{p_trip_id:trip.id,p_code:'123456'})).data.ok,false);
 assert.equal((await rpc(s,c,'verify_pickup_otp',{p_trip_id:trip.id,p_code:'482913'})).data.ok,true);
 assert.equal((await rpc(s,o,'ops_trip_board')).data[0].status,'picked_up');
 for(const to of ['at_centre','handed_over','session_done','returning','dropped_home'])assert.equal((await rpc(s,c,'advance_trip',{p_trip_id:trip.id,p_to_status:to})).status,200,to);
 assert.equal((await rpc(s,c,'advance_trip',{p_trip_id:trip.id,p_to_status:'completed'})).status,400);
 assert.equal((await rpc(s,c,'advance_trip',{p_trip_id:trip.id,p_to_status:'completed',p_note:'Synthetic completion note'})).status,200);
 const restored=structuredClone(s);assert.equal((await rpc(restored,f,'family_trip_board',{p_patient_id:pid})).data[0].status,'completed');
 assert.equal((await rpc(restored,f,'my_notifications')).data.length>0,true);
});
test('demo schedule and billing forms validate and keep their resulting state',async()=>{
 const s=seed(transitions),o=await login(s,'9000000001'),f=await login(s,'9000000101');
 const [asha,ravi]=s.accounts.filter(a=>a.role==='companion');
 assert.equal((await rpc(s,o,'ops_assign_schedule_companions',{p_primary_id:asha.id,p_backup_id:asha.id})).status,400);
 assert.equal((await rpc(s,o,'ops_assign_schedule_companions',{p_primary_id:ravi.id,p_backup_id:null})).status,200);
 assert.equal((await rpc(s,o,'ops_schedule_board')).data[0].primary_companion_id,ravi.id);
 assert.equal((await rpc(s,f,'ops_schedule_board')).status,403);
 assert.equal((await rpc(s,o,'ops_generate_invoice',{p_patient_id:'not-a-demo-patient',p_month:'2030-01-01'})).status,400);
 const id=(await rpc(s,o,'ops_generate_invoice',{p_patient_id:s.patients[0].id,p_month:'2030-01-01'})).data;
 assert.equal(s.invoices.find(i=>i.invoice_id===id).status,'draft');
 assert.equal((await rpc(s,o,'ops_issue_invoice',{p_invoice_id:id})).status,200);
 assert.equal(s.invoices.find(i=>i.invoice_id===id).status,'issued');
});
test('demo owner/editor/patient/viewer actions match existing boundaries; revocation stays revoked',async()=>{
 const s=seed(transitions),pid=s.patients[0].id,trip=s.trips[0];
 for(const [phone,canIssue,canEdit]of [['9000000101',true,true],['9000000103',true,true],['9000000104',true,false],['9000000102',false,false]]){
  const j=await login(s,phone);assert.equal((await rpc(s,j,'issue_pickup_otp',{p_trip_id:trip.id})).status,canIssue?200:403);
  assert.equal((await rpc(s,j,'family_invoices',{p_patient_id:pid})).status,canEdit?200:403);
  assert.equal((await rpc(s,j,'set_consent',{p_patient_id:pid,p_purpose:'vault',p_active:true})).status,phone==='9000000101'?200:403);
 }
 const viewer=await login(s,'9000000102');await call(s,'/demo/scenario',{scenario:'revoke-viewer'});
 assert.deepEqual((await rpc(s,viewer,'family_my_patients')).data,[]);await call(s,'/demo/scenario',{scenario:'normal'});
 assert.deepEqual((await rpc(s,viewer,'family_my_patients')).data,[]);
});
test('simulated payment updates the same invoice; companion cannot read patient records or manage Ops',async()=>{
 const s=seed(transitions),f=await login(s,'9000000101'),c=await login(s,'9000000201'),o=await login(s,'9000000001'),pid=s.patients[0].id;
 assert.equal((await rpc(s,c,'vault_list_documents',{p_patient_id:pid})).status,403);
 assert.equal((await rpc(s,c,'ops_trip_board')).status,403);
 const invoice=s.invoices[0].invoice_id;assert.equal((await call(s,'/functions/v1/payments',{action:'complete-test',invoice_id:invoice},f)).status,200);
 assert.equal((await rpc(s,o,'ops_invoices')).data[0].status,'paid');
});
test('demo file stays in local state and consent gates new authorisation; explicit reset restores fixtures',async()=>{
 const s=seed(transitions),f=await login(s,'9000000101'),pid=s.patients[0].id;
 let r=await call(s,'/functions/v1/vault-files',{action:'upload',patient_id:pid,title:'Synthetic image',doc_type:'other',content_type:'image/png',size_bytes:3},f);
 assert.equal(r.status,200);const id=r.data.document_id;
 await handle(s,new Request(base+r.data.upload_path,{method:'PUT',body:new Uint8Array([1,2,3])}));
 assert.equal((await call(s,'/functions/v1/vault-files',{action:'confirm',document_id:id},f)).status,200);
 assert.equal(s.files[id].byteLength,3);
 await rpc(s,f,'set_consent',{p_patient_id:pid,p_purpose:'vault',p_active:false});
 assert.equal((await call(s,'/functions/v1/vault-files',{action:'download',document_id:id},f)).status,403);
 await call(s,'/demo/reset',{});assert.equal(s.docs.length,0);assert.equal(s.consents[pid].vault,true);
});
