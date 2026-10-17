// Synthetic simulator only. Never imported by production apps or connected to Supabase.
const uid = n => `90000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const iso = ms => new Date(ms).toISOString();
export const DEMO_HOST = 'synthetic-anuga.invalid';
export function seed(transitions = []) {
  const now = Date.now(), month = new Date().toISOString().slice(0, 7) + '-01';
  const accounts = [
    [1,'9000000001','ops_admin','Demo Ops'], [101,'9000000101','family','Demo Family owner'],
    [102,'9000000102','family','Demo viewer'], [103,'9000000103','family','Demo editor'],
    [104,'9000000104','family','Demo patient'], [201,'9000000201','companion','Asha (synthetic)'],
    [202,'9000000202','companion','Ravi (synthetic)'], [901,'9000000901','family','Demo empty account'],
    [902,'9000000902','family','Demo pending account'], [903,'9000000903','family','Demo disabled account'],
  ].map(([n,phone,role,name]) => ({id:uid(n),phone:'91'+phone,role,name,state:n===902?'pending':n===903?'disabled':'active'}));
  const trip = (n,time,status='scheduled') => ({id:uid(n),patient_id:uid(501),status,companion_id:uid(201),
    scheduled_pickup_at:iso(time),scheduled_return_at:iso(time+5*3600000),post_visit_note:null,
    updated_at:iso(now),fare_amount_paise:null,status_before_issue:null,schedule_id:uid(601),otp:null,attempts:0});
  return {version:1,accounts,transitions,patients:[{id:uid(501),name:'Lakshmi Rao (synthetic)'},{id:uid(502),name:'Second patient (synthetic)'}],
    grants:[{user:uid(101),patient:uid(501),level:'owner'},{user:uid(101),patient:uid(502),level:'owner'},
      {user:uid(102),patient:uid(501),level:'viewer'},{user:uid(103),patient:uid(501),level:'editor'},{user:uid(104),patient:uid(501),level:'patient'}],
    trips:[trip(701,now-20*60000),trip(702,now+86400000)],events:[],notifications:[],
    consents:{[uid(501)]:{trips:true,vault:true,ops_vault_access:false},[uid(502)]:{trips:true,vault:false,ops_vault_access:false}},
    invoices:[{invoice_id:uid(801),patient_id:uid(501),patient_name:'Lakshmi Rao (synthetic)',package_name:'Demo package (simulated amounts)',
      period_start:month,period_end:month.slice(0,7)+'-28',status:'issued',total_paise:35000,visits:1,fares_paise:0,issued_at:iso(now),paid_at:null}],
    docs:[],files:{},caps:{},primary:uid(201),backup:uid(202),scenario:'normal'};
}
const json = (data,status=200) => new Response(JSON.stringify(data),{status,headers:{'Content-Type':'application/json','Access-Control-Allow-Origin':'*'}});
const denied = () => { throw {code:'42501',message:'Simulated permission denied. No real action was taken.'}; };
const invalid = message => { throw {code:'22023',message}; };
const b64 = value => btoa(JSON.stringify(value)).replaceAll('+','-').replaceAll('/','_').replaceAll('=','');
const token = a => `${b64({alg:'HS256',typ:'JWT'})}.${b64({sub:a.id,role:'authenticated',aud:'authenticated',iss:'synthetic-demo',exp:Math.floor(Date.now()/1000)+3600,iat:Math.floor(Date.now()/1000)})}.demo-simulation-not-a-real-signature`;
function actor(state,request) {
  try {const part=request.headers.get('authorization').split(' ')[1].split('.')[1];return state.accounts.find(a=>a.id===JSON.parse(atob(part.replaceAll('-','+').replaceAll('_','/'))).sub); } catch {return null;}
}
function session(a) {
  return {access_token:token(a),token_type:'bearer',expires_in:3600,expires_at:Math.floor(Date.now()/1000)+3600,refresh_token:'demo-refresh:'+a.id,
    user:{id:a.id,aud:'authenticated',role:'authenticated',phone:a.phone,email:'',created_at:iso(Date.now()),phone_confirmed_at:iso(Date.now()),
      app_metadata:{provider:'phone',providers:['phone']},user_metadata:{full_name:a.name},is_anonymous:false,identities:[]}};
}
function level(s,a,pid) {return a?.role==='family'?s.grants.find(g=>g.user===a.id&&g.patient===pid)?.level:null;}
function patient(s,a,pid,edit=false) {const l=level(s,a,pid);if(!l||(edit&&!['owner','editor'].includes(l)))denied();return l;}
function ops(a) {if(a?.role!=='ops_admin')denied();}
function fileLink(s,id,mode,seconds) {const token=crypto.randomUUID();s.caps[token]={id,mode,expires:Date.now()+seconds*1000};return '/storage/v1/demo/'+id+'?cap='+token;}
function projection(s,t) {
  const {otp,attempts,...safe}=t;
  return {...safe,trip_id:t.id,patient_name:s.patients.find(p=>p.id===t.patient_id)?.name,centre_name:'Demo Dialysis Centre',cluster_id:uid(301),
    companion_name:s.accounts.find(a=>a.id===t.companion_id)?.name,primary_companion_id:s.primary,backup_companion_id:s.backup,
    primary_companion_name:s.accounts.find(a=>a.id===s.primary)?.name,backup_companion_name:s.accounts.find(a=>a.id===s.backup)?.name,is_late:false};
}
function event(s,t,to,a,note) {
  const from=t.status;t.status=to;t.updated_at=iso(Date.now());
  if(to==='issue_reported')t.status_before_issue=from;
  if(to==='completed')t.post_visit_note=note;
  const e={event_id:s.events.length+1,trip_id:t.id,from_status:from,to_status:to,actor_kind:a.role==='family'?'family':a.role==='ops_admin'?'ops':'companion',note,created_at:t.updated_at};
  s.events.push(e);s.notifications.push({notification_id:s.notifications.length+1,trip_id:t.id,template:'trip_status_changed',payload:{from_status:from,to_status:to,note},created_at:t.updated_at});
}
function rpc(s,a,fn,b) {
  if(!a)denied();
  if(fn==='my_account_access')return {state:a.state,role:a.state==='active'?a.role:null};
  if(a.state!=='active')throw {code:'42501',message:'account access required',hint:'account_access_required'};
  if(s.scenario==='lookup-error'&&fn==='family_my_patients'){s.scenario='normal';throw {code:'DEMO_RETRY',message:'Simulated connection failure. Refresh to retry.'};}
  const t=s.trips.find(t=>t.id===b.p_trip_id),pid=b.p_patient_id;
  switch(fn) {
    case 'family_my_patients':
      if(a.role!=='family')denied();
      return s.patients.filter(p=>level(s,a,p.id)).map(p=>({patient_id:p.id,full_name:p.name,centre_name:'Demo Dialysis Centre',access_level:level(s,a,p.id)}));
    case 'family_trip_board':patient(s,a,pid);return s.trips.filter(t=>t.patient_id===pid).map(t=>projection(s,t));
    case 'family_trip_timeline':if(!t)denied();patient(s,a,t.patient_id);return s.events.filter(e=>e.trip_id===t.id);
    case 'my_notifications':return a.role==='family'?s.notifications.filter(n=>{const tr=s.trips.find(t=>t.id===n.trip_id);return tr&&level(s,a,tr.patient_id);}):[];
    case 'companion_my_trips':
      if(a.role!=='companion')denied();
      return s.trips.filter(t=>t.companion_id===a.id).map(t=>({...projection(s,t),centre_address:'1 Demo Road (synthetic)',details_visible:t.id===uid(701),
        patient_name:t.id===uid(701)?s.patients.find(p=>p.id===t.patient_id)?.name:null,home_address:t.id===uid(701)?'22 Sample Colony (synthetic)':null,
        home_lat:t.id===uid(701)?17.495:null,home_lng:t.id===uid(701)?78.405:null,mobility_notes:t.id===uid(701)?'Synthetic assistance note':null,emergency_contacts:[]}));
    case 'issue_pickup_otp':
      if(!t||!['owner','editor','patient'].includes(level(s,a,t.patient_id)))denied();
      if(!['scheduled','companion_en_route'].includes(t.status))invalid('Simulated visit is not awaiting pickup.');
      t.otp='482913';t.attempts=0;return t.otp;
    case 'verify_pickup_otp':
      if(!t||a.role!=='companion'||t.companion_id!==a.id)denied();
      if(t.status!=='companion_en_route')invalid('Begin the simulated outward journey first.');
      if(!t.otp||t.attempts>=5)return {ok:false,reason:'no_valid_code',attempts_left:0};
      if(b.p_code!==t.otp){t.attempts++;return {ok:false,reason:'wrong_code',attempts_left:5-t.attempts};}
      t.otp=null;event(s,t,'picked_up',a,'Simulated pickup code verified');return {ok:true,status:t.status};
    case 'advance_trip': {
      if(!t)denied();
      const who=a.role==='ops_admin'?'ops':a.role==='family'?'family':'companion';
      if(who==='family')patient(s,a,t.patient_id,true);
      if(who==='companion'&&t.companion_id!==a.id)denied();
      const rule=s.transitions.find(x=>x.from===t.status&&x.to===b.p_to_status&&x.actor===who&&!x.requires_otp);
      if(!rule)invalid('This simulated visit step is not available.');
      if(b.p_to_status==='completed'&&!b.p_note?.trim())invalid('Enter a simulated post-visit note.');
      event(s,t,b.p_to_status,a,b.p_note??null);return projection(s,t);
    }
    case 'ops_trip_board':ops(a);return s.trips.filter(t=>(!b.p_statuses||b.p_statuses.includes(t.status))&&(!b.p_from||t.scheduled_pickup_at>=b.p_from)&&(!b.p_to||t.scheduled_pickup_at<=b.p_to)).map(t=>projection(s,t));
    case 'ops_schedule_board':ops(a);return [{schedule_id:uid(601),patient_id:uid(501),patient_name:s.patients[0].name,centre_name:'Demo Dialysis Centre',cluster_id:uid(301),package_name:'Demo package',days_of_week:[1,3,5],pickup_time:'07:00:00',timezone:'Asia/Kolkata',active:true,primary_companion_id:s.primary,backup_companion_id:s.backup,primary_companion_name:s.accounts.find(a=>a.id===s.primary)?.name,backup_companion_name:s.accounts.find(a=>a.id===s.backup)?.name,upcoming_trips:s.trips.filter(t=>t.status==='scheduled').length}];
    case 'ops_companion_options':ops(a);return s.accounts.filter(a=>a.role==='companion').map(a=>({companion_id:a.id,full_name:a.name,verification_status:'verified',active:true,distance_m:500,radius_m:5000,eligible:true,reason:null}));
    case 'ops_assign_schedule_companions':
      ops(a);if(b.p_primary_id&&b.p_primary_id===b.p_backup_id)invalid('Choose different simulated primary and backup companions.');
      if(![b.p_primary_id,b.p_backup_id].every(id=>id==null||s.accounts.some(a=>a.id===id&&a.role==='companion')))invalid('Choose listed demo companions.');
      s.primary=b.p_primary_id;s.backup=b.p_backup_id;return null;
    case 'ops_assign_trip_companion':
      ops(a);if(!t||t.status!=='scheduled')invalid('Only a scheduled demo visit can be reassigned.');
      if(!s.accounts.some(a=>a.id===b.p_companion_id&&a.role==='companion'))invalid('Choose a demo companion.');
      t.companion_id=b.p_companion_id;s.notifications.push({notification_id:s.notifications.length+1,trip_id:t.id,template:'companion_changed',payload:{},created_at:iso(Date.now())});return null;
    case 'ops_exception_queue':ops(a);return s.trips.filter(t=>['issue_reported','no_show'].includes(t.status)).map(t=>({...projection(s,t),kind:t.status,last_note:s.events.filter(e=>e.trip_id===t.id).at(-1)?.note,since:t.updated_at}));
    case 'ops_record_trip_fare':ops(a);if(!t||t.status!=='completed'||!Number.isInteger(b.p_fare_paise)||b.p_fare_paise<0)invalid('Enter a valid simulated fare for a completed visit.');t.fare_amount_paise=b.p_fare_paise;return null;
    case 'family_consents':patient(s,a,pid);return Object.entries(s.consents[pid]).map(([purpose,active])=>({purpose,active,can_change:level(s,a,pid)==='owner',granted_at:active?iso(Date.now()):null}));
    case 'set_consent':if(level(s,a,pid)!=='owner')denied();if(!Object.hasOwn(s.consents[pid],b.p_purpose))invalid('Unknown demo consent purpose.');s.consents[pid][b.p_purpose]=Boolean(b.p_active);return s.consents[pid][b.p_purpose];
    case 'vault_list_documents':patient(s,a,pid);if(!s.consents[pid].vault)denied();return s.docs.filter(d=>d.patient_id===pid);
    case 'family_invoices':patient(s,a,pid,true);return s.invoices.filter(i=>i.patient_id===pid).map(i=>({...i,can_pay:level(s,a,pid)==='owner'&&i.status==='issued'}));
    case 'family_invoice_lines': {const i=s.invoices.find(i=>i.invoice_id===b.p_invoice_id);if(!i)denied();patient(s,a,i.patient_id,true);return [{kind:'visit',amount_paise:i.total_paise,service_date:i.period_start}];}
    case 'ops_invoices':ops(a);return s.invoices;
    case 'ops_generate_invoice': {
      ops(a);const p=s.patients.find(p=>p.id===pid);if(!p||!/^\d{4}-\d{2}-01$/.test(b.p_month??''))invalid('Enter a listed synthetic patient UUID and a month.');
      const existing=s.invoices.find(i=>i.patient_id===pid&&i.period_start===b.p_month);if(existing)return existing.invoice_id;
      const trips=s.trips.filter(t=>t.patient_id===pid&&t.status==='completed'&&t.scheduled_pickup_at.slice(0,7)===b.p_month.slice(0,7));
      const fares=trips.reduce((sum,t)=>sum+(t.fare_amount_paise??0),0),id=crypto.randomUUID();
      s.invoices.push({invoice_id:id,patient_id:pid,patient_name:p.name,package_name:'Demo package (simulated amounts)',period_start:b.p_month,period_end:b.p_month.slice(0,7)+'-28',status:'draft',total_paise:trips.length*35000+fares,visits:trips.length,fares_paise:fares,issued_at:null,paid_at:null});return id;
    }
    case 'ops_issue_invoice':ops(a);{const i=s.invoices.find(i=>i.invoice_id===b.p_invoice_id);if(!i)invalid('Demo invoice not found.');if(i.status==='paid')invalid('The simulated invoice is already paid.');i.status='issued';return null;}
    default:throw {code:'DEMO_UNAVAILABLE',message:'This capability is unfinished and not available in this preview.'};
  }
}

export async function handle(s,request) {
  const url=new URL(request.url),p=url.pathname;
  try {
    if(request.method==='OPTIONS')return new Response(null,{status:204,headers:{'Access-Control-Allow-Origin':'*','Access-Control-Allow-Headers':'*','Access-Control-Allow-Methods':'GET,POST,PUT,OPTIONS'}});
    if(p.startsWith('/demo/')) {
      if(p==='/demo/reset'){const next=seed(s.transitions);for(const k of Object.keys(s))delete s[k];Object.assign(s,next);return json({simulated:true,reset:true});}
      if(p==='/demo/scenario') {const b=await request.json();if(!['normal','lookup-error','slow','revoke-viewer'].includes(b.scenario))invalid('Unknown demo scenario.');s.scenario=b.scenario;if(b.scenario==='revoke-viewer')s.grants=s.grants.filter(g=>g.user!==uid(102));return json({simulated:true,scenario:s.scenario});}
      return json({simulated:true,accounts:s.accounts.map(a=>({name:a.name,phone:a.phone.slice(2),role:a.role,state:a.state})),scenario:s.scenario});
    }
    if(p.startsWith('/auth/v1/')) {
      const b=request.method==='GET'?{}:await request.json();
      const a=s.accounts.find(a=>a.phone===String(b.phone??'').replace(/\D/g,''));
      if(p.endsWith('/otp')) {if(!a)return json({msg:'Simulated login only: choose a listed demo number.',error_code:'user_not_found'},422);return json({message_id:'simulated-no-sms'});}
      if(p.endsWith('/verify')) {if(!a||b.token!=='123456')return json({msg:'Simulated code is 123456. No SMS is sent.',error_code:'otp_expired'},403);return json(session(a));}
      if(p.endsWith('/token')) {const a=s.accounts.find(a=>'demo-refresh:'+a.id===b.refresh_token);return a?json(session(a)):json({msg:'Demo session expired',error_code:'refresh_token_not_found'},400);}
      if(p.endsWith('/logout'))return json({});
      if(p.endsWith('/user')) {const a=actor(s,request);return a?json(session(a).user):json({msg:'Demo sign-in required'},401);}
      return json({msg:'Registration and real account administration are unavailable in this demo.'},403);
    }
    const a=actor(s,request);
    if(p.startsWith('/rest/v1/rpc/'))return json(rpc(s,a,p.split('/').at(-1),await request.json()));
    if(p==='/rest/v1/profiles') {if(!a||a.state!=='active')denied();return json({full_name:a.name});}
    if(p==='/rest/v1/trip_transitions') {ops(a);return json(s.transitions.filter(x=>x.actor==='ops').map(x=>({from_status:x.from,to_status:x.to,actor:x.actor,requires_otp:x.requires_otp})));}
    if(p.startsWith('/functions/v1/')) {
      if(!a||a.state!=='active')throw {code:'42501',message:'account access required',hint:'account_access_required'};
      const b=await request.json();
      if(p.endsWith('/payments')) {
        const i=s.invoices.find(i=>i.invoice_id===b.invoice_id);if(!i||level(s,a,i.patient_id)!=='owner')denied();
        if(b.action==='complete-test'){if(i.status!=='issued')invalid('Simulated invoice is not due.');i.status='paid';i.paid_at=iso(Date.now());}
        return json({provider:'test',invoice_id:i.invoice_id,payment_id:'simulated-payment',simulated:true});
      }
      if(p.endsWith('/vault-files')) {
        let d=s.docs.find(d=>d.id===b.document_id);
        const pid=b.patient_id??d?.patient_id;patient(s,a,pid,b.action!=='download');if(!s.consents[pid]?.vault)denied();
        if(b.action==='upload'){if(!b.title?.trim()||b.size_bytes>10485760||!['image/png','image/jpeg','image/webp'].includes(b.content_type))invalid('Choose a synthetic image under 10MB and enter a title.');d={id:crypto.randomUUID(),patient_id:pid,doc_type:b.doc_type,title:b.title,status:'pending_upload',created_at:iso(Date.now()),content_type:b.content_type,size_bytes:b.size_bytes};s.docs.push(d);return json({document_id:d.id,upload_path:fileLink(s,d.id,'upload',7200)});}
        if(!d)denied();
        if(b.action==='confirm'){if(!s.files[d.id])invalid('Demo image is not yet stored in this browser.');d.status='uploaded';return json({document_id:d.id,status:d.status});}
        if(b.action==='download'){if(d.status!=='uploaded'||!s.files[d.id])invalid('Demo image is not ready.');return json({download_path:fileLink(s,d.id,'download',60),content_type:d.content_type,expires_in:60});}
      }
    }
    if(p.startsWith('/storage/v1/demo/')) {
      const id=p.split('/').at(-1),d=s.docs.find(d=>d.id===id);if(!d)denied();
      const cap=s.caps[url.searchParams.get('cap')];if(!cap||cap.id!==id||cap.expires<Date.now()||cap.mode!==(request.method==='PUT'?'upload':'download'))denied();
      if(request.method==='PUT'){s.files[id]=await request.arrayBuffer();return json({simulated:true});}
      if(!s.files[id])return json({message:'Demo image missing'},404);
      return new Response(s.files[id],{headers:{'Content-Type':d.content_type,'Access-Control-Allow-Origin':'*'}});
    }
    return json({code:'DEMO_UNAVAILABLE',message:'This capability is unfinished and unavailable in the demo.'},501);
  } catch(e) {
    return json({code:e.code??'DEMO_ERROR',message:e.message??'Demo request failed',error:e.code==='42501'?'not_allowed':'invalid',hint:e.hint},e.code==='42501'?403:400);
  }
}
