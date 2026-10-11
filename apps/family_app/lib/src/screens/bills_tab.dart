import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import 'care_ui.dart';
import '../format.dart';
import '../labels.dart';
import '../payments.dart';

/// Monthly bills (`family_invoices`): owner and editors; the owner can pay a due bill.
class BillsTab extends StatefulWidget {
  const BillsTab({super.key, required this.api, required this.payments, required this.patient});

  final FamilyApi api;
  final Payments payments;
  final FamilyPatient patient;

  @override
  State<BillsTab> createState() => _BillsTabState();
}

class _BillsTabState extends State<BillsTab> {
  List<Invoice>? _bills;
  Object? _error;

  bool get _allowed => widget.patient.accessLevel.canChangeTrips;

  @override
  void initState() {
    super.initState();
    if (_allowed) _load();
  }

  Future<void> _load() async {
    try {
      final bills = await widget.api.invoices(widget.patient.patientId);
      if (mounted) {
        setState(() {
          _bills = bills;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    if (!_allowed) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(l10n.billsNotAllowed, key: const Key('bills-not-allowed')),
      );
    }
    final bills = _bills;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CareHeading(l10n.tabBills),
          if (_error != null)
            Text(describeError(l10n, _error!), style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (bills == null && _error == null) Text(l10n.loading),
          if (bills != null && bills.isEmpty) Text(l10n.noBills),
          for (final bill in bills ?? const <Invoice>[])
            Card(
              key: Key('bill-${bill.id}'),
              child: ListTile(
                minVerticalPadding: 12,
                leading: const Icon(Icons.receipt_long_outlined, size: 28),
                title: Text(l10n.billFor(formatMonth(bill.periodStart, locale))),
                subtitle: Text(
                  '${formatRupees(bill.totalPaise, locale)} · ${bill.isPaid ? l10n.billPaid : l10n.billDue}',
                ),
                trailing: const Icon(Icons.chevron_right, size: 32),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BillScreen(api: widget.api, payments: widget.payments, bill: bill),
                    ),
                  );
                  await _load();
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// One bill: its lines and, for the owner while due, payment.
class BillScreen extends StatefulWidget {
  const BillScreen({super.key, required this.api, required this.payments, required this.bill});

  final FamilyApi api;
  final Payments payments;
  final Invoice bill;

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  List<InvoiceLine>? _lines;
  late bool _paid = widget.bill.isPaid;
  bool _busy = false;
  String? _message;
  bool _messageIsError = false;

  @override
  void initState() {
    super.initState();
    widget.api.invoiceLines(widget.bill.id).then((lines) {
      if (mounted) setState(() => _lines = lines);
    });
  }

  Future<void> _pay() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final provider = await widget.payments.provider(widget.bill.id);
      if (provider != 'test') {
        // Real checkout (Razorpay SDK) is not part of this build.
        setState(() {
          _message = l10n.onlinePaymentNotInBuild;
          _messageIsError = true;
        });
        return;
      }
      if (!mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(l10n.testModeNotice),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.close)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.confirmPay)),
          ],
        ),
      );
      if (ok != true) return;
      await widget.payments.completeTestPayment(widget.bill.id);
      setState(() {
        _paid = true;
        _message = l10n.paymentDone;
        _messageIsError = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _message = describeError(l10n, e);
          _messageIsError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _lineLabel(AppLocalizations l10n, InvoiceLine line, String locale) => switch (line.kind) {
    'visit' => l10n.lineVisit(formatDay(line.serviceDate!, locale)),
    'fare' => l10n.lineFare(formatDay(line.serviceDate!, locale)),
    _ => l10n.lineMonthlyFee,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final bill = widget.bill;
    final lines = _lines;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.billFor(formatMonth(bill.periodStart, locale)))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CarePanel(child: Text(bill.packageName, style: Theme.of(context).textTheme.titleLarge)),
            const SizedBox(height: 24),
            if (lines == null) Text(l10n.loading),
            for (final line in lines ?? const <InvoiceLine>[])
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_lineLabel(l10n, line, locale)),
                subtitle: Text(
                  formatRupees(line.amountPaise, locale),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.billTotal, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                formatRupees(bill.totalPaise, locale),
                key: const Key('bill-total'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            Chip(key: const Key('bill-status'), label: Text(_paid ? l10n.billPaid : l10n.billDue)),
            if (bill.canPay && !_paid)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: FilledButton(
                  key: const Key('pay'),
                  onPressed: _busy ? null : _pay,
                  child: Text(l10n.payNow(formatRupees(bill.totalPaise, locale))),
                ),
              ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _message!,
                  key: const Key('pay-message'),
                  style: TextStyle(fontSize: 18, color: _messageIsError ? Theme.of(context).colorScheme.error : null),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
