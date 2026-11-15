'use client';

import {useState} from 'react';
import {useOpsApi} from './ApiProvider';
import {useI18n} from './I18nProvider';
import {ErrorMessage} from './ErrorMessage';
import type {CompanionOption, TripRow, VisitPlanRow} from '@/lib/api';
import {formatDateTime} from '@/lib/format';

// These are operational planning controls, not automatic ETA/clinical decisions.
const copy = {
  en:{open:'Plan outbound and return',queue:'Return pickup queue',load:'Refresh',close:'Close',start:'Outbound departure (IST)',end:'Outbound handover expected (IST)',returnStart:'Return departure reservation (IST)',returnEnd:'Home drop-off expected (IST)',ready:'Expected centre readiness (IST)',outbound:'Outbound companion',returning:'Return companion',save:'Reserve both assignments',stays:'Stay-and-assist: companion remains occupied',released:'Drop-off + return: gap may be used for Ops-approved work',note:'Centre staff confirmation (internal, no clinical notes)',confirm:'Centre confirms patient ready',code:'Issue separate return code',replace:'Replace unstarted return',reschedule:'Update return times',due:'Return departure due',late:'Arrival overdue — contact companion or arrange backup',help:'Include travel in every time block. No live location or ETA is inferred. Reserve return at least 30 minutes before readiness; target arrival is 15 minutes before.',select:'Choose eligible companion',saved:'Saved. Refresh to inspect current assignments.'},
  te:{open:'వెళ్లే, తిరుగు పనులను ప్లాన్ చేయండి',queue:'తిరుగు పికప్ జాబితా',load:'రిఫ్రెష్',close:'మూసివేయి',start:'ఇంటి పికప్‌కు బయలుదేరే సమయం (IST)',end:'కేంద్రంలో అప్పగించే అంచనా సమయం (IST)',returnStart:'తిరుగు ప్రయాణానికి బయలుదేరే సమయం (IST)',returnEnd:'ఇంటికి చేర్చే అంచనా సమయం (IST)',ready:'కేంద్రంలో సిద్ధమయ్యే అంచనా సమయం (IST)',outbound:'వెళ్లే ప్రయాణ సహచరుడు',returning:'తిరుగు సహచరుడు',save:'రెండు పనులను రిజర్వ్ చేయండి',stays:'రోగితో ఉండే సేవ: సహచరుడి పని కొనసాగుతుంది',released:'డ్రాప్, తిరుగు సేవ: మధ్య సమయాన్ని బృందం ఆమోదించిన పనికి వాడవచ్చు',note:'కేంద్ర సిబ్బంది నిర్ధారణ (అంతర్గతం, వైద్య గమనికలు వద్దు)',confirm:'రోగి సిద్ధమని కేంద్రం నిర్ధారించింది',code:'వేరే తిరుగు కోడ్ ఇవ్వండి',replace:'ప్రారంభించని తిరుగు పనిని మార్చండి',reschedule:'తిరుగు సమయాలను నవీకరించండి',due:'తిరుగు ప్రయాణ సమయం వచ్చింది',late:'రాక ఆలస్యం — సహచరుడిని సంప్రదించండి లేదా ప్రత్యామ్నాయం ఏర్పాటు చేయండి',help:'ప్రతి పనిలో ప్రయాణ సమయాన్ని చేర్చండి. ప్రత్యక్ష స్థానం లేదా అంచనా ప్రయాణ సమయం లేదు. సిద్ధమయ్యే సమయానికి కనీసం 30 నిమిషాల ముందు రిజర్వ్ చేయండి; 15 నిమిషాల ముందు చేరాలి.',select:'అర్హత ఉన్న సహచరుడిని ఎంచుకోండి',saved:'సేవ్ అయింది. ప్రస్తుత పనులను చూడటానికి రిఫ్రెష్ చేయండి.'},
  hi:{open:'जाने और वापसी के काम की योजना',queue:'वापसी पिकअप सूची',load:'रीफ़्रेश',close:'बंद करें',start:'घर पिकअप के लिए रवाना (IST)',end:'केंद्र में सौंपने का अनुमान (IST)',returnStart:'वापसी के लिए रवाना आरक्षण (IST)',returnEnd:'घर पहुँचाने का अनुमान (IST)',ready:'केंद्र में तैयार होने का अनुमान (IST)',outbound:'जाने वाला साथी',returning:'वापसी का साथी',save:'दोनों काम आरक्षित करें',stays:'साथ रहने की सेवा: साथी व्यस्त रहेगा',released:'ड्रॉप और वापसी: बीच में टीम का स्वीकृत काम हो सकता है',note:'केंद्र के कर्मचारियों की पुष्टि (आंतरिक, चिकित्सा नोट नहीं)',confirm:'केंद्र ने मरीज़ के तैयार होने की पुष्टि की',code:'अलग वापसी कोड दें',replace:'अभी शुरू नहीं हुई वापसी बदलें',reschedule:'वापसी का समय बदलें',due:'वापसी के लिए रवाना होने का समय',late:'पहुँचने में देर — साथी से संपर्क करें या बैकअप तय करें',help:'हर समय खंड में यात्रा समय जोड़ें। लाइव स्थान या यात्रा अनुमान नहीं है। तैयार होने से कम से कम 30 मिनट पहले आरक्षण और 15 मिनट पहले पहुँचने का लक्ष्य रखें।',select:'पात्र साथी चुनें',saved:'सहेजा गया। वर्तमान काम देखने के लिए रीफ़्रेश करें।'},
};

