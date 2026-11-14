import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import 'companion_help_screen.dart';
import 'companion_ui.dart';

enum _TripPage { status, pickup, handover, note }

typedef _IssueResult = ({String? error, bool denied});

/// The companion's existing journey contract, presented as focused task screens.
/// Every write still goes through the database state machine and restricted RPCs.
class CompanionTripScreen extends StatefulWidget {
  const CompanionTripScreen({super.key, required this.api, required this.trip, this.clock, this.nextPickupAt});

  final CompanionApi api;
  final CompanionTrip trip;
  final DateTime Function()? clock;
  final DateTime? nextPickupAt;

  @override
  State<CompanionTripScreen> createState() => _CompanionTripScreenState();
}

class _CompanionTripScreenState extends State<CompanionTripScreen> with WidgetsBindingObserver {
  late CompanionTrip? _trip = widget.trip;
  late TripStatus _status = widget.trip.status;
  final _code = TextEditingController();
  final _handoverNote = TextEditingController();
  final _visitNote = TextEditingController();
  final _scroll = ScrollController();
  final _issueSheet = GlobalKey<_IssueSheetState>();
  Route<void>? _issueRoute;
  _TripPage _page = _TripPage.status;
  bool _busy = false;
  bool _loading = false;
  bool _staffReceived = false;
  bool _belongingsReceived = false;
  bool _familyRecipient = true;
  bool _locked = false;
  bool _refreshAfterAction = false;
  bool _transportFailed = false;
  bool _offline = false;
  int _request = 0;
  String? _error;
  Timer? _startTimer;

  DateTime get _now => (widget.clock ?? DateTime.now)();
  bool get _canAct => !_busy && !_loading && !_offline && _trip != null;
  bool _can(TripStatus to) => TripStateMachine.instance.canAdvance(_status, to, TransitionActor.companion);

