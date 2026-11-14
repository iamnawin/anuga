import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import 'care_ui.dart';
import 'family_ui.dart';
import '../format.dart';
import '../labels.dart';

/// In-app inbox (`my_notifications`): the push copies of status changes and
/// companion assignments, newest first.
class InboxTab extends StatefulWidget {
  const InboxTab({super.key, required this.api});

  final FamilyApi api;

  @override
  State<InboxTab> createState() => _InboxTabState();
}

class _InboxTabState extends State<InboxTab> with WidgetsBindingObserver {
  List<InboxNotification>? _items;
  Object? _error;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    final request = ++_request;
    setState(() {
      _items = null;
      _error = null;
    });
    try {
      final items = await widget.api.notifications();
      if (mounted && request == _request) {
        setState(() {
          _items = items;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted && request == _request) setState(() => _error = e);
    }
  }

  String _title(AppLocalizations l10n, InboxNotification n, String locale) => switch (n.template) {
    'trip_status_changed' when n.toStatus != null => l10n.updateStatus(
      formatIstDateTime(n.createdAt, locale),
      statusLabel(l10n, n.toStatus!),
    ),
    'companion_assigned' => l10n.updateCompanionAssigned,
    'companion_changed' => l10n.updateCompanionChanged,
    _ => l10n.updateOther,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final items = _items;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: CareHeading(l10n.tabInbox)),
              IconButton(
                key: const Key('updates-refresh'),
                tooltip: l10n.refresh,
                onPressed: _load,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (_error != null) FamilyFailureNotice(_error!, key: const Key('updates-error')),
          if (items == null && _error == null) Text(l10n.loading),
          if (items != null && items.isEmpty) Text(l10n.noUpdates),
          for (final n in items ?? const <InboxNotification>[])
            Card(
              key: Key('update-${n.notificationId}'),
              child: ListTile(
                minVerticalPadding: 12,
                leading: const Icon(Icons.notifications_outlined, size: 28),
                title: Text(_title(l10n, n, locale)),
                subtitle: (n.payload['note'] as String?)?.isNotEmpty == true ? Text(n.payload['note'] as String) : null,
              ),
            ),
        ],
      ),
    );
  }
}