const iso = (value:string) => {
  const date=new Date(`${value}:00+05:30`);
  if(!Number.isFinite(date.getTime())) throw new Error('Invalid date/time');
  return date.toISOString();
};

export function VisitPlanTools({trip}:{trip:TripRow}) {
  const getApi=useOpsApi();const {lang}=useI18n();const l=copy[lang];
  const [open,setOpen]=useState(false);const [options,setOptions]=useState<CompanionOption[]>([]);
  const [outbound,setOutbound]=useState(trip.companion_id??'');const [returning,setReturning]=useState(trip.companion_id??'');
  const [busy,setBusy]=useState(false);const [error,setError]=useState<unknown>(null);const [saved,setSaved]=useState(false);
  if(trip.status!=='scheduled' || !trip.schedule_id) return null;
  if(!open) return <button type="button" className="btn" onClick={async()=>{
    setOpen(true);try{setOptions(await getApi().companionOptions(trip.patient_id));}catch(e){setError(e);}
  }}>{l.open}</button>;
  return <form className="card" onSubmit={async e=>{
    e.preventDefault();const form=new FormData(e.currentTarget);setBusy(true);setError(null);
    try{await getApi().planVisit(trip.trip_id,{outboundStart:iso(String(form.get('start'))),outboundEnd:iso(String(form.get('end'))),returnStart:iso(String(form.get('returnStart'))),returnEnd:iso(String(form.get('returnEnd')))},outbound,returning);setSaved(true);}
    catch(e){setError(e);}finally{setBusy(false);}
  }}>
    <p>{l.help}</p><ErrorMessage error={error}/>
    {saved?<p role="status">{l.saved}</p>:<fieldset disabled={busy}>
      {(['start','end','returnStart','returnEnd'] as const).map(key=><label className="field" key={key}>
        <span>{l[key]}</span><input name={key} type="datetime-local" required step="60"/></label>)}
      {(['outbound','returning'] as const).map(key=><label className="field" key={key}><span>{l[key]}</span>
        <select required value={key==='outbound'?outbound:returning} onChange={e=>key==='outbound'?setOutbound(e.target.value):setReturning(e.target.value)}>
          <option value="">{l.select}</option>{options.filter(o=>o.eligible).map(o=><option key={o.companion_id} value={o.companion_id}>{o.full_name}</option>)}
        </select></label>)}
      <button className="btn btn-primary" type="submit">{l.save}</button>
    </fieldset>}
    <button className="btn" type="button" onClick={()=>setOpen(false)}>{l.close}</button>
  </form>;
}

