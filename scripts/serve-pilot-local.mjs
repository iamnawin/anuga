// Serve only the already-built combined synthetic site on loopback. Never deploys.
import {createServer} from 'node:http';
import {readFile, stat} from 'node:fs/promises';
import {resolve, extname, sep} from 'node:path';
const root=resolve('artifacts/staging/.vercel/output/static');
await stat(resolve(root,'index.html'));
const types={'.html':'text/html; charset=utf-8','.js':'text/javascript','.json':'application/json','.wasm':'application/wasm','.css':'text/css','.png':'image/png','.svg':'image/svg+xml','.ttf':'font/ttf','.otf':'font/otf','.woff2':'font/woff2'};
createServer(async(req,res)=>{
  try {
    if(!['GET','HEAD'].includes(req.method)){res.writeHead(405).end();return;}
    let file=resolve(root,'.'+decodeURIComponent(new URL(req.url,'http://localhost').pathname));
    if(file!==root&&!file.startsWith(root+sep)){res.writeHead(403).end();return;}
    if((await stat(file)).isDirectory())file=resolve(file,'index.html');
    const content=await readFile(file);res.writeHead(200,{'Content-Type':types[extname(file)]??'application/octet-stream','Cache-Control':'no-store','X-Robots-Tag':'noindex, nofollow'});
    res.end(req.method==='HEAD'?undefined:content);
  }catch{res.writeHead(404).end('Not found');}
}).listen(3110,'127.0.0.1',()=>console.log('Synthetic combined site: http://127.0.0.1:3110/'));
