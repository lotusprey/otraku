import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/users/friends.dart';
import 'package:otraku/users/user_grid.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/loaders.dart/sliver_loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class FriendsView extends ConsumerStatefulWidget {
  const FriendsView(this.id, this.onFollowing);

  final int id;
  final bool onFollowing;

  @override
  ConsumerState<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends ConsumerState<FriendsView> {
  late final PaginationController _ctrl;
  late bool _onFollowing;

  @override
  void initState() {
    super.initState();
    _onFollowing = widget.onFollowing;
    _ctrl = PaginationController(
      loadMore: () => ref.read(friendsProvider(widget.id).notifier).fetch(),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late final int count;
    if (_onFollowing) {
      count = ref.watch(
        friendsProvider(widget.id).select((s) => s.followingCount),
      );
    } else {
      count = ref.watch(
        friendsProvider(widget.id).select((s) => s.followersCount),
      );
    }

    return PageLayout(
      topBar: TopBar(
        title: _onFollowing ? 'Following' : 'Followers',
        items: [
          if (count > 0)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                count.toString(),
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
        ],
      ),
      bottomBar: BottomBarIconTabs(
        index: _onFollowing ? 0 : 1,
        onChanged: (page) {
          setState(() => _onFollowing = page == 0 ? true : false);
          _ctrl.scrollUpTo(0);
        },
        onSame: (_) => _ctrl.scrollUpTo(0),
        items: const {
          'Following': Ionicons.people_circle,
          'Followers': Ionicons.person_circle,
        },
      ),
      builder: (context, topOffset, bottomOffset) => Consumer(
        child: SliverRefreshControl(
          onRefresh: () {
            ref.invalidate(friendsProvider(widget.id));
            return Future.value();
          },
        ),
        builder: (context, ref, refreshControl) {
          ref.listen<FriendsNotifier>(
            friendsProvider(widget.id),
            (_, s) {
              final users = _onFollowing ? s.following : s.followers;
              users.whenOrNull(
                error: (error, _) => showPopUp(
                  context,
                  ConfirmationDialog(
                    title: 'Could not load users',
                    content: error.toString(),
                  ),
                ),
              );
            },
          );

          const empty = Center(child: Text('No Users'));

          final provider = ref.watch(friendsProvider(widget.id));
          final users = _onFollowing ? provider.following : provider.followers;
          return users.maybeWhen(
              loading: () => const Center(child: Loader()),
              orElse: () => empty,
              data: (data) {
                if (data.items.isEmpty) return empty;

                return Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: Consts.layoutBig),
                    child: CustomScrollView(
                      physics: Consts.physics,
                      controller: _ctrl,
                      slivers: [
                        refreshControl!,
                        UserGrid(data.items),
                        SliverFooter(loading: data.hasNext),
                      ],
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
}
