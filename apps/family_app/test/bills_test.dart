import 'package:family_app/src/screens/bills_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_dart/shared_dart.dart';

import 'support/fake_backend.dart';
import 'support/pump.dart';

FakeFamilyBackend withBill(AccessLevel level, {String status = 'issued'}) => FakeFamilyBackend(level: level)
  ..invoices.add({
    'invoice_id': 'i1',
    'period_start': '2026-09-01',
    'period_end': '2026-09-30',
    'status': status,
    'total_paise': 98000,
    'package_name': 'Basic',
    'issued_at': '2026-10-01T04:30:00+00:00',
    'paid_at': null,
  })
  ..invoiceLines['i1'] = [
    {'kind': 'visit', 'service_date': '2026-09-02', 'amount_paise': 40000},
    {'kind': 'fare', 'service_date': '2026-09-02', 'amount_paise': 18000},
    {'kind': 'visit', 'service_date': '2026-09-04', 'amount_paise': 40000},
  ];

Future<void> pumpBills(WidgetTester tester, FakeFamilyBackend backend, FakePayments payments) async {
  final patient = (await backend.api.myPatients()).single;
  await pumpLocalized(
    tester,
    Scaffold(
      body: BillsTab(api: backend.api, payments: payments, patient: patient),
    ),
  );
}

void main() {
  testWidgets('owner opens a due bill, sees the lines and pays in test mode', (tester) async {
    final backend = withBill(AccessLevel.owner);
    final payments = FakePayments(backend);
    await pumpBills(tester, backend, payments);
    expect(find.text('Bill for September 2026'), findsOneWidget);
    expect(find.textContaining('₹980.00 · Due'), findsOneWidget);

    await tapVisible(tester, byKey('bill-i1'));
    expect(find.text('Visit on 2 Sep'), findsOneWidget);
    expect(find.text('Cab/auto fare on 2 Sep'), findsOneWidget);
    expect(tester.widget<Text>(byKey('bill-total')).data, '₹980.00');

    await tapVisible(tester, byKey('pay'));
    expect(find.textContaining('Test mode: no real money moves'), findsOneWidget);
    await tapVisible(tester, find.text('Pay'));
    expect(payments.calls, ['start:i1', 'complete-test:i1']);
    expect(find.text('Payment received. Thank you!'), findsOneWidget);
    expect(byKey('pay'), findsNothing);
    expect(backend.invoices.single['status'], 'paid');
  });

  testWidgets('cancelling the test-mode confirmation pays nothing', (tester) async {
    final backend = withBill(AccessLevel.owner);
    final payments = FakePayments(backend);
    await pumpBills(tester, backend, payments);
    await tapVisible(tester, byKey('bill-i1'));
    await tapVisible(tester, byKey('pay'));
    await tapVisible(tester, find.text('Close'));
    expect(payments.calls, ['start:i1']);
    expect(backend.invoices.single['status'], 'issued');
  });

  testWidgets('with a live provider the app says checkout is not in this build', (tester) async {
    final backend = withBill(AccessLevel.owner);
    final payments = FakePayments(backend, providerName: 'razorpay');
    await pumpBills(tester, backend, payments);
    await tapVisible(tester, byKey('bill-i1'));
    await tapVisible(tester, byKey('pay'));
    expect(find.text('Online payment is not available in this build yet.'), findsOneWidget);
    expect(payments.calls, ['start:i1']);
  });

  testWidgets('an editor sees the bill but cannot pay', (tester) async {
    final backend = withBill(AccessLevel.editor);
    await pumpBills(tester, backend, FakePayments(backend));
    await tapVisible(tester, byKey('bill-i1'));
    expect(byKey('pay'), findsNothing);
  });

  testWidgets('viewers and the patient are told bills are for the owner and editors', (tester) async {
    for (final level in [AccessLevel.viewer, AccessLevel.patient]) {
      final backend = withBill(level);
      await pumpBills(tester, backend, FakePayments(backend));
      expect(byKey('bills-not-allowed'), findsOneWidget, reason: level.dbValue);
      expect(backend.calls, isNot(contains('family_invoices')), reason: 'no request is made');
    }
  });

  testWidgets('a paid bill shows as paid with no pay button', (tester) async {
    final backend = withBill(AccessLevel.owner, status: 'paid');
    await pumpBills(tester, backend, FakePayments(backend));
    expect(find.textContaining('· Paid'), findsOneWidget);
    await tapVisible(tester, byKey('bill-i1'));
    expect(byKey('pay'), findsNothing);
  });
}
