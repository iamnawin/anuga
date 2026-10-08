import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
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

class _InboxTabState extends State<InboxTab> {
  List<InboxNotification>? _items;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await widget.api.notifications();
      if (mounted) {
        setState(() {
          _items = items;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
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
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null)
            Text(describeError(l10n, _error!), style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (items == null && _error == null) Text(l10n.loading),
          if (items != null && items.isEmpty) Text(l10n.noUpdates),
          for (final n in items ?? const <InboxNotification>[])
            Card(
              key: Key('update-${n.notificationId}'),
              child: ListTile(
                minVerticalPadding: 12,
                title: Text(_title(l10n, n, locale)),
                subtitle: (n.payload['note'] as String?)?.isNotEmpty == true ? Text(n.payload['note'] as String) : null,
              ),
            ),
        ],
      ),
    );
  }
}
