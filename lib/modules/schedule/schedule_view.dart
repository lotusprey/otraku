import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/paged_view.dart';
import 'package:otraku/modules/schedule/schedule_media_grid.dart';
import 'package:otraku/modules/schedule/schedule_models.dart';
import 'package:otraku/modules/schedule/schedule_provider.dart';

class ScheduleView extends ConsumerWidget {
  const ScheduleView(this.scrollCtrl);

  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onRefresh = () {
      ref.invalidate(scheduleAnimeProvider);
    };

    return TabScaffold(
      topBar: const TopBar(canPop: false, title: "Schedule"),
      child: _Grid(scrollCtrl, onRefresh),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid(this.scrollCtrl, this.onRefresh);

  final ScrollController scrollCtrl;
  final void Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return PagedView<ScheduleAiringScheduleItem>(
        provider: scheduleAnimeProvider,
        scrollCtrl: scrollCtrl,
        onRefresh: onRefresh,
        onData: (data) => ScheduleMediaGrid(data.items),
      );
    });
  }
}
