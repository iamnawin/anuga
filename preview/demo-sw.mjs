// Browser-local synthetic state. No proxy, hosted backend, credentials or server data.
import {seed,handle,DEMO_HOST} from './demo-core.mjs';
const contract=fetch('/demo-contract.json').then(r=>r.json());
let queue=Promise.resolve();
async function database() {return new Promise((resolve,reject)=>{const r=indexedDB.open('anuga-interactive-demo',1);r.onupgradeneeded=()=>r.result.createObjectStore('state');r.onsuccess=()=>resolve(r.result);r.onerror=()=>reject(r.error);});}
async function load(db) {return new Promise((resolve,reject)=>{const tx=db.transaction('state','readonly'),r=tx.objectStore('state').get('demo');r.onsuccess=()=>resolve(r.result);r.onerror=()=>reject(r.error);});}
async function save(db,state) {return new Promise((resolve,reject)=>{const tx=db.transaction('state','readwrite');tx.objectStore('state').put(state,'demo');tx.oncomplete=resolve;tx.onerror=()=>reject(tx.error);});}
self.addEventListener('install',()=>self.skipWaiting());
self.addEventListener('activate',e=>e.waitUntil(self.clients.claim()));
self.addEventListener('fetch',event=>{
  if(new URL(event.request.url).hostname!==DEMO_HOST)return;
  const task=queue.then(async()=>{const db=await database();try{const state=await load(db)??seed((await contract).transitions);
    if(state.scenario==='slow'&&new URL(event.request.url).pathname.includes('/rest/'))await new Promise(r=>setTimeout(r,2500));
    const response=await handle(state,event.request);await save(db,state);return response;
  }finally{db.close();}});
  queue=task.catch(()=>{});event.respondWith(task);
});
