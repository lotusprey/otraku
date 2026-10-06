import 'package:flutter/widgets.dart';
import 'package:otraku/feature/forum/thread_item_list.dart';
import 'package:otraku/feature/media/media_provider.dart';
import 'package:otraku/widget/paged_view.dart';

class MediaThreadsSubview extends StatefulWidget {
  const MediaThreadsSubview({
    required this.id,
    required this.scrollCtrl,
    required this.highContrast,
    required this.analogClock,
  });

  final int id;
  final ScrollController scrollCtrl;
  final bool highContrast;
  final bool analogClock;

  @override
  State<MediaThreadsSubview> createState() => _MediaThreadsSubviewState();
}

class _MediaThreadsSubviewState extends State<MediaThreadsSubview>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PagedView(
      scrollCtrl: widget.scrollCtrl,
      onRefresh: (invalidate) => invalidate(mediaThreadsProvider(widget.id)),
      provider: mediaThreadsProvider(widget.id),
      onData: (data) => ThreadItemList(data.items, widget.highContrast, widget.analogClock),
    );
  }
}
