import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import '../format.dart';
import '../labels.dart';
import '../photo_source.dart';
import '../vault_files.dart';
import 'consent_screen.dart';
import 'record_screen.dart';

/// Health records (vault documents). Listing is an audited vault read. Adding a
/// report needs edit access and the owner's records consent; the database and the
/// vault-files function check both again.
class RecordsTab extends StatefulWidget {
  const RecordsTab({super.key, required this.api, required this.files, required this.photos, required this.patient});

  final FamilyApi api;
  final VaultFiles files;
  final PhotoSource photos;
  final FamilyPatient patient;

  @override
  State<RecordsTab> createState() => _RecordsTabState();
}

class _RecordsTabState extends State<RecordsTab> {
  List<VaultDocument>? _docs;
  bool? _consent;
  Object? _error;
  bool _busy = false;
  String? _info;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final consents = await widget.api.consents(widget.patient.patientId);
      final docs = await widget.api.vaultDocuments(widget.patient.patientId);
      if (!mounted) return;
      setState(() {
        _consent = consents.any((c) => c.purpose == ConsentPurpose.vault && c.active);
        _docs = docs;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  bool get _canAdd => widget.patient.accessLevel.canChangeTrips && _consent == true;

  Future<void> _add() async {
    final l10n = AppLocalizations.of(context);
    final camera = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(l10n.takePhoto),
              onTap: () => Navigator.pop(context, true),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.chooseFromGallery),
              onTap: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    );
    if (camera == null) return;
    final photo = await widget.photos.pick(camera: camera);
    if (photo == null || !mounted) return;
    final details = await showDialog<({String title, String type})>(
      context: context,
      builder: (_) => const _DetailsDialog(),
    );
    if (details == null || !mounted) return;

    setState(() {
      _busy = true;
      _info = l10n.uploading;
      _error = null;
    });
    try {
      final start = await widget.files.startUpload(
        patientId: widget.patient.patientId,
        docType: details.type,
        title: details.title,
        contentType: photo.contentType,
        sizeBytes: photo.bytes.length,
      );
      await widget.files.putFile(start.uploadUrl, photo.bytes, photo.contentType);
      await widget.files.confirm(start.documentId);
      if (mounted) setState(() => _info = l10n.uploadDone);
    } catch (e) {
      if (mounted) {
        setState(() {
          _info = null;
          _error = e;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final docs = _docs;
    final isOwner = widget.patient.accessLevel == AccessLevel.owner;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_consent == false) ...[
            Text(isOwner ? l10n.recordsOffOwner : l10n.recordsOffOther, key: const Key('records-off')),
            if (isOwner)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: OutlinedButton(
                  key: const Key('open-consent'),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ConsentScreen(api: widget.api, patient: widget.patient),
                      ),
                    );
                    await _load();
                  },
                  child: Text(l10n.openConsent),
                ),
              ),
          ],
          if (_canAdd)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FilledButton.icon(
                key: const Key('add-record'),
                onPressed: _busy ? null : _add,
                icon: const Icon(Icons.add_a_photo),
                label: Text(l10n.addReportPhoto),
              ),
            ),
          if (_info != null) Text(_info!, key: const Key('records-info')),
          if (_error != null)
            Text(
              describeError(l10n, _error!),
              key: const Key('records-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (docs == null && _error == null) Text(l10n.loading),
          if (docs != null && docs.isEmpty) Text(l10n.noRecords),
          for (final doc in docs ?? const <VaultDocument>[])
            Card(
              key: Key('record-${doc.id}'),
              child: ListTile(
                minVerticalPadding: 12,
                leading: Icon(doc.isImage ? Icons.image : Icons.description, size: 32),
                title: Text(doc.title),
                subtitle: Text(
                  [
                    docTypeLabel(l10n, doc.docType),
                    formatIstDateTime(doc.createdAt, locale),
                    if (!doc.isUploaded) l10n.uploadPending,
                  ].join(' · '),
                ),
                onTap: doc.isUploaded
                    ? () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => RecordScreen(files: widget.files, document: doc),
                        ),
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

/// Name and type for a new report.
class _DetailsDialog extends StatefulWidget {
  const _DetailsDialog();

  @override
  State<_DetailsDialog> createState() => _DetailsDialogState();
}

class _DetailsDialogState extends State<_DetailsDialog> {
  final _title = TextEditingController();
  String _type = 'lab_report';
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('record-title'),
            controller: _title,
            decoration: InputDecoration(labelText: l10n.docTitleLabel, errorText: _error),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: const Key('record-type'),
            initialValue: _type,
            // Long type names at large text sizes must fit the dialog.
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.docTypeLabel),
            items: [
              for (final t in VaultDocument.docTypes) DropdownMenuItem(value: t, child: Text(docTypeLabel(l10n, t))),
            ],
            onChanged: (t) => setState(() => _type = t ?? _type),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
        FilledButton(
          onPressed: () {
            final title = _title.text.trim();
            if (title.isEmpty) return setState(() => _error = l10n.docTitleRequired);
            Navigator.pop(context, (title: title, type: _type));
          },
          child: Text(l10n.upload),
        ),
      ],
    );
  }
}
