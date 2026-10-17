import {createServer} from 'node:http';
import {readFile,stat,mkdir,writeFile} from 'node:fs/promises';
import {resolve,extname,sep} from 'node:path';
import {createRequire} from 'node:module';
import assert from 'node:assert/strict';
const require=createRequire(new URL('../apps/ops_console/package.json',import.meta.url));
const {chromium,expect}=require('@playwright/test');
const output=process.env.ANUGA_DEMO_EVIDENCE??'artifacts/interactive-preview/browser';await mkdir(output,{recursive:true});
const root=resolve('artifacts/interactive-preview/.vercel/output/static');
const base=process.env.ANUGA_DEMO_SITE??'http://127.0.0.1:3210';
if(!/^http:\/\/127\.0\.0\.1:3210$|^https:\/\/[^/]+\.vercel\.app\/?$/.test(base))throw Error('Only local or Vercel demo URLs permitted');
let server;
if(base.startsWith('http:')){
 const types={'.html':'text/html','.js':'text/javascript','.mjs':'text/javascript','.json':'application/json','.wasm':'application/wasm','.ttf':'font/ttf','.otf':'font/otf','.png':'image/png','.txt':'text/x-component'};
 server=createServer(async(req,res)=>{try{let file=resolve(root,'.'+decodeURIComponent(new URL(req.url,base).pathname));if(file!==root&&!file.startsWith(root+sep)){res.writeHead(403).end();return;}if((await stat(file)).isDirectory())file=resolve(file,'index.html');if(req.headers.rsc==='1'&&file.endsWith('index.html')){try{await stat(file.replace(/index.html$/,'index.txt'));file=file.replace(/index.html$/,'index.txt');}catch{}}
 res.writeHead(200,{'Content-Type':types[extname(file)]??'application/octet-stream','Cache-Control':'no-store'});res.end(await readFile(file));}catch{res.writeHead(404).end();}});
 await new Promise(r=>server.listen(3210,'127.0.0.1',r));
}
const browser=await chromium.launch({channel:'msedge',headless:true,...(process.env.ANUGA_DEMO_HTTP1?{args:['--disable-http2']}:{})});
const context=await browser.newContext({viewport:{width:1280,height:960},...(process.env.ANUGA_DEMO_STORAGE_STATE?{storageState:process.env.ANUGA_DEMO_STORAGE_STATE}:{}),...(process.env.VERCEL_AUTOMATION_BYPASS_SECRET?{extraHTTPHeaders:{'x-vercel-protection-bypass':process.env.VERCEL_AUTOMATION_BYPASS_SECRET}}:{})});
const forbidden=[],errors=[],results=[];let last;
await context.route('**/*',route=>{const u=new URL(route.request().url());if(u.hostname.endsWith('.supabase.co')){forbidden.push(u.origin);return route.abort();}return route.continue();});
async function open(app){const page=await context.newPage();last=page;page.on('pageerror',e=>errors.push(e.message));await page.goto(base+'/?screen='+encodeURIComponent(app==='ops'?'/ops/login/':`/${app}/`));await page.locator('iframe').waitFor({timeout:60000});if(await page.locator('#guide[open]').count())await page.getByRole('button',{name:'Close guide and test',exact:true}).click();const f=page.frameLocator('iframe');if(app!=='ops'){await f.locator('flutter-view').waitFor({timeout:180000});await f.locator('flt-semantics-placeholder').evaluate(e=>e.click());}return {page,f,app};}
async function enter(field,text){for(let i=0;i<3;i++){await field.click();await field.press('Control+A');await field.pressSequentially(text,{delay:40});if(await field.inputValue()===text)return;}await expect(field).toHaveValue(text);}
async function login(x,phone){await enter(x.f.getByRole('textbox').first(),phone);await x.f.getByRole('button',{name:'Send code',exact:true}).click();const code=x.app==='ops'?x.f.locator('#code'):x.f.getByRole('textbox',{name:'6-digit code',exact:true});await enter(code,'123456');await x.f.getByRole('button',{name:'Sign in',exact:true}).click();}
// Each caller waits for its real UI state; background asset requests may stay open.
async function snap(x,name){await x.page.waitForLoadState('domcontentloaded');await x.page.screenshot({path:output+'/'+name+'.png'});}
try{
 const family=await open('family');await enter(family.f.getByRole('textbox').first(),'123');await family.f.getByRole('button',{name:'Send code',exact:true}).click();await family.f.getByText('Enter a valid 10-digit mobile number.',{exact:true}).last().waitFor();results.push('phone validation');
 await login(family,'9000000101');await family.f.getByText('Lakshmi Rao (synthetic)',{exact:true}).last().waitFor();await snap(family,'family-home');results.push('simulated Family login and two-patient home');
 const ops=await open('ops');await login(ops,'9000000001');await ops.f.getByRole('heading',{name:'Trips board',exact:true}).waitFor();await ops.f.getByText('Lakshmi Rao (synthetic)',{exact:false}).first().waitFor();await snap(ops,'ops-trips');results.push('simulated Ops login/trips');
 const companion=await open('companion');await login(companion,'9000000201');await companion.f.getByRole('group',{name:/Lakshmi Rao/}).first().waitFor();await snap(companion,'companion-trips');results.push('simulated Companion login');
 // Click the actual Family visit and issue its separate pickup code.
 last=family.page;await family.page.bringToFront();await family.f.getByRole('button',{name:/Scheduled/}).first().click();await family.f.getByRole('button',{name:'Get pickup code',exact:true}).click();await family.f.getByText('Pickup code',{exact:true}).last().waitFor();await snap(family,'family-pickup');await family.f.getByRole('button',{name:'Close',exact:true}).click();results.push('Family issues simulated pickup code');
 last=companion.page;await companion.page.bringToFront();await companion.f.getByRole('group',{name:/Lakshmi Rao/}).first().click();await companion.f.getByRole('button',{name:"I'm on my way",exact:true}).click();
 const pickup=companion.f.getByRole('textbox');await enter(pickup.first(),'482913');await companion.f.getByRole('button',{name:'Verify code and pick up',exact:true}).click();await companion.f.getByRole('button',{name:'Reached the centre',exact:true}).waitFor();await snap(companion,'companion-picked-up');results.push('Companion journey and separate pickup-code validation');
 last=ops.page;await ops.page.bringToFront();await ops.f.getByRole('button',{name:'Refresh',exact:true}).click();await ops.f.getByRole('row').filter({hasText:'Picked up'}).first().waitFor();results.push('same changed visit appears in Ops');
 await family.page.reload();await family.f.locator('flutter-view').waitFor();await family.f.locator('flt-semantics-placeholder').evaluate(e=>e.click());await family.f.getByText(/Picked up/).last().waitFor();results.push('reload preserves role session and shared demo state');
 await family.page.screenshot({path:output+'/family-updated.png'});
 assert.deepEqual(forbidden,[]);assert.deepEqual(errors,[]);
 await writeFile(output+'/results.json',JSON.stringify({base,simulated:true,results,forbiddenHostedRequests:forbidden,pageErrors:errors},null,2));console.log(JSON.stringify({passed:results.length,forbiddenHostedRequests:forbidden,pageErrors:errors}));
}catch(e){if(last){await last.screenshot({path:output+'/failure.png'}).catch(()=>{});await writeFile(output+'/failure-semantics.json',JSON.stringify(await Promise.all(last.frames().map(f=>f.locator('flt-semantics').evaluateAll(es=>es.map(e=>({role:e.getAttribute('role'),label:e.getAttribute('aria-label'),text:e.textContent,rect:{x:e.getBoundingClientRect().x,y:e.getBoundingClientRect().y,w:e.getBoundingClientRect().width,h:e.getBoundingClientRect().height}}))).catch(()=>[]))),null,2));await writeFile(output+'/failure.txt',(await Promise.all(last.frames().map(f=>f.locator('body').innerText().catch(()=>'')))).join('\n\nFRAME\n')); }throw e;
}finally{await browser.close();if(server)await new Promise(r=>server.close(r));}
