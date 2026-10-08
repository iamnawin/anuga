// Payments in test mode (migration 0900): fares, invoices, bills and payment
// state, with allowed and denied cases. Uses fixed past months so other test
// files' trips (created around now) never land on these invoices.
import { describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { asAdmin, asServiceRole, asUser, createUser, expectPgError, ids, probeAsAnon, probeAsUser } from './support/db.ts';

const BASIC_VISIT = 40000; // seed package 'basic': ₹400 per visit, no monthly fee

// A completed (or other status) trip for the seed patient at an exact instant.
async function pastTrip(pickupUtc: string, status = 'completed', farePaise: number | null = null): Promise<string> {
  return asAdmin(async (db) => {
    const [row] = await db.query<{ id: string }>(
      `insert into public.trips (patient_id, centre_id, companion_id, scheduled_pickup_at, scheduled_return_at, status, fare_amount_paise)
       values ($1, $2, $3, $4::timestamptz, $4::timestamptz + interval '5 hours', $5::public.trip_status, $6) returning id`,
      [ids.patient, ids.centre, ids.asha, pickupUtc, status, farePaise]);
    return row.id;
  });
}

const generate = (user: string, month: string, patient: string = ids.patient) =>
  asUser(user, (db) => db.query<{ id: string }>('select public.ops_generate_invoice($1, $2::date) as id', [patient, month]))
    .then(([r]) => r.id);

async function lines(invoiceId: string) {
  return asAdmin((db) => db.query<{ kind: string; service_date: string; amount_paise: number }>(
    `select kind, to_char(service_date, 'YYYY-MM-DD') as service_date, amount_paise
     from public.invoice_lines where invoice_id = $1 order by service_date, kind`, [invoiceId]));
}

async function invoice(id: string) {
  const [row] = await asAdmin((db) => db.query<{ status: string; total_paise: number }>(
    'select status, total_paise from public.invoices where id = $1', [id]));
  return row;
}

describe('trip fares', () => {
  test('ops records the actual fare; family and companions cannot', async () => {
    const trip = await pastTrip('2024-11-05T01:30:00Z');
    await asUser(ids.ops, (db) => db.query('select public.ops_record_trip_fare($1, 18000)', [trip]));
    const [{ fare_amount_paise }] = await asAdmin((db) => db.query<{ fare_amount_paise: number }>(
      'select fare_amount_paise from public.trips where id = $1', [trip]));
    assert.equal(fare_amount_paise, 18000);
    for (const user of [ids.owner, ids.asha]) {
      await expectPgError(probeAsUser(user, (db) => db.query('select public.ops_record_trip_fare($1, 1)', [trip])));
    }
    await expectPgError(probeAsUser(ids.ops, (db) => db.query('select public.ops_record_trip_fare($1, -5)', [trip])), '22023');
  });
});

describe('invoices', () => {
  test('one line per completed visit at the package price, plus fares; India-time month boundaries', async () => {
    const jan1 = await pastTrip('2024-12-31T19:00:00Z');              // 1 Jan 00:30 IST -> January
    const jan10 = await pastTrip('2025-01-10T01:30:00Z', 'completed', 15000);
    await pastTrip('2025-01-12T01:30:00Z', 'cancelled');               // not billed
    await pastTrip('2025-01-14T01:30:00Z', 'no_show');                 // not billed by default (setting)
    await pastTrip('2025-01-31T19:00:00Z');                            // 1 Feb 00:30 IST -> February
    const id = await generate(ids.ops, '2025-01-20');
    assert.deepEqual(await lines(id), [
      { kind: 'visit', service_date: '2025-01-01', amount_paise: BASIC_VISIT },
      { kind: 'visit', service_date: '2025-01-10', amount_paise: BASIC_VISIT },
      { kind: 'fare', service_date: '2025-01-10', amount_paise: 15000 },
    ]);
    assert.deepEqual(await invoice(id), { status: 'draft', total_paise: 2 * BASIC_VISIT + 15000 });
    assert.ok(jan1 && jan10);

    // Regenerating a draft picks up a new fare and does not duplicate lines.
    await asUser(ids.ops, (db) => db.query('select public.ops_record_trip_fare($1, 9000)', [jan1]));
    assert.equal(await generate(ids.ops, '2025-01-01'), id);
    assert.equal((await lines(id)).length, 4);
    assert.equal((await invoice(id)).total_paise, 2 * BASIC_VISIT + 15000 + 9000);
  });

  test('only ops can generate, issue or list invoices', async () => {
    for (const user of [ids.owner, ids.viewer, ids.asha]) {
      await expectPgError(probeAsUser(user, (db) => db.query(`select public.ops_generate_invoice($1, '2025-02-01')`, [ids.patient])));
      await expectPgError(probeAsUser(user, (db) => db.query('select * from public.ops_invoices()')));
    }
    await expectPgError(probeAsAnon((db) => db.query('select * from public.ops_invoices()')));
  });

  test('an empty invoice cannot be issued; an issued one cannot be rebuilt and freezes its fares', async () => {
    const empty = await generate(ids.ops, '2024-06-01');
    await expectPgError(asUser(ids.ops, (db) => db.query('select public.ops_issue_invoice($1)', [empty])), '22023');

    const trip = await pastTrip('2024-07-03T01:30:00Z', 'completed', 12000);
    const id = await generate(ids.ops, '2024-07-01');
    await asUser(ids.ops, (db) => db.query('select public.ops_issue_invoice($1)', [id]));
    assert.equal((await invoice(id)).status, 'issued');
    await expectPgError(asUser(ids.ops, (db) => db.query(`select public.ops_generate_invoice($1, '2024-07-01')`, [ids.patient])), '22023');
    await expectPgError(asUser(ids.ops, (db) => db.query('select public.ops_record_trip_fare($1, 1)', [trip])), '22023');
    const notices = await asAdmin((db) => db.query<{ recipient_id: string; payload: { total_paise: number } }>(
      `select recipient_id, payload from public.notifications where template = 'invoice_issued' and payload ->> 'invoice_id' = $1`, [id]));
    assert.deepEqual(notices.map((n) => [n.recipient_id, n.payload.total_paise]), [[ids.owner, BASIC_VISIT + 12000]]);
  });

  test('the monthly fee comes from the package', async () => {
    // A separate synthetic patient on the Family Care package (monthly fee 99900).
    const owner2 = await createUser('20000000-0000-0000-0000-0000000000c1');
    const patient2 = await asAdmin(async (db) => {
      const [p] = await db.query<{ id: string }>(
        `insert into public.patients (full_name, home_address, home_location, centre_id)
         values ('Second Patient (synthetic)', 'Addr (synthetic)', extensions.st_setsrid(extensions.st_makepoint(78.405, 17.495), 4326)::extensions.geography, $1)
         returning id`, [ids.centre]);
      await db.query(`insert into public.patient_access (patient_id, user_id, access_level) values ($1, $2, 'owner')`, [p.id, owner2]);
      await db.query(
        `insert into public.schedules (patient_id, package_id, days_of_week, pickup_time)
         values ($1, '60000000-0000-0000-0000-000000000003', '{2,4,6}', '08:00')`, [p.id]);
      return p.id;
    });
    const id = await generate(ids.ops, '2024-09-01', patient2);
    assert.deepEqual(await lines(id), [{ kind: 'monthly_fee', service_date: '2024-09-01', amount_paise: 99900 }]);
    // Bills are visible to that patient's owner only.
    await asUser(ids.ops, (db) => db.query('select public.ops_issue_invoice($1)', [id]));
    assert.equal((await probeAsUser(owner2, (db) => db.query('select * from public.family_invoices($1)', [patient2]))).length, 1);
    await expectPgError(probeAsUser(ids.owner, (db) => db.query('select * from public.family_invoices($1)', [patient2])));
  });
});

describe('family bills and payments', () => {
  let invoiceId = '';

  test('owner sees issued bills with lines; drafts are hidden; viewers and companions are refused', async () => {
    await pastTrip('2024-03-04T01:30:00Z', 'completed', 20000);
    invoiceId = await generate(ids.ops, '2024-03-01');
    const draftVisible = await probeAsUser(ids.owner, (db) => db.query('select invoice_id from public.family_invoices($1)', [ids.patient]));
    assert.ok(!draftVisible.some((r) => r.invoice_id === invoiceId), 'drafts are not shown to family');
    await expectPgError(probeAsUser(ids.owner, (db) => db.query('select * from public.family_invoice_lines($1)', [invoiceId])));

    await asUser(ids.ops, (db) => db.query('select public.ops_issue_invoice($1)', [invoiceId]));
    const bills = await probeAsUser(ids.owner, (db) => db.query('select * from public.family_invoices($1)', [ids.patient]));
    const bill = bills.find((b) => b.invoice_id === invoiceId);
    assert.equal(bill?.total_paise, BASIC_VISIT + 20000);
    assert.equal(bill?.can_pay, true);
    const billLines = await probeAsUser(ids.owner, (db) => db.query('select kind, amount_paise from public.family_invoice_lines($1)', [invoiceId]));
    assert.deepEqual(billLines.map((l) => [l.kind, l.amount_paise]), [['visit', BASIC_VISIT], ['fare', 20000]]);

    for (const user of [ids.viewer, ids.asha]) {
      await expectPgError(probeAsUser(user, (db) => db.query('select * from public.family_invoices($1)', [ids.patient])));
      await expectPgError(probeAsUser(user, (db) => db.query('select * from public.family_invoice_lines($1)', [invoiceId])));
    }
    for (const table of ['invoices', 'invoice_lines', 'payments']) {
      await expectPgError(probeAsUser(ids.owner, (db) => db.query(`select * from public.${table}`)));
    }
  });

  test('only the owner can start a payment; a repeated start reuses the open attempt', async () => {
    const start = () => asUser(ids.owner, (db) =>
      db.query<{ payment_id: string; amount_paise: number }>(`select * from public.payment_start($1, 'test')`, [invoiceId]));
    const [first] = await start();
    assert.equal(first.amount_paise, BASIC_VISIT + 20000);
    const [again] = await start();
    assert.equal(again.payment_id, first.payment_id);
    for (const user of [ids.viewer, ids.asha, ids.ops]) {
      await expectPgError(probeAsUser(user, (db) => db.query(`select * from public.payment_start($1, 'test')`, [invoiceId])));
    }
  });

  test('provider callbacks are service-role only; a wrong amount fails the payment, the right one pays the bill once', async () => {
    const [{ payment_id: paymentId }] = await asUser(ids.owner, (db) =>
      db.query<{ payment_id: string }>(`select * from public.payment_start($1, 'test')`, [invoiceId]));
    for (const user of [ids.owner, ids.ops]) {
      await expectPgError(probeAsUser(user, (db) => db.query(`select public.payment_set_order($1, 'x')`, [paymentId])));
      await expectPgError(probeAsUser(user, (db) => db.query(`select public.payment_captured('x', 'y', 1)`)));
    }
    await asServiceRole((db) => db.query(`select public.payment_set_order($1, 'test_order_1')`, [paymentId]));

    const capture = (amount: number, providerPaymentId: string) => asServiceRole((db) =>
      db.query<{ r: string }>('select public.payment_captured($1, $2, $3) as r', ['test_order_1', providerPaymentId, amount]))
      .then(([row]) => row.r);
    assert.equal(await capture(1, 'test_pay_bad'), 'amount_mismatch');
    assert.equal((await invoice(invoiceId)).status, 'issued', 'a mismatched amount does not pay the bill');

    // A fresh attempt (the failed one is closed), then the correct capture.
    const [{ payment_id: retryId }] = await asUser(ids.owner, (db) =>
      db.query<{ payment_id: string }>(`select * from public.payment_start($1, 'test')`, [invoiceId]));
    assert.notEqual(retryId, paymentId);
    await asServiceRole((db) => db.query(`select public.payment_set_order($1, 'test_order_2')`, [retryId]));
    const ok = await asServiceRole((db) => db.query<{ r: string }>(
      'select public.payment_captured($1, $2, $3) as r', ['test_order_2', 'test_pay_ok', BASIC_VISIT + 20000]));
    assert.equal(ok[0].r, 'captured');
    assert.equal((await invoice(invoiceId)).status, 'paid');
    const again = await asServiceRole((db) => db.query<{ r: string }>(
      'select public.payment_captured($1, $2, $3) as r', ['test_order_2', 'test_pay_ok', BASIC_VISIT + 20000]));
    assert.equal(again[0].r, 'already_captured');
    await expectPgError(asServiceRole((db) => db.query(`select public.payment_captured('nope', 'x', 1)`)), 'P0002');
    // A paid bill cannot be paid again.
    await expectPgError(probeAsUser(ids.owner, (db) => db.query(`select * from public.payment_start($1, 'test')`, [invoiceId])), '22023');
    const [{ can_pay }] = (await probeAsUser(ids.owner, (db) =>
      db.query<{ invoice_id: string; can_pay: boolean }>('select * from public.family_invoices($1)', [ids.patient])))
      .filter((b) => b.invoice_id === invoiceId);
    assert.equal(can_pay, false);
  });

  test('ops sees invoices across patients with visit and fare totals', async () => {
    const rows = await probeAsUser(ids.ops, (db) => db.query(`select * from public.ops_invoices('2024-03-01')`));
    const row = rows.find((r) => r.invoice_id === invoiceId);
    assert.equal(row?.status, 'paid');
    assert.equal(row?.visits, 1);
    assert.equal(row?.fares_paise, 20000);
  });
});
