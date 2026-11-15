import {describe, test} from 'node:test';
import assert from 'node:assert/strict';
import {asAdmin, asUser, asServiceRole, createTrip, createUser, expectPgError, ids} from './support/db.ts';
import {randomUUID} from 'node:crypto';
import {connectActor,waitForLock} from './support/scheduling_concurrent.ts';

async function companion() {
  const id=await createUser(randomUUID(),'companion');
  await asAdmin(db=>db.query("update public.profiles set full_name='Synthetic Relief Companion' where id=$1",[id]));
  await asAdmin(db=>db.query(`insert into public.companions
    (id,cluster_id,home_location,verification_status,training_completed)
    select $1,cluster_id,home_location,verification_status,training_completed from public.companions where id=$2`,[id,ids.ravi]));
  return id;
}

const plan = async (trip: string, id: string) => asUser(ids.ops, db => db.query<{plan: Record<string, unknown>}>(
  `select public.ops_plan_visit($1,now()-interval '30 minutes',now()+interval '45 minutes',
    now()+interval '210 minutes',now()+interval '360 minutes',$2,$2) as plan`, [trip, id]));

async function setup(stays=false) {
  const id=await companion();const trip=await createTrip(20,null);
  const schedule=randomUUID();
  await asAdmin(db=>db.query(`insert into public.schedules(id,patient_id,package_id,days_of_week,pickup_time)
    select $1,patient_id,$2,days_of_week,pickup_time from public.schedules where id=$3`,
    [schedule,stays?'60000000-0000-0000-0000-000000000002':ids.basicPackage,ids.schedule]));
  await asAdmin(db=>db.query('update public.trips set schedule_id=$2 where id=$1',[trip,schedule]));
  await plan(trip,id);return {trip,id};
}
async function handover(trip:string,id:string) {
  await asUser(id,db=>db.query("select public.advance_trip($1,'companion_en_route')",[trip]));
  const [otp]=await asUser(ids.owner,db=>db.query<{code:string}>('select public.issue_pickup_otp($1) as code',[trip]));
  const [picked]=await asUser(id,db=>db.query<{result:{ok:boolean}}>('select public.verify_pickup_otp($1,$2) as result',[trip,otp.code]));
  assert.equal(picked.result.ok,true);
  await asUser(id,db=>db.query("select public.advance_trip($1,'at_centre')",[trip]));
  await expectPgError(asUser(id,db=>db.query('select public.companion_confirm_centre_handover($1,false)',[trip])),'22023');
  await asUser(id,db=>db.query("select public.companion_confirm_centre_handover($1,true,'Staff received patient (synthetic)')",[trip]));
}
const getPlan=(trip:string)=>asUser(ids.ops,db=>db.query<{p:Record<string,unknown>}>(
  'select to_jsonb(p) as p from jsonb_to_recordset(public.ops_visit_plans()) as p(trip_id uuid,version uuid) where trip_id=$1',[trip]));

async function readyForReturn(trip:string,id:string) {
  await handover(trip,id);
  await asAdmin(db=>db.query(`update public.visit_plans set outbound_start_at=now()-interval '150 minutes',
    outbound_end_at=now()-interval '60 minutes',return_prepare_at=now()-interval '1 minute',
    return_arrive_by=now()+interval '14 minutes',expected_ready_at=now()+interval '29 minutes',return_end_at=now()+interval '90 minutes' where trip_id=$1`,[trip]));
  const [{p}]=await getPlan(trip);
  await asUser(ids.ops,db=>db.query("select public.ops_confirm_centre_ready($1,$2,'Centre staff confirmed (synthetic)')",[trip,p.version]));
  await asUser(id,db=>db.query("select public.companion_return_action($1,'depart')",[trip]));
  await asUser(id,db=>db.query("select public.companion_return_action($1,'arrive')",[trip]));
}

