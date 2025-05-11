import 'package:flutter/material.dart';
import 'package:otraku/extension/date_time_extension.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
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
    final onTap = () => SnackBarExtension.show(
          context,
          dateTime.formattedDateTimeFromSeconds(analogClock),
          canCopyText: true,
        );

    return Semantics(
      onTap: onTap,
      onTapHint: 'show absolute creation time',
      tooltip: 'Creation Time',
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading,
            const SizedBox(width: 5),
            Text(
              _relativeTime(),
              style: TextTheme.of(context).labelSmall,
            )
          ],
        ),
      ),
    );
  }

  String _relativeTime() {
    final diff = DateTime.now().difference(dateTime);

    final seconds = diff.inSeconds;
    if (seconds < 61) {
      if (seconds > 4) return '$seconds seconds ago';

      return 'just now';
    }

    final minutes = diff.inMinutes;
    if (minutes < 61) {
      if (minutes > 1) return '$minutes minutes ago';

      return 'last minute';
    }

    final hours = diff.inHours;
    if (hours < 25) {
      if (hours > 1) return '$hours hours ago';

      return 'last hour';
    }

    final days = diff.inDays;
    if (days < 31) {
      if (days > 1) return '$days days ago';

      return 'yesterday';
    }

    final months = days ~/ 30;
    if (months < 13) {
      if (months > 1) return '$months months ago';

      return 'last month';
    }

    final years = months ~/ 12;
    if (years > 1) return '$years years ago';

    return 'last year';
  }
}
