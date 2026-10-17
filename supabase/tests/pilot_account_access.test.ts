import assert from 'node:assert/strict';
import { before, test } from 'node:test';
import { asServiceRole, asUser, createTrip, expectPgError, getDb, ids, probeAsAnon, probeAsUser } from './support/db.ts';

const pending = '20000000-0000-0000-0000-00000000a001';
before(async () => {
  const db = await getDb();
  await db.query(`insert into auth.users(id,phone) values ($1,'919000008881')`, [pending]);
});

async function setState(id: string, state: string) {
  const db = await getDb();
  await db.query(`select private.configure_pilot_account(id, account_state_version, $2, null,
    'synthetic lifecycle test', 'synthetic:test-operator', 'synthetic:provisional-defaults')
    from public.profiles where id=$1`, [id, state]);
}

test('new Auth identity is pending; resolver is self-only and has no private fields', async () => {
  const rows = await asUser(pending, db => db.query('select public.my_account_access() as access'));
  assert.deepEqual(rows[0].access, { state: 'pending', role: null });
  await expectPgError(probeAsAnon(db => db.query('select public.my_account_access()')));
  assert.deepEqual(await asUser(pending, db => db.query('select * from public.profiles')), []);
});

test('active users including Ops and service cannot manage lifecycle or self-promote', async () => {
  for (const id of [pending, ids.owner, ids.asha, ids.ops]) {
    await expectPgError(probeAsUser(id, db => db.query(`update public.profiles set account_state='active' where id=$1`, [id])));
    await expectPgError(probeAsUser(id, db => db.query(`select private.configure_pilot_account($1,1,'active',null,'x','x','x')`, [id])));
  }
  await expectPgError(asServiceRole(db => db.query(`select private.configure_pilot_account($1,1,'active',null,'x','x','x')`, [pending])));
});

test('state changes audit atomically, reject stale versions, and do not create patient grants/consent', async () => {
  const db = await getDb();
  await setState(pending, 'active');
  assert.deepEqual((await asUser(pending, db => db.query('select public.my_account_access() as access')))[0].access,
    { state: 'active', role: 'family' });
  assert.equal((await db.query('select 1 from public.patient_access where user_id=$1', [pending])).length, 0);
  assert.equal((await db.query('select 1 from public.consents where user_id=$1', [pending])).length, 0);
  await expectPgError(db.query(`select private.configure_pilot_account($1,1,'disabled',null,'test','synthetic:operator','synthetic:authority')`, [pending]), '40001');
  const audit = await db.query(`select details from public.audit_log where record_id=$1 and action='account_access_changed'`, [pending]);
  assert.equal(audit.length, 1);
  assert.deepEqual(audit[0].details, {
    old_state: 'pending', new_state: 'active', old_role: 'family', new_role: 'family',
    version: 2, source: 'operator', reason: 'synthetic lifecycle test',
    operator_ref: 'synthetic:test-operator', authority_ref: 'synthetic:provisional-defaults',
    database_actor: 'postgres',
  });
  const beforeRetry = await db.query('select account_state,account_state_version from public.profiles where id=$1', [pending]);
  await setState(pending, 'active');
  assert.deepEqual(await db.query('select account_state,account_state_version from public.profiles where id=$1', [pending]), beforeRetry);
  assert.equal((await db.query(`select 1 from public.audit_log where record_id=$1 and action='account_access_changed'`, [pending])).length, 1);
  await setState(pending, 'disabled');
});

test('existing caller claims cannot read or mutate after disable, including direct-ID RPC paths', async () => {
  const trip = await createTrip(10);
  const db = await getDb();
  await setState(ids.asha, 'disabled');
  try {
    assert.deepEqual(await asUser(ids.asha, db => db.query('select id from public.trips')), []);
    assert.deepEqual((await asUser(ids.asha, db => db.query('select public.my_account_access() as access')))[0].access,
      { state: 'disabled', role: null });
    for (const sql of [
      'select public.my_notifications()',
      'select public.companion_my_trips()',
      `select public.advance_trip('${trip}','companion_en_route')`,
      `select public.verify_pickup_otp('${trip}','123456')`,
    ]) await expectPgError(probeAsUser(ids.asha, db => db.query(sql)));
  } finally { await setState(ids.asha, 'active'); }
});

test('reactivation never recreates revoked patient grants or withdrawn consent', async () => {
  const db = await getDb();
  await db.exec('begin');
  try {
    await db.query('delete from public.patient_access where user_id=$1', [ids.viewer]);
    await setState(ids.viewer, 'disabled');
    await setState(ids.viewer, 'active');
    assert.equal((await db.query('select 1 from public.patient_access where user_id=$1', [ids.viewer])).length, 0);
    await db.query(`update public.consents set withdrawn_at=now() where user_id=$1`, [ids.owner]);
    await setState(ids.owner, 'disabled');
    await setState(ids.owner, 'active');
    assert.equal((await db.query('select 1 from public.consents where user_id=$1 and withdrawn_at is null', [ids.owner])).length, 0);
  } finally { await db.exec('rollback'); }
});