export function VisitReturnQueue() {
  const getApi=useOpsApi();const {lang}=useI18n();const l=copy[lang];
  const [rows,setRows]=useState<VisitPlanRow[]|null>(null);const [error,setError]=useState<unknown>(null);
  const load=async()=>{setError(null);try{setRows(await getApi().visitPlans());}catch(e){setRows(null);setError(e);}};
  return <section><button className="btn" type="button" onClick={()=>void load()}>{rows===null?l.queue:l.load}</button>
    <ErrorMessage error={error}/>{rows?.map(row=><ReturnCard key={`${row.trip_id}-${row.version}`} row={row} onDone={load}/>)}</section>;
}

function ReturnCard({row,onDone}:{row:VisitPlanRow;onDone:()=>Promise<void>}) {
  const api=useOpsApi();const {lang}=useI18n();const l=copy[lang];
  const [options,setOptions]=useState<CompanionOption[]>([]);const [replacement,setReplacement]=useState('');
  const [note,setNote]=useState('');const [code,setCode]=useState<string|null>(null);
  const [busy,setBusy]=useState(false);const [error,setError]=useState<unknown>(null);
  const run=async(action:()=>Promise<void>)=>{setBusy(true);setError(null);setCode(null);try{await action();await onDone();}catch(e){setError(e);}finally{setBusy(false);}};
  return <article className="card" data-return-trip-id={row.trip_id}>
    <h2>{row.patient_name} — {row.centre_name}</h2><p>{row.stays_through_session?l.stays:l.released}</p>
    <p>{l.returning}: {row.return_companion_name}</p><p>{l.ready}: {formatDateTime(row.expected_ready_at,lang)}</p>
    <p>{l.returnStart}: {formatDateTime(row.return_prepare_at,lang)}</p>
    {row.return_due&&<p role="status">{l.due}</p>}{row.return_late&&<p role="alert">{l.late}</p>}
    <ErrorMessage error={error}/><fieldset disabled={busy}>
      {row.status==='handed_over'&&<><label className="field"><span>{l.note}</span><textarea value={note} onChange={e=>setNote(e.target.value)}/></label>
        <button className="btn" disabled={!note.trim()} type="button" onClick={()=>void run(()=>api().confirmCentreReady(row.trip_id,row.version,note))}>{l.confirm}</button></>}
      {!row.stays_through_session&&!row.return_departed_at&&['handed_over','session_done'].includes(row.status)&&<>
        <button className="btn" type="button" onClick={async()=>{try{setOptions(await api().companionOptions(row.patient_id));}catch(e){setError(e);}}}>{l.replace}</button>
        {options.length>0&&<label className="field"><span>{l.returning}</span><select value={replacement} onChange={e=>setReplacement(e.target.value)}><option value="">{l.select}</option>{options.filter(o=>o.eligible).map(o=><option key={o.companion_id} value={o.companion_id}>{o.full_name}</option>)}</select></label>}
        {replacement&&<button className="btn" type="button" onClick={()=>void run(()=>api().reassignReturn(row.trip_id,row.version,replacement))}>{l.replace}</button>}
      </>}
      {row.status==='session_done'&&row.return_arrived_at&&<button className="btn" type="button" onClick={async()=>{
        setBusy(true);setError(null);try{setCode(await api().issueReturnCode(row.trip_id));}catch(e){setError(e);}finally{setBusy(false);}
      }}>{l.code}</button>}
      {!row.return_departed_at&&['scheduled','handed_over','session_done'].includes(row.status)&&<form onSubmit={e=>{
        e.preventDefault();const values=new FormData(e.currentTarget);void run(()=>api().rescheduleReturn(row.trip_id,row.version,iso(String(values.get('ready'))),iso(String(values.get('returnStart'))),iso(String(values.get('returnEnd')))));
      }}>{(['ready','returnStart','returnEnd'] as const).map(key=><label className="field" key={key}><span>{l[key]}</span><input required type="datetime-local" name={key}/></label>)}<button className="btn" type="submit">{l.reschedule}</button></form>}
    </fieldset>{code&&<output aria-label={l.code}>{code}</output>}
  </article>;
}
