import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/extension/scroll_controller_extension.dart';
import 'package:otraku/feature/comment/comment_model.dart';
import 'package:otraku/feature/comment/comment_tile.dart';
import 'package:otraku/feature/forum/thread_item_list.dart';
import 'package:otraku/feature/social/social_model.dart';
import 'package:otraku/feature/social/social_provider.dart';
import 'package:otraku/feature/user/user_item_grid.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/util/paged_controller.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layout/adaptive_scaffold.dart';
import 'package:otraku/widget/layout/top_bar.dart';
import 'package:otraku/widget/paged_view.dart';

class SocialView extends ConsumerStatefulWidget {
  const SocialView(this.id);

  final int id;

  @override
  ConsumerState<SocialView> createState() => _SocialViewState();
}

class _SocialViewState extends ConsumerState<SocialView>
    with SingleTickerProviderStateMixin {
  late final _tabCtrl = TabController(
    length: SocialTab.values.length,
    vsync: this,
  );
  late final _scrollCtrl = PagedController(
    loadMore: () => ref
        .read(socialProvider(widget.id).notifier)
        .fetch(SocialTab.values[_tabCtrl.index]),
  );

  @override
  void initState() {
    super.initState();
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tab = SocialTab.values[_tabCtrl.index];

    final viewerId = ref.watch(viewerIdProvider);
    final analogClock = ref.watch(
      persistenceProvider.select((s) => s.options.analogClock),
    );

    final count = ref.watch(
      socialProvider(widget.id).select(
        (s) => s.valueOrNull?.getCount(tab) ?? 0,
      ),
    );

    final onRefresh = (invalidate) => invalidate(socialProvider(widget.id));

    return AdaptiveScaffold(
      topBar: TopBarAnimatedSwitcher(
        TopBar(
          key: Key('${tab.title}TopBar'),
          title: tab.title,
          trailing: [
            if (count > 0)
              Padding(
                padding: const EdgeInsets.only(right: Theming.offset),
                child: Text(
                  count.toString(),
                  style: TextTheme.of(context).titleSmall,
                ),
              ),
          ],
        ),
      ),
      navigationConfig: NavigationConfig(
        selected: _tabCtrl.index,
        onChanged: (i) => _tabCtrl.index = i,
        onSame: (_) => _scrollCtrl.scrollToTop(),
        items: {
          SocialTab.following.title: Ionicons.people_circle,
          SocialTab.followers.title: Ionicons.person_circle,
          SocialTab.threads.title: Ionicons.chatbubble_outline,
          SocialTab.comments.title: Ionicons.chatbubbles_outline,
        },
      ),
      child: TabBarView(
        controller: _tabCtrl,
        children: [
          PagedView(
            scrollCtrl: _scrollCtrl,
            onRefresh: onRefresh,
            provider: socialProvider(widget.id).select(
              (s) => s.unwrapPrevious().whenData((data) => data.following),
            ),
            onData: (data) => UserItemGrid(data.items),
          ),
          PagedView(
            scrollCtrl: _scrollCtrl,
            onRefresh: onRefresh,
            provider: socialProvider(widget.id).select(
              (s) => s.unwrapPrevious().whenData((data) => data.followers),
            ),
            onData: (data) => UserItemGrid(data.items),
          ),
          PagedView(
            scrollCtrl: _scrollCtrl,
            onRefresh: onRefresh,
            provider: socialProvider(widget.id).select(
              (s) => s.unwrapPrevious().whenData((data) => data.threads),
            ),
            onData: (data) => ThreadItemList(data.items, analogClock),
          ),
          PagedView(
            scrollCtrl: _scrollCtrl,
            onRefresh: onRefresh,
            provider: socialProvider(widget.id).select(
              (s) => s.unwrapPrevious().whenData((data) => data.comments),
            ),
            onData: (data) => _CommentItemList(
              data.items,
              viewerId,
              analogClock,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentItemList extends StatelessWidget {
  const _CommentItemList(this.items, this.viewerId, this.analogClock);

  final List<Comment> items;
  final int? viewerId;
  final bool analogClock;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];

        final openThread = () => context.push(Routes.thread(item.threadId));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              onTap: openThread,
              onTapHint: 'open thread',
              child: GestureDetector(
                onTap: openThread,
                behavior: HitTestBehavior.opaque,
                child: Text(
                  item.threadTitle,
                  style: TextTheme.of(context).titleMedium,
                ),
              ),
            ),
            const SizedBox(height: Theming.offset),
            CommentTile(item, viewerId: viewerId, analogClock: analogClock),
            const SizedBox(height: Theming.offset),
          ],
        );
      },
    );
  }
}