test('catalog: every protected authenticated RPC rejects inactive callers before its argument validation', async () => {
  const db = await getDb();
  const functions = await db.query<{name: string; args: string}>(`select p.proname as name,
    coalesce((select string_agg('null::'||format_type(t,null),',') from unnest(p.proargtypes) t),'') as args
    from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public'
    and p.prosecdef and has_function_privilege('authenticated',p.oid,'execute') and p.proname<>'my_account_access'`);
  assert.ok(functions.length >= 20);
  for (const f of functions) {
    await expectPgError(probeAsUser(pending, db => db.query('select public.' + f.name + '(' + f.args + ')')));
  }
});

test('all granted RLS tables and own-profile edits are denied for inactive identities', async () => {
  const db = await getDb();
  const tables = await db.query<{name: string}>(`select c.relname as name from pg_class c join pg_namespace n on n.oid=c.relnamespace
    where n.nspname='public' and c.relkind='r' and c.relrowsecurity and has_table_privilege('authenticated',c.oid,'select')`);
  for (const t of tables) assert.deepEqual(await asUser(pending, db => db.query('select * from public.' + t.name)), []);
  assert.deepEqual(await asUser(pending, db => db.query(`update public.profiles set full_name='synthetic' where id=$1 returning id`, [pending])), []);
});

test('privileged direct role/state writes require audit context; service cannot forge management context', async () => {
  const db = await getDb();
  await expectPgError(db.query(`update public.profiles set account_state='active' where id=$1`, [pending]));
  await expectPgError(asServiceRole(async db => {
    await db.query(`select set_config('anuga.account_change_context',$1,true)`, [JSON.stringify({reason:'x',operator_ref:'x',authority_ref:'x'})]);
    return db.query(`update public.profiles set account_state='active' where id=$1`, [pending]);
  }));
  await expectPgError(db.query(`select private.configure_pilot_account(id,account_state_version,'active','ops_admin','x','synthetic:operator','synthetic:authority') from public.profiles where id=$1`,[ids.owner]));
});

test('disabled candidates are ineligible and inactive recipients are not newly claimed', async () => {
  const db = await getDb();
  await setState(ids.ravi,'disabled');
  await setState(ids.viewer,'disabled');
  try {
    await expectPgError(probeAsUser(ids.ops,db=>db.query(`select public.ops_assign_schedule_companions($1,$2,$3)`,[ids.schedule,ids.asha,ids.ravi])), 'P0001');
    const claimed = await asServiceRole(db=>db.query('select * from public.dispatch_claim_notifications(500)'));
    assert.ok(claimed.every(row=>row.recipient_id!==ids.viewer));
  } finally { await setState(ids.ravi,'active'); await setState(ids.viewer,'active'); }
});

test('audit insertion failure rolls back account state and version', async () => {
  const db = await getDb();
  const [before] = await db.query('select account_state,account_state_version from public.profiles where id=$1',[pending]);
  await db.exec(`create function private.fail_account_audit_test() returns trigger language plpgsql as $$ begin
    if new.action='account_access_changed' then raise exception 'synthetic audit unavailable'; end if; return new; end $$;
    create trigger fail_account_audit_test before insert on public.audit_log for each row execute function private.fail_account_audit_test();`);
  try { await expectPgError(setState(pending,'active'),'P0001'); }
  finally { await db.exec('drop trigger fail_account_audit_test on public.audit_log; drop function private.fail_account_audit_test()'); }
  const [after] = await db.query('select account_state,account_state_version from public.profiles where id=$1',[pending]);
  assert.deepEqual(after,before);
});


test('patient links never turn Companion/Ops into a Family owner or expose companion clinical data', async () => {
  const db=await getDb();
  for(const id of [ids.asha,ids.ops]) {
    const [{id:patient}]=await asUser(ids.owner,db=>db.query<{id:string}>(`select public.create_patient('Synthetic role boundary','Synthetic address',17.49,78.4,$1) as id`,[ids.centre]));
    await db.query('delete from public.patient_access where patient_id=$1',[patient]);
    await db.query(`insert into public.patient_access(patient_id,user_id,access_level) values($1,$2,'owner')`,[patient,id]);
    try {
      assert.deepEqual(await asUser(id,db=>db.query('select private.access_level_for($1) as level',[patient])),[{level:null}]);
      await expectPgError(probeAsUser(id,db=>db.query(`select public.set_consent($1,'vault',true)`,[patient])));
      if(id===ids.asha) {
        assert.deepEqual(await asUser(id,db=>db.query('select date_of_birth from public.patients where id=$1',[patient])),[]);
        await expectPgError(probeAsUser(id,db=>db.query('select public.vault_list_documents($1)',[patient])));
      }
    }finally{await db.query('delete from public.patients where id=$1',[patient]);}
  }
});