describe('service-aware visit assignments', () => {
  test('Ops creates distinct reservations using the package attendance flag', async () => {
    const trip=await createTrip(20,null);
    const id=await companion();
    await asAdmin(db=>db.query('update public.trips set schedule_id=$2 where id=$1',[trip,ids.schedule]));
    const [result]=await plan(trip,id);
    assert.equal(result.plan.stays_through_session,false);
    assert.equal(result.plan.outbound_companion_id,id);
    assert.equal(result.plan.return_companion_id,id);
    assert.ok(result.plan.return_prepare_at);
    assert.ok(result.plan.return_arrive_by);
    for(const user of [ids.owner,ids.viewer,ids.asha]) {
      await expectPgError(asUser(user,db=>db.query(`select public.ops_plan_visit($1,now(),now()+interval '1 hour',
        now()+interval '3 hours',now()+interval '6 hours',$2,$2)`,[trip,ids.ravi])), '42501');
    }
  });

  test('legacy clients cannot read or bypass an opted-in visit', async () => {
    const trip=await createTrip(20,null);
    const id=await companion();
    await asAdmin(db=>db.query('update public.trips set schedule_id=$2 where id=$1',[trip,ids.schedule]));
    await plan(trip,id);
    const legacy=await asUser(id,db=>db.query('select * from public.companion_my_trips()'));
    assert.ok(!legacy.some(t=>t.trip_id===trip));
    const direct=await asUser(id,db=>db.query('select * from public.trips where id=$1',[trip]));
    assert.equal(direct.length,0);
    await expectPgError(asUser(id,db=>db.query("select public.advance_trip($1,'session_done')",[trip])),'22023');
  });

  test('Basic handover releases work in the gap but preserves the return reservation', async()=>{
    const {trip,id}=await setup();await handover(trip,id);
    const fitting=await createTrip(50,null);
    await asAdmin(db=>db.query('update public.trips set scheduled_return_at=scheduled_pickup_at+interval \'1 hour\' where id=$1',[fitting]));
    await asUser(ids.ops,db=>db.query('select public.ops_assign_trip_companion($1,$2)',[fitting,id]));
    assert.equal((await asUser(id,db=>db.query("select public.advance_trip($1,'companion_en_route') as t",[fitting]))).length,1);
    const overlap=await createTrip(220,null);
    await expectPgError(asUser(ids.ops,db=>db.query('select public.ops_assign_trip_companion($1,$2)',[overlap,id])),'22023');
    await expectPgError(asUser(id,db=>db.query("select public.advance_trip($1,'session_done')",[trip])),'22023');
  });

  test('stay-assist remains occupied after handover and cannot replace its return', async()=>{
    const {trip,id}=await setup(true);await handover(trip,id);
    const fitting=await createTrip(50,null);
    await asAdmin(db=>db.query("update public.trips set scheduled_return_at=scheduled_pickup_at+interval '1 hour' where id=$1",[fitting]));
    await expectPgError(asUser(ids.ops,db=>db.query('select public.ops_assign_trip_companion($1,$2)',[fitting,id])),'22023');
    const [{p}]=await getPlan(trip);const other=await companion();
    await expectPgError(asUser(ids.ops,db=>db.query('select public.ops_reassign_visit_return($1,$2,$3)',[trip,p.version,other])),'22023');
  });

  test('Ops replacement revokes original access, requires readiness/arrival, and distinct one-use return code',async()=>{
    const {trip,id}=await setup();await handover(trip,id);const other=await companion();
    const [{p}]=await getPlan(trip);
    await asUser(ids.ops,db=>db.query('select public.ops_reassign_visit_return($1,$2,$3)',[trip,p.version,other]));
    await expectPgError(asUser(ids.ops,db=>db.query('select public.ops_reassign_visit_return($1,$2,$3)',[trip,p.version,id])),'22023');
    await expectPgError(asUser(id,db=>db.query("select public.companion_return_action($1,'depart')",[trip])),'42501');
    await expectPgError(asUser(ids.ops,db=>db.query('select public.ops_issue_return_code($1)',[trip])),'22023');
    const [mine]=await asUser(id,db=>db.query<{rows:{trip_id:string;details_visible:boolean;can_return:boolean;home_address:string|null}[]}>('select public.companion_visit_board() as rows'));
    const released=mine.rows.find(t=>t.trip_id===trip)!;
    assert.equal(released.details_visible,false);assert.equal(released.can_return,false);assert.equal(released.home_address,null);
    assert.equal((await asUser(other,db=>db.query('select * from public.trips where id=$1',[trip]))).length,0);
    await asAdmin(db=>db.query(`update public.visit_plans set outbound_start_at=now()-interval '150 minutes',
      outbound_end_at=now()-interval '60 minutes',return_prepare_at=now()-interval '1 minute',
      return_arrive_by=now()+interval '14 minutes',expected_ready_at=now()+interval '29 minutes',return_end_at=now()+interval '90 minutes' where trip_id=$1`,[trip]));
    const [{p:readyPlan}]=await getPlan(trip);
    await asUser(ids.ops,db=>db.query("select public.ops_confirm_centre_ready($1,$2,'Centre staff called, ready (synthetic)')",[trip,readyPlan.version]));
    await asUser(other,db=>db.query("select public.companion_return_action($1,'depart')",[trip]));
    await asUser(other,db=>db.query("select public.companion_return_action($1,'arrive')",[trip]));
    const [{code}]=await asUser(ids.ops,db=>db.query<{code:string}>('select public.ops_issue_return_code($1) as code',[trip]));
    const [wrong]=await asUser(other,db=>db.query<{r:{ok:boolean}}>('select public.verify_return_pickup($1,$2) as r',[trip,code==='000000'?'111111':'000000']));
    assert.equal(wrong.r.ok,false);
    const [correct]=await asUser(other,db=>db.query<{r:{ok:boolean;status:string}}>('select public.verify_return_pickup($1,$2) as r',[trip,code]));
    assert.equal(correct.r.ok,true);assert.equal(correct.r.status,'returning');
    await expectPgError(asUser(other,db=>db.query('select public.verify_return_pickup($1,$2)',[trip,code])),'22023');
    await expectPgError(asUser(id,db=>db.query("select public.advance_trip($1,'dropped_home')",[trip])),'42501');
    await asUser(other,db=>db.query("select public.advance_trip($1,'dropped_home')",[trip]));
    await asUser(other,db=>db.query("select public.advance_trip($1,'completed','Synthetic return completed')",[trip]));
    const [visible]=await asUser(ids.owner,db=>db.query<{p:{return_companion_name:string}}>('select public.family_visit_plan($1) as p',[trip]));
    assert.ok(visible.p.return_companion_name);
  });

  test('direct service-role writes cannot bypass a planned status or assignee',async()=>{
    const {trip}=await setup();
    await expectPgError(asServiceRole(db=>db.query("update public.trips set status='completed' where id=$1",[trip])),'42501');
    await expectPgError(asServiceRole(db=>db.query('update public.trips set companion_id=$2 where id=$1',[trip,ids.asha])),'22023');
    await expectPgError(asUser(ids.owner,db=>db.query('select * from public.visit_plans where trip_id=$1',[trip])),'42501');
  });

  test('return rescheduling is Ops-only, versioned and rejects a conflicting reservation',async()=>{
    const {trip,id}=await setup();await handover(trip,id);const [{p}]=await getPlan(trip);
    const args=[trip,p.version];
    const sql=`select public.ops_reschedule_visit_return($1,$2,now()+interval '400 minutes',now()+interval '360 minutes',now()+interval '450 minutes')`;
    for(const user of [ids.owner,ids.viewer,id]) await expectPgError(asUser(user,db=>db.query(sql,args)),'42501');
    const conflict=await createTrip(380,null);
    await asUser(ids.ops,db=>db.query('select public.ops_assign_trip_companion($1,$2)',[conflict,id]));
    await expectPgError(asUser(ids.ops,db=>db.query(sql,args)),'22023');
    const [{p:unchanged}]=await getPlan(trip);assert.equal(unchanged.version,p.version);
    await asUser(ids.ops,db=>db.query(`select public.ops_reschedule_visit_return($1,$2,
      now()+interval '1000 minutes',now()+interval '960 minutes',now()+interval '1100 minutes')`,args));
    await expectPgError(asUser(ids.ops,db=>db.query(sql,args)),'22023');
  });

  test('return reminders are durable, hidden until due, and replaced with the current assignee',async()=>{
    const {trip,id}=await setup();
    const notifications=()=>asAdmin(db=>db.query<{recipient_id:string;next_attempt_at:string}>(
      "select recipient_id,next_attempt_at from public.notifications where trip_id=$1 and template='visit_return_reminder' and status='pending'",[trip]));
    assert.equal((await notifications()).length,1);
    const inbox=await asUser(id,db=>db.query('select * from public.my_notifications()'));
    assert.ok(!inbox.some(n=>n.trip_id===trip && n.template==='visit_return_reminder'));
    await handover(trip,id);const other=await companion();const [{p}]=await getPlan(trip);
    await asUser(ids.ops,db=>db.query('select public.ops_reassign_visit_return($1,$2,$3)',[trip,p.version,other]));
    const reminders=await notifications();assert.equal(reminders.length,1);assert.equal(reminders[0].recipient_id,other);
    await asUser(ids.ops,db=>db.query("select public.advance_trip($1,'cancelled','Synthetic cancellation')",[trip]));
    assert.equal((await notifications()).length,0);
  });

  test('consent withdrawal prevents planned reads/actions with an existing identity',async()=>{
    const {trip,id}=await setup();await handover(trip,id);
    await asUser(ids.owner,db=>db.query("select public.set_consent($1,'trips',false)",[ids.patient]));
    try{
      const [{rows}]=await asUser(id,db=>db.query<{rows:{trip_id:string;details_visible:boolean;home_address:string|null}[]}>('select public.companion_visit_board() as rows'));
      const row=rows.find(t=>t.trip_id===trip)!;assert.equal(row.details_visible,false);assert.equal(row.home_address,null);
      await expectPgError(asUser(id,db=>db.query("select public.companion_return_action($1,'depart')",[trip])),'42501');
      const [{p}]=await getPlan(trip);
      await expectPgError(asUser(ids.ops,db=>db.query("select public.ops_confirm_centre_ready($1,$2,'Synthetic confirmation')",[trip,p.version])),'42501');
    }finally{await asUser(ids.owner,db=>db.query("select public.set_consent($1,'trips',true)",[ids.patient]));}
  });

  test('return OTP enforces issuer, lockout, expiry and reissue without exposing the stored secret',async()=>{
    const {trip,id}=await setup();await readyForReturn(trip,id);
    for(const user of [ids.owner,ids.viewer,id]) await expectPgError(asUser(user,db=>db.query('select public.ops_issue_return_code($1)',[trip])),'42501');
    const [{code}]=await asUser(ids.ops,db=>db.query<{code:string}>('select public.ops_issue_return_code($1) as code',[trip]));
    await expectPgError(asUser(id,db=>db.query('select * from private.return_pickup_otps where trip_id=$1',[trip])),'42501');
    const [{max}]=await asAdmin(db=>db.query<{max:number}>("select private.setting_int('pickup_otp_max_attempts') as max"));
    for(let attempt=0;attempt<max;attempt++) {
      const [{r}]=await asUser(id,db=>db.query<{r:{ok:boolean;attempts_left:number}}>('select public.verify_return_pickup($1,$2) as r',[trip,code==='000000'?'111111':'000000']));
      assert.equal(r.ok,false);assert.equal(r.attempts_left,max-attempt-1);
    }
    const [{locked}]=await asUser(id,db=>db.query<{locked:{ok:boolean}}>('select public.verify_return_pickup($1,$2) as locked',[trip,code]));
    assert.equal(locked.ok,false);
    const [{code:fresh}]=await asUser(ids.ops,db=>db.query<{code:string}>('select public.ops_issue_return_code($1) as code',[trip]));
    await asAdmin(db=>db.query("update private.return_pickup_otps set expires_at=now()-interval '1 second' where trip_id=$1",[trip]));
    const [{expired}]=await asUser(id,db=>db.query<{expired:{ok:boolean}}>('select public.verify_return_pickup($1,$2) as expired',[trip,fresh]));
    assert.equal(expired.ok,false);
  });

  test('a missed return continues to block new jobs until Ops replans it',async()=>{
    const {trip,id}=await setup();await handover(trip,id);
    await asAdmin(db=>db.query(`update public.visit_plans set outbound_start_at=now()-interval '8 hours',
      outbound_end_at=now()-interval '7 hours',handed_over_at=now()-interval '5 hours',
      return_prepare_at=now()-interval '3 hours',return_arrive_by=now()-interval '2 hours',
      expected_ready_at=now()-interval '1 hour',return_end_at=now()-interval '30 minutes' where trip_id=$1`,[trip]));
    const next=await createTrip(10,null);
    await expectPgError(asUser(ids.ops,db=>db.query('select public.ops_assign_trip_companion($1,$2)',[next,id])),'22023');
    await expectPgError(asUser(id,db=>db.query("select public.companion_return_action($1,'depart')",[trip])),'22023');
    const [{p}]=await getPlan(trip);
    await asUser(ids.ops,db=>db.query(`select public.ops_reschedule_visit_return($1,$2,
      now()+interval '31 minutes',now(),now()+interval '90 minutes')`,[trip,p.version]));
    await asUser(id,db=>db.query("select public.companion_return_action($1,'depart')",[trip]));
  });

  test('concurrent planned assignments serialize on the companion reservation', {skip:!process.env.DATABASE_URL},async()=>{
    const id=await companion();const first=await createTrip(20,null);const second=await createTrip(21,null);
    await asAdmin(db=>db.query('update public.trips set schedule_id=$1 where id=any($2::uuid[])',[ids.schedule,[first,second]]));
    const a=await connectActor(ids.ops);const b=await connectActor(ids.ops);
    const sql=`select public.ops_plan_visit($1,now()-interval '30 minutes',now()+interval '45 minutes',now()+interval '210 minutes',now()+interval '360 minutes',$2,$2)`;
    try{
      await a.query(sql,[first,id]);
      const {rows:[{pid}]}=await b.query('select pg_backend_pid() as pid');
      const losing=expectPgError(b.query(sql,[second,id]),'22023');void losing.catch(()=>{});
      await waitForLock(a,pid);await a.query('commit');await losing;
    }finally{await a.query('rollback');await b.query('rollback');await a.end();await b.end();}
    const [row]=await asAdmin(db=>db.query<{count:number}>('select count(*)::integer as count from public.visit_plans where trip_id=$1',[second]));
    assert.equal(row.count,0);
  });
});
