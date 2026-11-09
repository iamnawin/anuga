import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import 'care_ui.dart';
import 'consent_screen.dart';

/// One-date care request; the database retains control of patient access,
/// consent, registered centre, package eligibility and duplicate detection.
class CareRequestScreen extends StatefulWidget {
  const CareRequestScreen({super.key, required this.api, required this.patient});

  final FamilyApi api;
  final FamilyPatient patient;

  @override
  State<CareRequestScreen> createState() => _CareRequestScreenState();
}

class _CareRequestScreenState extends State<CareRequestScreen> {
  final _form = GlobalKey<FormState>();
  final _date = TextEditingController();
  final _time = TextEditingController();
  CareOptions? _options;
  String? _packageId;
  Object? _error;
  bool _review = false;
  bool _busy = false;
  String _requestId = _newRequestId();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _date.dispose();
    _time.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final options = await widget.api.careOptions(widget.patient.patientId);
      if (mounted) {
        setState(() {
          _options = options;
          if (_packageId != null && !options.packages.any((p) => p.id == _packageId)) {
            _packageId = null;
            _review = false;
          }
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  DateTime? _pickup() {
    final date = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(_date.text.trim());
    final time = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(_time.text.trim());
    if (date == null || time == null) return null;
    final year = int.parse(date[1]!);
    final month = int.parse(date[2]!);
    final day = int.parse(date[3]!);
    final hour = int.parse(time[1]!);
    final minute = int.parse(time[2]!);
    final wall = DateTime.utc(year, month, day, hour, minute);
    if (wall.year != year || wall.month != month || wall.day != day || hour > 23 || minute > 59) return null;
    return wall.subtract(istOffset);
  }

  Future<void> _pickDate() async {
    final today = toIst(DateTime.now());
    final first = DateTime(today.year, today.month, today.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: first,
      firstDate: first,
      lastDate: DateTime(9999, 12, 31),
    );
    if (picked != null) _date.text = DateFormat('yyyy-MM-dd').format(picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 7, minute: 0));
    if (picked != null) {
      _time.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  void _reviewRequest() {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _review = true;
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.api.requestCare(
        requestId: _requestId,
        patientId: widget.patient.patientId,
        centreId: _options!.centreId,
        packageId: _packageId!,
        pickupAt: _pickup()!,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _privacy() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ConsentScreen(api: widget.api, patient: widget.patient),
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = _options;
    final permissionError = _error is RpcException && (_error! as RpcException).isNotAllowed;
    final duplicateError = _error is RpcException && (_error! as RpcException).code == '23505';
    final locale = Localizations.localeOf(context).languageCode;
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: Text(_review ? l10n.careReview : l10n.careRequestTitle)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CareHeading(_review ? l10n.careReview : l10n.careRequestTitle),
                  CarePanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.careRequestIntro),
                        const SizedBox(height: 12),
                        Text(
                          l10n.patientLabel,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.patient.fullName,
                          key: const Key('care-patient'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (options == null && _error == null) Text(l10n.loading),
                  if (options != null) ...[
                    if (_review) ...[
                      CarePanel(
                        key: const Key('care-review-summary'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l10n.centre}: ${options.centreName}',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text('${l10n.carePackage}: ${options.packages.firstWhere((p) => p.id == _packageId).name}'),
                            const SizedBox(height: 8),
                            Text(
                              '${l10n.carePickup}: ${DateFormat('d MMM y, HH:mm', locale).format(toIst(_pickup()!))}',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      CarePanel(child: Text(l10n.carePendingExplanation)),
                    ] else ...[
                      DropdownButtonFormField<String>(
                        key: const Key('care-centre'),
                        initialValue: options.centreId,
                        isExpanded: true,
                        itemHeight: null,
                        decoration: InputDecoration(
                          labelText: l10n.centre,
                          prefixIcon: const Icon(Icons.local_hospital_outlined),
                        ),
                        items: [DropdownMenuItem(value: options.centreId, child: Text(options.centreName))],
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.careRegisteredCentre,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        key: const Key('care-package'),
                        initialValue: _packageId,
                        isExpanded: true,
                        itemHeight: null,
                        decoration: InputDecoration(
                          labelText: l10n.carePackage,
                          prefixIcon: const Icon(Icons.medical_services_outlined),
                        ),
                        items: [for (final p in options.packages) DropdownMenuItem(value: p.id, child: Text(p.name))],
                        onChanged: (value) => setState(() => _packageId = value),
                        validator: (value) => value == null ? l10n.careChoosePackage : null,
                      ),
                      if (options.packages.isEmpty) Text(l10n.careNoPackages),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('care-date'),
                        controller: _date,
                        keyboardType: TextInputType.datetime,
                        decoration: InputDecoration(
                          labelText: l10n.careDate,
                          hintText: 'YYYY-MM-DD',
                          suffixIcon: IconButton(
                            tooltip: l10n.careDate,
                            icon: const Icon(Icons.calendar_month),
                            onPressed: _pickDate,
                          ),
                        ),
                        validator: (_) =>
                            _pickup() == null || !_pickup()!.isAfter(DateTime.now()) ? l10n.careFuturePickup : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('care-time'),
                        controller: _time,
                        keyboardType: TextInputType.datetime,
                        decoration: InputDecoration(
                          labelText: l10n.careTime,
                          hintText: 'HH:mm',
                          suffixIcon: IconButton(
                            tooltip: l10n.careTime,
                            icon: const Icon(Icons.access_time),
                            onPressed: _pickTime,
                          ),
                        ),
                        validator: (_) => _pickup() == null ? l10n.careFuturePickup : null,
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      key: Key(_review ? 'care-submit' : 'care-review'),
                      onPressed: _busy ? null : (_review ? _submit : _reviewRequest),
                      child: Text(_busy ? l10n.careSubmitting : (_review ? l10n.careSubmit : l10n.careReview)),
                    ),
                    if (_review) ...[
                      const SizedBox(height: 8),
                      OutlinedButton(
                        key: const Key('care-edit'),
                        onPressed: _busy
                            ? null
                            : () => setState(() {
                                _review = false;
                                _error = null;
                                _requestId = _newRequestId();
                              }),
                        child: Text(l10n.careEdit),
                      ),
                    ],
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        permissionError
                            ? l10n.carePermissionNeeded
                            : (duplicateError ? l10n.careDuplicate : l10n.errorGeneric),
                        key: const Key('care-error'),
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                    if (permissionError)
                      OutlinedButton(onPressed: _busy ? null : _privacy, child: Text(l10n.openConsent))
                    else if (options == null)
                      OutlinedButton(onPressed: _load, child: Text(l10n.refresh)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _newRequestId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 15) | 64;
  bytes[8] = (bytes[8] & 63) | 128;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
