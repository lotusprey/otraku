import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/forum/forum_filter_provider.dart';
import 'package:otraku/feature/forum/forum_filter_view.dart';
import 'package:otraku/feature/forum/forum_provider.dart';
import 'package:otraku/feature/forum/thread_item_list.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/debounce.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/widget/input/search_field.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
import 'package:otraku/widget/layout/top_bar.dart';
import 'package:otraku/widget/paged_view.dart';

class ForumView extends ConsumerStatefulWidget {
  const ForumView();

  @override
  ConsumerState<ForumView> createState() => _ForumViewState();
}

class _ForumViewState extends ConsumerState<ForumView> {
  late final _scrollCtrl = PagedController(
    loadMore: () => ref.read(forumProvider.notifier).fetch(),
  );

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analogClock = ref.watch(
      persistenceProvider.select((s) => s.options.analogClock),
    );

    return AdaptiveScaffold(
      topBar: TopBar(trailing: [
        Consumer(
          builder: (context, ref, filterButton) {
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: SearchField(
                      debounce: Debounce(),
                      hint: 'Forum',
                      value: ref
                          .watch(forumFilterProvider.select((s) => s.search)),
                      onChanged: (search) => ref
                          .read(forumFilterProvider.notifier)
                          .update((s) => s.copyWith(search: search.trim())),
                    ),
                  ),
                  filterButton!,
                ],
              ),
            );
          },
          child: IconButton(
            tooltip: 'Filter',
            icon: const Icon(Ionicons.funnel_outline),
            onPressed: () => showForumFilterSheet(context, ref),
          ),
        ),
      ]),
      child: PagedView(
        provider: forumProvider,
        scrollCtrl: _scrollCtrl,
        onRefresh: (invalidate) => invalidate(forumProvider),
        onData: (data) => ThreadItemList(data.items, analogClock),
      ),
    );
  }
}
