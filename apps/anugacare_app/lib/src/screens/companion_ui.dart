import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_dart/shared_dart.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/generated/app_localizations.dart';
import 'companion_connection_stub.dart' if (dart.library.js_interop) 'companion_connection_web.dart';
export 'companion_connection_stub.dart' if (dart.library.js_interop) 'companion_connection_web.dart';

String? firstName(String? name) => name?.trim().split(RegExp(r'\s+')).firstOrNull;
String companionDate(DateTime time, BuildContext context) =>
    DateFormat.yMMMEd(Localizations.localeOf(context).languageCode).format(toIst(time));
String companionTime(DateTime time, BuildContext context) =>
    DateFormat.jm(Localizations.localeOf(context).languageCode).format(toIst(time));

String companionStatus(AppLocalizations l, TripStatus status) => switch (status) {
  TripStatus.scheduled => l.statusScheduled,
  TripStatus.companionEnRoute => l.statusCompanionEnRoute,
  TripStatus.pickedUp => l.statusPickedUp,
  TripStatus.atCentre => l.statusAtCentre,
  TripStatus.handedOver => l.statusHandedOver,
  TripStatus.sessionDone => l.statusSessionDone,
  TripStatus.returning => l.statusReturning,
  TripStatus.droppedHome => l.statusDroppedHome,
  TripStatus.completed => l.statusCompleted,
  TripStatus.cancelled => l.statusCancelled,
  TripStatus.noShow => l.statusNoShow,
  TripStatus.issueReported => l.statusIssueReported,
};

class CompanionNetworkView extends StatelessWidget {
  const CompanionNetworkView({super.key, required this.builder});
  final WidgetBuilder builder;
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: companionNetworkOnline,
    builder: (context, online, _) => _NetworkScope(
      online: online,
      child: Builder(builder: builder),
    ),
  );
}

class _NetworkScope extends InheritedWidget {
  const _NetworkScope({required this.online, required super.child});
  final bool online;
  @override
  bool updateShouldNotify(_NetworkScope oldWidget) => online != oldWidget.online;
}

bool companionIsOffline(BuildContext context) =>
    !(context.dependOnInheritedWidgetOfExactType<_NetworkScope>()?.online ?? companionNetworkOnline.value);

class CompanionOfflineNotice extends StatelessWidget {
  const CompanionOfflineNotice({super.key});
  @override
  Widget build(BuildContext context) => CompanionNotice(message: AppLocalizations.of(context).cOffline);
}

class CompanionNotice extends StatelessWidget {
  const CompanionNotice({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: CompanionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(message),
          if (onRetry != null)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).retry),
            ),
        ],
      ),
    ),
  );
}

class CompanionPanel extends StatelessWidget {
  const CompanionPanel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );
}

/// A deliberately neutral, flat illustrated face; no photograph or uniform.
class CompanionPerson extends StatelessWidget {
  const CompanionPerson({super.key, required this.name});
  final String? name;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      ExcludeSemantics(
        child: SizedBox(
          width: 56,
          height: 56,
          child: CustomPaint(painter: _FacePainter(Theme.of(context).colorScheme)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          firstName(name) ?? AppLocalizations.of(context).detailsHidden,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    ],
  );
}

class _FacePainter extends CustomPainter {
  const _FacePainter(this.scheme);
  final ColorScheme scheme;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 56, size.height / 56);
    final paint = Paint()..isAntiAlias = true;
    canvas.drawCircle(const Offset(28, 28), 28, paint..color = scheme.surfaceContainerLow);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(11, 36, 34, 18), const Radius.circular(14)),
      paint..color = scheme.primary,
    );
    canvas.drawOval(const Rect.fromLTWH(15, 8, 26, 30), paint..color = const Color(0xFF273B43));
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(18, 15, 20, 25), const Radius.circular(9)),
      paint..color = const Color(0xFFE3B28E),
    );
    canvas.drawCircle(const Offset(24, 25), 1.2, paint..color = const Color(0xFF273B43));
    canvas.drawCircle(const Offset(32, 25), 1.2, paint);
    canvas.drawArc(
      const Rect.fromLTWH(24, 28, 8, 5),
      0,
      3.14,
      false,
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(_FacePainter oldDelegate) => scheme != oldDelegate.scheme;
}