  void _scrollToTop() {
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _clearDrafts() {
    _code.clear();
    _handoverNote.clear();
    _visitNote.clear();
    _staffReceived = false;
    _belongingsReceived = false;
    _familyRecipient = true;
    _locked = false;
    _page = _TripPage.status;
    _scrollToTop();
    // Remove this exact sheet, never an unrelated route above the visit.
    _issueSheet.currentState?.clearDraft();
    final issueRoute = _issueRoute;
    _issueRoute = null;
    if (issueRoute?.isActive ?? false) {
      issueRoute!.navigator?.removeRoute(issueRoute);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleStart();
  }

  void _scheduleStart() {
    _startTimer?.cancel();
    final at = _trip?.startAllowedAt;
    if (at != null && at.isAfter(_now)) {
      _startTimer = Timer(at.difference(_now), () {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _startTimer?.cancel();
    _code.dispose();
    _handoverNote.dispose();
    _visitNote.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reload();
  }

  Future<void> _reload() async {
    if (_busy) {
      _refreshAfterAction = true;
      return;
    }
    final request = ++_request;
    setState(() {
      _trip = null;
      _loading = true;
      _error = null;
      _transportFailed = false;
      _code.clear();
      _locked = false;
    });
    try {
      final rows = await widget.api.myTrips(
        from: widget.trip.scheduledPickupAt.subtract(const Duration(seconds: 1)),
        to: widget.trip.scheduledPickupAt.add(const Duration(seconds: 1)),
      );
      if (!mounted || request != _request) return;
      final trip = rows.where((row) => row.tripId == widget.trip.tripId).firstOrNull;
      setState(() {
        _trip = trip;
        _loading = false;
        if (trip == null || !trip.detailsVisible) {
          _clearDrafts();
        }
        if (trip == null) {
          _error = AppLocalizations.of(context).cVisitDenied;
        } else {
          if (_status != trip.status) _page = _TripPage.status;
          _status = trip.status;
        }
      });
      _scheduleStart();
    } catch (error) {
      if (mounted && request == _request) {
        setState(() {
          _loading = false;
          _error = _describe(error);
          _transportFailed = error is! RpcException;
          if (error is RpcException && error.isNotAllowed) {
            _clearDrafts();
          }
        });
      }
    }
  }

  String _describe(Object error) {
    final l = AppLocalizations.of(context);
    if (error is RpcException && error.isNotAllowed) return l.cVisitDenied;
    if (error is RpcException && error.isStepNotPossible) return l.cStepChanged;
    return l.cActionError;
  }

  Future<void> _run(Future<void> Function() action) async {
    if (!_canAct) return;
    ++_request;
    setState(() {
      _busy = true;
      _error = null;
      _transportFailed = false;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) {
        if (error is RpcException && error.isNotAllowed) {
          _trip = null;
          _clearDrafts();
        }
        _error = _describe(error);
        _transportFailed = error is! RpcException;
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        if (_refreshAfterAction) {
          _refreshAfterAction = false;
          await _reload();
        }
      }
    }
  }

  Future<void> _advance(TripStatus to, {String? note}) async {
    if (!_can(to)) return;
    await _run(() async {
      final result = await widget.api.advance(widget.trip.tripId, to, note: note);
      if (!mounted) return;
      _status = result.status;
      _page = _TripPage.status;
      _scrollToTop();
      _code.clear();
      if (result.status == TripStatus.noShow || result.status == TripStatus.cancelled) {
        final trip = _trip;
        if (trip != null) {
          _trip = CompanionTrip(
            tripId: trip.tripId,
            scheduledPickupAt: trip.scheduledPickupAt,
            scheduledReturnAt: trip.scheduledReturnAt,
            status: result.status,
            centreName: trip.centreName,
            centreAddress: trip.centreAddress,
            detailsVisible: false,
          );
        }
        _clearDrafts();
      } else if (result.status == TripStatus.completed) {
        _clearDrafts();
      }
    });
  }

  Future<void> _verify() async {
    final l = AppLocalizations.of(context);
    if (!isOtpCode(_code.text)) {
      setState(() => _error = l.invalidCode);
      return;
    }
    if (_locked || !TripStateMachine.instance.needsPickupOtp(_status, TransitionActor.companion)) return;
    await _run(() async {
      final result = await widget.api.verifyPickupOtp(widget.trip.tripId, _code.text);
      if (!mounted) return;
      _code.clear();
      if (result.ok) {
        _status = result.status ?? TripStatus.pickedUp;
        _page = _TripPage.status;
        _scrollToTop();
      } else if (result.reason == 'wrong_code') {
        _locked = result.attemptsLeft == 0;
        _error = _locked ? l.cCodeLocked : l.cCodeWrong(result.attemptsLeft ?? 0);
      } else {
        _error = l.cCodeUnavailable;
      }
    });
  }

  void _showPage(_TripPage page) => setState(() {
    _page = page;
    _error = null;
    _scrollToTop();
  });

  Future<void> _issue() async {
    if (!_canAct || !_can(TripStatus.issueReported)) return;
    final status = _status;
    final l = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        _issueRoute = ModalRoute.of<void>(sheetContext);
        return _IssueSheet(
          key: _issueSheet,
          onSubmit: (note) async {
            if (!mounted || _trip == null) return (error: null, denied: true);
            if (status != _status || !_canAct) return (error: l.cStepChanged, denied: false);
            await _advance(TripStatus.issueReported, note: note);
            if (!mounted || _trip == null) return (error: null, denied: true);
            return (error: _status == TripStatus.issueReported ? null : _error ?? l.cActionError, denied: false);
          },
        );
      },
    );
    _issueRoute = null;
  }

  Future<void> _noShow() async {
    if (!_canAct || !_can(TripStatus.noShow)) return;
    final status = _status;
    final l = AppLocalizations.of(context);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.person_off_outlined, size: 40),
            const SizedBox(height: 16),
            Text(l.cPatientUnavailable, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(l.cNoShowConfirm),
            const SizedBox(height: 24),
            FilledButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cKeepVisit)),
            const SizedBox(height: 12),
            OutlinedButton(
              key: const Key('confirm-no-show'),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.cConfirmUnavailable),
            ),
          ],
        ),
      ),
    );
    if (!mounted || confirmed != true || status != _status || !_canAct) return;
    await _advance(TripStatus.noShow);
  }

  String _title(AppLocalizations l) => switch (_page) {
    _TripPage.pickup => l.cConfirmPickup,
    _TripPage.handover => l.cConfirmHandover,
    _TripPage.note => l.cVisitNote,
    _TripPage.status => switch (_status) {
      TripStatus.scheduled => l.cTripEssentials,
      TripStatus.companionEnRoute => l.cOnTheWay,
      TripStatus.atCentre => l.cAtCentre,
      TripStatus.handedOver => l.cSessionInProgress,
      TripStatus.returning => l.cReturningHome,
      TripStatus.droppedHome => l.cHomeArrival,
      TripStatus.completed => l.cVisitCompleted,
      _ => companionStatus(l, _status),
    },
  };

  Widget _button(String key, String label, VoidCallback? action, {bool secondary = false}) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: secondary
        ? OutlinedButton(key: Key(key), onPressed: _canAct ? action : null, child: Text(label))
        : FilledButton(key: Key(key), onPressed: _canAct ? action : null, child: Text(label)),
  );

  @override
  Widget build(BuildContext context) => CompanionNetworkView(builder: _build);

  Widget _build(BuildContext context) {
    _offline = companionIsOffline(context);
    final l = AppLocalizations.of(context);
    final trip = _trip;
    return Scaffold(
      appBar: AppBar(
        title: Text(_title(l)),
        leading: _page != _TripPage.status
            ? IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: _busy ? null : () => _showPage(_TripPage.status),
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        actions: [
          IconButton(
            key: const Key('visit-refresh'),
            tooltip: l.cRefresh,
            onPressed: _busy ? null : _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scroll,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_offline) const CompanionOfflineNotice(),
              if (_transportFailed) CompanionNotice(message: l.cConnectionProblem),
              if (_loading) ...[const LinearProgressIndicator(), Text(l.cLoading)],
              if (_error != null) CompanionNotice(message: _error!, onRetry: _reload),
              if (trip != null) ...[
                CompanionProgress(status: _status),
                const SizedBox(height: 20),
                CompanionPerson(name: trip.detailsVisible ? firstName(trip.patientName) : null),
                const SizedBox(height: 12),
                Text(companionDate(trip.scheduledPickupAt, context)),
                Text(l.pickupAt(companionTime(trip.scheduledPickupAt, context))),
                if (_status != TripStatus.completed)
                  Text(
                    companionStatus(l, _status),
                    key: const Key('trip-status'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                const SizedBox(height: 20),
                ..._content(trip, l),
                if (_busy) const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
                if (!_status.isTerminal) ...[
                  const SizedBox(height: 24),
                  const CompanionSupport(),
                  _button('trip-help', l.cHelp, () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            CompanionHelpScreen(onReportIssue: _can(TripStatus.issueReported) ? _issue : null),
                      ),
                    );
                  }, secondary: true),
                  if (_can(TripStatus.issueReported)) _button('report-issue', l.cReportIssue, _issue, secondary: true),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(CompanionTrip trip, AppLocalizations l) {
    if (_page == _TripPage.pickup) return _pickup(l);
    if (_page == _TripPage.handover) return _handover(l);
    if (_page == _TripPage.note) return _note(l);
    final tooEarly = trip.startAllowedAt?.isAfter(_now) ?? false;
    switch (_status) {
      case TripStatus.scheduled:
        return [
          CompanionRoute(trip: trip, status: _status),
          if (trip.detailsVisible && (trip.mobilityNotes?.isNotEmpty ?? false))
            CompanionPanel(child: Text(l.cMobility(trip.mobilityNotes!))),
          if (trip.detailsVisible && trip.emergencyContacts.isNotEmpty) Text(l.familyContacts),
          if (trip.detailsVisible)
            for (final contact in trip.emergencyContacts) CompanionPerson(name: firstName(contact.name)),
          if (tooEarly) Text(l.cStartOpens(companionTime(trip.startAllowedAt!, context))),
          _button('start-journey', l.cStartJourney, tooEarly ? null : () => _advance(TripStatus.companionEnRoute)),
        ];
      case TripStatus.companionEnRoute:
        return [
          CompanionRoute(trip: trip, status: _status),
          if (trip.detailsVisible && (trip.mobilityNotes?.isNotEmpty ?? false))
            CompanionPanel(child: Text(l.cMobility(trip.mobilityNotes!))),
          if (trip.detailsVisible && trip.emergencyContacts.isNotEmpty) Text(l.familyContacts),
          if (trip.detailsVisible)
            for (final contact in trip.emergencyContacts) CompanionPerson(name: firstName(contact.name)),
          _button('open-pickup', l.cConfirmPickup, () => _showPage(_TripPage.pickup)),
          _button('patient-unavailable', l.cPatientUnavailable, _noShow, secondary: true),
        ];
      case TripStatus.pickedUp:
        return [
          CompanionRoute(trip: trip, status: _status),
          _button('arrive-centre', l.cConfirmAtCentre, () => _advance(TripStatus.atCentre)),
        ];
      case TripStatus.atCentre:
        return [
          CompanionRoute(trip: trip, status: _status),
          Text(l.cNextHandover),
          _button('open-handover', l.cContinueHandover, () => _showPage(_TripPage.handover)),
        ];
      case TripStatus.handedOver:
        return [
          CompanionPanel(child: Text(l.cWaitForCentre)),
          Text(l.cExpectedReturn(companionTime(trip.scheduledReturnAt, context))),
          _button('session-finished', l.cConfirmSession, () => _advance(TripStatus.sessionDone)),
        ];
      case TripStatus.sessionDone:
        return [
          Text(l.cSessionFinished),
          CompanionRoute(trip: trip, returning: true),
          _button('start-return', l.cStartReturn, () => _advance(TripStatus.returning)),
        ];
      case TripStatus.returning:
        return [
          Text(l.cPatientWithYou),
          CompanionRoute(trip: trip, returning: true),
          _button('arrive-home', l.cConfirmHome, () => _advance(TripStatus.droppedHome)),
        ];
      case TripStatus.droppedHome:
        return _home(l);
      case TripStatus.completed:
        return [
          CompanionPanel(
            child: Column(
              children: [const Icon(Icons.check_circle_outline, size: 48), Text(l.cThankYou), Text(l.cNoteSubmitted)],
            ),
          ),
          if (widget.nextPickupAt != null)
            CompanionPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.cNextVisit),
                  Text(companionDate(widget.nextPickupAt!, context)),
                  Text(companionTime(widget.nextPickupAt!, context)),
                ],
              ),
            ),
          _button('back-today', l.cBackToday, () => Navigator.pop(context)),
        ];
      case TripStatus.issueReported:
        return [CompanionNotice(message: l.cIssueWaiting, onRetry: _reload)];
      case TripStatus.cancelled || TripStatus.noShow:
        return [Text(l.cVisitClosed), _button('back-today', l.cBackToday, () => Navigator.pop(context))];
    }
  }

  List<Widget> _pickup(AppLocalizations l) => [
    if (_trip?.detailsVisible ?? false) Text(_trip?.homeAddress ?? ''),
    Text(l.cAskPickupCode),
    const SizedBox(height: 16),
    TextField(
      key: const Key('pickup-code'),
      controller: _code,
      enabled: _canAct && !_locked,
      keyboardType: TextInputType.number,
      obscureText: true,
      maxLength: 6,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: l.cPickupCode),
      onChanged: (_) => setState(() {}),
    ),
    ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < 6; i++)
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(3),
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: i < _code.text.length ? const Icon(Icons.circle, size: 12) : null,
              ),
            ),
        ],
      ),
    ),
    _button('verify-pickup', l.cVerifyPickup, _locked ? null : _verify),
    _button('patient-unavailable', l.cPatientUnavailable, _noShow, secondary: true),
  ];

  List<Widget> _handover(AppLocalizations l) => [
    Text(_trip!.centreName, style: Theme.of(context).textTheme.titleMedium),
    CheckboxListTile(
      key: const Key('staff-received'),
      contentPadding: EdgeInsets.zero,
      title: Text(l.cStaffReceived),
      value: _staffReceived,
      onChanged: _canAct ? (value) => setState(() => _staffReceived = value ?? false) : null,
    ),
    CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(l.cBelongings),
      value: _belongingsReceived,
      onChanged: _canAct ? (value) => setState(() => _belongingsReceived = value ?? false) : null,
    ),
    TextField(
      key: const Key('handover-note'),
      controller: _handoverNote,
      enabled: _canAct,
      minLines: 2,
      maxLines: 5,
      decoration: InputDecoration(labelText: l.cHandoverNote),
    ),
    _button(
      'confirm-handover',
      l.cConfirmHandover,
      _staffReceived
          ? () => _advance(
              TripStatus.handedOver,
              note: _handoverNote.text.trim().isEmpty ? null : _handoverNote.text.trim(),
            )
          : null,
    ),
  ];

  List<Widget> _home(AppLocalizations l) => [
    CompanionPanel(child: Column(children: [const Icon(Icons.home_outlined, size: 48), Text(l.cPatientHome)])),
    const SizedBox(height: 16),
    Text(l.cHandedTo),
    RadioGroup<bool>(
      groupValue: _familyRecipient,
      onChanged: (value) {
        if (_canAct && value != null) setState(() => _familyRecipient = value);
      },
      child: Column(
        children: [
          RadioListTile<bool>(
            value: true,
            enabled: _canAct,
            title: Text(l.cFamilyMember),
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<bool>(
            value: false,
            enabled: _canAct,
            title: Text(l.cPatientAtDoor),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),
    Text(l.cCompleteAfterNote),
    _button('add-visit-note', l.cAddNote, () => _showPage(_TripPage.note)),
  ];

  List<Widget> _note(AppLocalizations l) => [
    Text(l.cNoMedicalNotes),
    const SizedBox(height: 16),
    TextField(
      key: const Key('visit-note'),
      controller: _visitNote,
      enabled: _canAct,
      minLines: 4,
      maxLines: 8,
      decoration: InputDecoration(labelText: l.cVisitNote, hintText: l.cNoteHint),
    ),
    _button('complete-visit', l.cSubmitComplete, () {
      final note = _visitNote.text.trim();
      if (note.isEmpty) {
        setState(() => _error = l.cNoteRequired);
        return;
      }
      final recipient = _familyRecipient ? l.cFamilyMember : l.cPatientAtDoor;
      _advance(TripStatus.completed, note: '${l.cHandedTo} $recipient\n$note');
    }),
  ];
}

class _IssueSheet extends StatefulWidget {
  const _IssueSheet({super.key, required this.onSubmit});
  final Future<_IssueResult> Function(String) onSubmit;

  @override
  State<_IssueSheet> createState() => _IssueSheetState();
}

class _IssueSheetState extends State<_IssueSheet> {
  final _note = TextEditingController();
  int? _selected;
  String? _error;
  bool _busy = false;
  bool _revoked = false;

  void clearDraft() {
    _revoked = true;
    _note.clear();
    _selected = null;
    _error = null;
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final reasons = [l.cPatientNotReady, l.cPatientUnwell, l.cCannotFindFamily, l.cCentreNotReady, l.cOther];
    return CompanionNetworkView(
      builder: (context) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.cReportIssue, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < reasons.length; i++)
                  ChoiceChip(
                    label: Text(reasons[i]),
                    selected: _selected == i,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    onSelected: _busy ? null : (_) => setState(() => _selected = i),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('issue-note'),
              controller: _note,
              enabled: !_busy,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(labelText: l.cIssueDetails, errorText: _error),
            ),
            const SizedBox(height: 16),
            Text(l.cEmergencyReminder, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 16),
            if (_busy) const LinearProgressIndicator(),
            if (companionIsOffline(context)) const CompanionOfflineNotice(),
            FilledButton(
              key: const Key('send-issue'),
              onPressed: _busy || companionIsOffline(context)
                  ? null
                  : () async {
                      if (_note.text.trim().isEmpty) {
                        setState(() => _error = l.cIssueRequired);
                        return;
                      }
                      final category = _selected == null ? '' : '${reasons[_selected!]}\n';
                      setState(() {
                        _busy = true;
                        _error = null;
                      });
                      final result = await widget.onSubmit('$category${_note.text.trim()}');
                      if (_revoked || !context.mounted) return;
                      if (result.denied || result.error == null) {
                        _note.clear();
                        _selected = null;
                        Navigator.pop(context);
                        return;
                      }
                      setState(() {
                        _busy = false;
                        _error = result.error;
                      });
                    },
              child: Text(l.cSendReport),
            ),
            TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: Text(l.cCancel)),
          ],
        ),
      ),
    );
  }
}
