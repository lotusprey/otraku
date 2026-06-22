import 'package:flutter/material.dart';
import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/localizations/gen.dart';
import 'package:otraku/util/theming.dart';

class Timestamp extends StatelessWidget {
  const Timestamp(
    this.dateTime,
    this.analogClock, {
    this.leading = const Icon(Icons.history_rounded, size: Theming.iconSmall),
  });

  final DateTime dateTime;
  final bool analogClock;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final children = [
      leading,
      Text(
        _relativeTime(l10n),
        style: TextTheme.of(context).labelSmall,
        overflow: .ellipsis,
        maxLines: 1,
      ),
    ];

    return Semantics(
      tooltip: l10n.dateTimeCreationTime,
      child: GestureDetector(
        onTap: () => SnackBarExtension.show(
          context,
          dateTime.formattedDateTimeFromSeconds(analogClock),
          canCopyText: true,
        ),
        child: Row(
          mainAxisSize: .min,
          spacing: 5,
          children: switch (Directionality.of(context)) {
            .ltr => children,
            .rtl => children.reversed.toList(),
          },
        ),
      ),
    );
  }

  String _relativeTime(AppLocalizations l10n) {
    final diff = DateTime.now().difference(dateTime);

    final seconds = diff.inSeconds;
    if (seconds < 61) {
      return l10n.dateTimeAgoSeconds(seconds);
    }

    final minutes = diff.inMinutes;
    if (minutes < 61) {
      return l10n.dateTimeAgoMinutes(minutes);
    }

    final hours = diff.inHours;
    if (hours < 25) {
      return l10n.dateTimeAgoHours(hours);
    }

    final days = diff.inDays;
    if (days < 31) {
      return l10n.dateTimeAgoDays(days);
    }

    final months = days ~/ 30;
    if (months < 13) {
      return l10n.dateTimeAgoMonths(months);
    }

    final years = months ~/ 12;
    return l10n.dateTimeAgoYears(years);
  }
}
