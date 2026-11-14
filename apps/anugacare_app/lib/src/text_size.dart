import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

enum AppTextSize {
  small(0.9),
  standard(1),
  large(1.15),
  extraLarge(1.3);

  const AppTextSize(this.factor);
  final double factor;

  static AppTextSize fromStoredValue(String? value) =>
      values.where((size) => size.name == value).firstOrNull ?? standard;
}

/// Keep the device's nonlinear accessibility curve, then apply the user's choice.
TextScaler adjustedTextScaler(TextScaler device, AppTextSize size) => _AdjustedTextScaler(device, size.factor);

class _AdjustedTextScaler extends TextScaler {
  const _AdjustedTextScaler(this.device, this.factor);
  final TextScaler device;
  final double factor;

  @override
  double scale(double fontSize) => device.scale(fontSize) * factor;

  @override
  double get textScaleFactor => scale(14) / 14;
}

class TextSizeScope extends InheritedWidget {
  const TextSizeScope({super.key, required this.value, required this.onChanged, required super.child});
  final AppTextSize value;
  final ValueChanged<AppTextSize> onChanged;

  static TextSizeScope of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<TextSizeScope>()!;

  @override
  bool updateShouldNotify(TextSizeScope oldWidget) => value != oldWidget.value;
}

String _label(AppLocalizations l, AppTextSize size) => switch (size) {
  AppTextSize.small => l.textSizeSmall,
  AppTextSize.standard => l.textSizeStandard,
  AppTextSize.large => l.textSizeLarge,
  AppTextSize.extraLarge => l.textSizeExtraLarge,
};

class TextSizeControl extends StatelessWidget {
  const TextSizeControl({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = TextSizeScope.of(context);
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return PopupMenuButton<AppTextSize>(
      key: const Key('text-size-setting'),
      tooltip: l.textSize,
      initialValue: settings.value,
      onSelected: settings.onChanged,
      itemBuilder: (_) => [
        for (final size in AppTextSize.values)
          CheckedPopupMenuItem(
            key: Key('text-size-choice-${size.name}'),
            value: size,
            checked: settings.value == size,
            child: Text(_label(l, size)),
          ),
      ],
      child: ListTile(
        titleTextStyle: (theme.listTileTheme.titleTextStyle ?? theme.textTheme.bodyLarge)?.copyWith(inherit: false),
        subtitleTextStyle: (theme.listTileTheme.subtitleTextStyle ?? theme.textTheme.bodyMedium)?.copyWith(
          inherit: false,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        leading: const Icon(Icons.text_fields),
        title: Text(l.textSize),
        subtitle: Text(_label(l, settings.value)),
        trailing: const Icon(Icons.expand_more),
      ),
    );
  }
}
