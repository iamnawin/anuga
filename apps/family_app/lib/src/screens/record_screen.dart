import 'package:flutter/material.dart';
import 'package:shared_dart/shared_dart.dart';

import '../../l10n/generated/app_localizations.dart';
import '../labels.dart';
import '../vault_files.dart';

/// Shows one report through a short-lived signed URL (an audited vault read).
/// The URL is fetched when the screen opens and is never stored.
class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key, required this.files, required this.document});

  final VaultFiles files;
  final VaultDocument document;

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  Uri? _url;
  Object? _error;

  @override
  void initState() {
    super.initState();
    if (widget.document.isImage) _open();
  }

  Future<void> _open() async {
    try {
      final url = await widget.files.downloadUrl(widget.document.id);
      if (mounted) setState(() => _url = url);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final doc = widget.document;
    Widget body;
    if (!doc.isImage) {
      body = Text(l10n.pdfNotViewable, key: const Key('pdf-note'));
    } else if (_error != null) {
      body = Text(describeError(l10n, _error!), key: const Key('record-error'));
    } else if (_url == null) {
      body = Text(l10n.loading);
    } else {
      body = InteractiveViewer(
        maxScale: 5,
        child: Image.network(
          _url.toString(),
          key: const Key('record-image'),
          errorBuilder: (context, error, stack) => Text(l10n.viewFailed),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(doc.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(docTypeLabel(l10n, doc.docType), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Expanded(child: Center(child: body)),
            ],
          ),
        ),
      ),
    );
  }
}