class CompanionProgress extends StatelessWidget {
  const CompanionProgress({super.key, required this.status});
  final TripStatus status;
  static const stages = [
    TripStatus.scheduled,
    TripStatus.companionEnRoute,
    TripStatus.pickedUp,
    TripStatus.atCentre,
    TripStatus.handedOver,
    TripStatus.sessionDone,
    TripStatus.returning,
    TripStatus.droppedHome,
  ];
  @override
  Widget build(BuildContext context) {
    final index = status == TripStatus.completed ? 7 : stages.indexOf(status);
    if (index < 0) return const SizedBox.shrink();
    final label = AppLocalizations.of(context).cStep(index + 1);
    return Semantics(
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Row(
              key: const Key('visit-progress'),
              children: [
                for (var i = 0; i < 8; i++)
                  Expanded(
                    child: Container(
                      height: 6,
                      margin: const EdgeInsetsDirectional.only(end: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: i <= index
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ExcludeSemantics(child: Text(label)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

Future<bool> companionExternal(Uri uri) async {
  try {
    return await launchUrl(uri, mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

Uri companionMapUri(String destination, {required bool isWeb, required TargetPlatform platform}) {
  if (isWeb) {
    return Uri.https('www.google.com', '/maps/dir/', {'api': '1', 'destination': destination});
  }
  return platform == TargetPlatform.iOS
      ? Uri(scheme: 'maps', queryParameters: {'q': destination})
      : Uri(scheme: 'geo', path: '0,0', queryParameters: {'q': destination});
}

class CompanionRoute extends StatelessWidget {
  const CompanionRoute({super.key, required this.trip, this.returning = false, this.status});
  final CompanionTrip trip;
  final bool returning;
  final TripStatus? status;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final home = trip.detailsVisible ? trip.homeAddress : null;
    final homeDestination = trip.detailsVisible && trip.homeLat != null && trip.homeLng != null
        ? '${trip.homeLat},${trip.homeLng}'
        : home;
    final currentStatus = status ?? trip.status;
    final destination =
        returning || currentStatus == TripStatus.scheduled || currentStatus == TripStatus.companionEnRoute
        ? homeDestination
        : trip.centreAddress;
    final homeRow = _Place(icon: Icons.home_outlined, label: l.homeAddress, value: home ?? l.detailsHidden);
    final centreRow = _Place(icon: Icons.apartment_outlined, label: trip.centreName, value: trip.centreAddress);
    return CompanionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (returning) centreRow else homeRow,
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 21),
            child: ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < 4; i++)
                    Container(
                      width: 2,
                      height: 3,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
          ),
          if (returning) homeRow else centreRow,
          const SizedBox(height: 16),
          OutlinedButton.icon(
            key: const Key('navigate'),
            onPressed: destination == null || destination.trim().isEmpty || companionIsOffline(context)
                ? null
                : () async {
                    final uri = companionMapUri(destination, isWeb: kIsWeb, platform: defaultTargetPlatform);
                    final opened = await companionExternal(uri);
                    if (!opened && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.cCannotOpen)));
                    }
                  },
            icon: const Icon(Icons.navigation_outlined),
            label: Text(l.cNavigate),
          ),
        ],
      ),
    );
  }
}

class _Place extends StatelessWidget {
  const _Place({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        foregroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(icon),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            Text(value),
          ],
        ),
      ),
    ],
  );
}

class CompanionSupport extends StatelessWidget {
  const CompanionSupport({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.support_agent), label: Text(l.cCallSupport)),
        const SizedBox(height: 8),
        Text(l.cSupportUnavailable),
        const SizedBox(height: 16),
      ],
    );
  }
}
