import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/user/user_models.dart';
import 'package:otraku/user/friends_provider.dart';
import 'package:otraku/user/user_grid.dart';
import 'package:otraku/utils/paged_controller.dart';
import 'package:otraku/widgets/layouts/bottom_bar.dart';
import 'package:otraku/widgets/layouts/scaffolds.dart';
import 'package:otraku/widgets/layouts/direct_page_view.dart';
import 'package:otraku/widgets/layouts/top_bar.dart';
import 'package:otraku/widgets/paged_view.dart';

class FriendsView extends ConsumerStatefulWidget {
  const FriendsView(this.id);

  final int id;

  @override
  ConsumerState<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends ConsumerState<FriendsView> {
  late bool _onFollowing = true;
  late final _ctrl = PagedController(
    loadMore: () =>
        ref.read(friendsProvider(widget.id).notifier).fetch(_onFollowing),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(
      friendsProvider(widget.id).select((s) => s.getCount(_onFollowing)),
    );

    final onRefresh = () {
      ref.invalidate(friendsProvider(widget.id));
      return Future.value();
    };

    return PageScaffold(
      bottomBar: BottomBarIconTabs(
        current: _onFollowing ? 0 : 1,
        onChanged: (page) {
          setState(() => _onFollowing = page == 0 ? true : false);
        },
        onSame: (_) => _ctrl.scrollToTop(),
        items: const {
          'Following': Ionicons.people_circle,
          'Followers': Ionicons.person_circle,
        },
      ),
      child: TabScaffold(
        topBar: TopBar(
          title: _onFollowing ? 'Following' : 'Followers',
          trailing: [
            if (count > 0)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  count.toString(),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
          ],
        ),
        child: DirectPageView(
          current: _onFollowing ? 0 : 1,
          onChanged: (page) {
            setState(() => _onFollowing = page == 0 ? true : false);
          },
          children: [
            PagedView<UserItem>(
              provider: friendsProvider(widget.id).select((s) => s.following),
              onData: (data) => UserGrid(data.items),
              scrollCtrl: _ctrl,
              onRefresh: onRefresh,
              dataType: 'following',
            ),
            PagedView<UserItem>(
              provider: friendsProvider(widget.id).select((s) => s.followers),
              onData: (data) => UserGrid(data.items),
              scrollCtrl: _ctrl,
              onRefresh: onRefresh,
              dataType: 'followers',
            ),
          ],
        ),
      ),
    );
  }
}
