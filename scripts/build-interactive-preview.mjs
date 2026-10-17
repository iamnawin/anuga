// Build the actual apps against an unreachable demo host; only its local SW responds.
import {spawnSync} from 'node:child_process';
import {mkdir,cp,readFile,writeFile,readdir} from 'node:fs/promises';
import {resolve,join} from 'node:path';
const root=process.cwd(),out=resolve('artifacts/interactive-preview/.vercel/output'),staticRoot=join(out,'static');
if(out!==join(root,'artifacts','interactive-preview','.vercel','output'))throw Error('Unexpected preview output');
await mkdir(staticRoot,{recursive:true});
const demoUrl='https://synthetic-anuga.invalid',demoKey='demo-public-key-not-valid-for-any-backend';
function run(cwd,command){const r=spawnSync(process.platform==='win32'?'cmd.exe':'bash',process.platform==='win32'?['/d','/c',command]:['-c',command],{cwd:resolve(cwd),env:{...process.env,NEXT_TELEMETRY_DISABLED:'1',OPS_STATIC_EXPORT:'1',OPS_BASE_PATH:'/ops',NEXT_PUBLIC_SUPABASE_URL:demoUrl,NEXT_PUBLIC_SUPABASE_ANON_KEY:demoKey},stdio:'inherit'});if(r.status!==0)throw Error('Preview build failed: '+command);}
run('apps/ops_console','pnpm exec next build');await cp('apps/ops_console/out',join(staticRoot,'ops'),{recursive:true});
for(const name of ['family','companion']){
 run('apps/'+name+'_app',`flutter build web --release --pwa-strategy=none --no-web-resources-cdn --base-href /${name}/ --dart-define=SUPABASE_URL=${demoUrl} --dart-define=SUPABASE_PUBLISHABLE_KEY=${demoKey}`);
 await cp(`apps/${name}_app/build/web`,join(staticRoot,name),{recursive:true});
}
await mkdir(join(staticRoot,'welcome'),{recursive:true});await cp('scripts/welcome.html',join(staticRoot,'welcome/index.html'));
for(const name of ['demo-core.mjs','demo-sw.mjs','index.html'])await cp(join('preview',name),join(staticRoot,name));
await cp('packages/shared_dart/test/fixtures/trip_contract.json',join(staticRoot,'demo-contract.json'));
// Keep all app routes within the labelled preview shell, including direct bookmarks.
async function label(folder){for(const e of await readdir(folder,{withFileTypes:true})){const p=join(folder,e.name);if(e.isDirectory())await label(p);else if(e.name.endsWith('.html')){let html=await readFile(p,'utf8');html=html.replace('<head>','<head><script>if(window.top===window.self)location.replace("/?screen="+encodeURIComponent(location.pathname+location.search));</script>');await writeFile(p,html);}}}
for(const name of ['ops','family','companion','welcome'])await label(join(staticRoot,name));
await writeFile(join(out,'config.json'),JSON.stringify({version:3,routes:[{src:'/(.*)',headers:{'X-Robots-Tag':'noindex, nofollow'},continue:true},{src:'^/(ops|family|companion|welcome)$',status:308,headers:{Location:'/$1/'}},{handle:'filesystem'}]},null,2));
console.log('Built isolated interactive preview; no real Supabase client settings are present.');
