// Actual combined builds and local Auth; no intercepted role/state answers.
import {createRequire} from 'node:module';
import {randomUUID} from 'node:crypto';
import {mkdir,writeFile} from 'node:fs/promises';
import assert from 'node:assert/strict';
import pg from 'pg';
const require=createRequire(new URL('../apps/ops_console/package.json',import.meta.url));
const {chromium}=require('@playwright/test');
const api=process.env.API_URL, key=process.env.SERVICE_ROLE_KEY, anon=process.env.ANON_KEY;
if(api!=='http://127.0.0.1:54321'||!key||!anon)throw Error('Dedicated local synthetic API only');
const base='http://127.0.0.1:3110';
const output='artifacts/anu002-lifecycle/browser';await mkdir(output,{recursive:true});
const headers={apikey:anon,Authorization:'Bearer '+key,'Content-Type':'application/json'};
const email='synthetic-pending-'+randomUUID()+'@example.test',password=randomUUID()+randomUUID();
const created=await fetch(api+'/auth/v1/admin/users',{method:'POST',headers,body:JSON.stringify({email,password,email_confirm:true,user_metadata:{full_name:'Synthetic pending browser'}})});assert.ok(created.ok);
const user=await created.json();
const signed=await fetch(api+'/auth/v1/token?grant_type=password',{method:'POST',headers:{...headers,Authorization:'Bearer '+anon},body:JSON.stringify({email,password})});assert.ok(signed.ok);const session=await signed.json();session.expires_at??=Math.floor(Date.now()/1000)+session.expires_in;
const db=new pg.Client({connectionString:'postgresql://postgres:postgres@127.0.0.1:54322/postgres'});await db.connect();
const browser=await chromium.launch({channel:'msedge',headless:true});const results=[];
try {
for(const state of ['pending','disabled']){
 if(state==='disabled')await db.query(`select private.configure_pilot_account(id,account_state_version,'disabled',null,'synthetic browser state','synthetic:browser','synthetic:local-assumption') from public.profiles where id=$1`,[user.id]);
 for(const [app,storage]of [['family','anuga-family-auth'],['companion','anuga-companion-auth'],['ops','companion-ops-auth']]){
  const context=await browser.newContext({viewport:{width:430,height:1000}});const page=await context.newPage();const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await context.addInitScript(({key,value})=>localStorage.setItem(key,JSON.stringify(value)),{key:storage,value:session});
  await page.goto(base+(app==='ops'?'/ops/login/':'/'+app+'/'));
  if(app!=='ops'){
   await page.locator('flutter-view').waitFor({timeout:60000});
   await page.locator('flt-semantics-placeholder').evaluate(e=>e.click());
  }
  const message=state==='pending'?'Your pilot account setup is pending. Ops needs to finish your access setup.':'Your account access is disabled.';
  await page.getByText(message,{exact:true}).last().waitFor({timeout:30000});
  await page.screenshot({path:output+'/'+app+'-'+state+'-en.png',fullPage:false});
  results.push({app,state,locale:'en',pageErrors:errors});
  for(const lang of ['te','hi']){
   if(app==='ops')await page.getByRole('combobox').selectOption(lang);
   else{
    const tooltip=lang==='te'?'Language':'భాష';
    await page.getByRole('button',{name:tooltip,exact:true}).click();
    await page.getByRole('menuitem',{name:lang==='te'?'తెలుగు':'हिन्दी',exact:true}).click();
   }
   await page.emulateMedia({colorScheme:lang==='te'?'dark':'light'});
   await page.waitForTimeout(2500);
   await page.screenshot({path:output+'/'+app+'-'+state+'-'+lang+'.png',fullPage:false});
   results.push({app,state,locale:lang,pageErrors:[...errors],nativeReview:'not performed'});
  }
  await context.close();
 }
}

for(const [app,storage,phone,id]of [
 ['family','anuga-family-auth','+919000000101','20000000-0000-0000-0000-000000000001'],
 ['companion','anuga-companion-auth','+919000000202','30000000-0000-0000-0000-000000000002'],
 ['ops','companion-ops-auth','+919000000001','10000000-0000-0000-0000-000000000001']]) {
 const send=await fetch(api+'/auth/v1/otp',{method:'POST',headers:{...headers,Authorization:'Bearer '+anon},body:JSON.stringify({phone,create_user:false})});assert.ok(send.ok);
 const verify=await fetch(api+'/auth/v1/verify',{method:'POST',headers:{...headers,Authorization:'Bearer '+anon},body:JSON.stringify({phone,token:'123456',type:'sms'})});assert.ok(verify.ok);const current=await verify.json();current.expires_at??=Math.floor(Date.now()/1000)+current.expires_in;
 const context=await browser.newContext({viewport:{width:430,height:1000}});const page=await context.newPage();
 await context.addInitScript(({key,value})=>localStorage.setItem(key,JSON.stringify(value)),{key:storage,value:current});
 await page.goto(base+(app==='ops'?'/ops/trips/':'/'+app+'/'));
 if(app!=='ops'){await page.locator('flutter-view').waitFor();await page.locator('flt-semantics-placeholder').evaluate(e=>e.click());}
 await page.getByRole(app==='family'?'tab':'button',{name:app==='family'?'Updates':'Refresh',exact:true}).waitFor({timeout:30000});
 await db.query(`select private.configure_pilot_account(id,account_state_version,'disabled',null,'synthetic remote disable','synthetic:browser','synthetic:local-assumption') from public.profiles where id=$1`,[id]);
 try {
  await page.getByRole(app==='family'?'tab':'button',{name:app==='family'?'Updates':'Refresh',exact:true}).click();
  await page.getByText('Your account access is disabled.',{exact:true}).last().waitFor({timeout:30000});
  await page.screenshot({path:output+'/'+app+'-existing-session-disabled.png',fullPage:false});
  results.push({app,scenario:'existing session protected request rechecks and displays disabled without reload',passed:true});
 } finally {
  await db.query(`select private.configure_pilot_account(id,account_state_version,'active',null,'synthetic cleanup','synthetic:browser','synthetic:local-assumption') from public.profiles where id=$1`,[id]);
  await context.close();
 }
}
await writeFile(output+'/results.json',JSON.stringify({environment:'actual local builds + real Auth/DB resolver',fixtureLogin:'Admin-created synthetic email identity for state rendering only; phone-OTP UI separately checked by web-session-smoke',results},null,2));console.log(JSON.stringify(results));
 }catch(error){
 const page=browser.contexts().flatMap(c=>c.pages()).at(-1);
 if(page){await page.screenshot({path:output+'/failure.png',fullPage:false});await writeFile(output+'/failure-dom.json',JSON.stringify(await page.locator('[role]').evaluateAll(es=>es.map(e=>({role:e.getAttribute('role'),label:e.getAttribute('aria-label'),text:e.textContent}))),null,2));}
 throw error;
}finally{await browser.close();await db.end();}
