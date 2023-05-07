import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/modules/social/social_model.dart';
import 'package:otraku/modules/user/user_models.dart';
import 'package:otraku/modules/social/social_provider.dart';
import 'package:otraku/modules/user/user_grid.dart';
import 'package:otraku/common/utils/paged_controller.dart';
import 'package:otraku/common/widgets/layouts/bottom_bar.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/layouts/direct_page_view.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/paged_view.dart';

class SocialView extends ConsumerStatefulWidget {
  const SocialView(this.id);

  final int id;

  @override
  ConsumerState<SocialView> createState() => _SocialViewState();
}

class _SocialViewState extends ConsumerState<SocialView> {
  late SocialTab _tab = SocialTab.following;
  late final _ctrl = PagedController(
    loadMore: () => ref.read(socialProvider(widget.id).notifier).fetch(_tab),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(
      socialProvider(widget.id).select((s) => s.getCount(_tab)),
    );

    final onRefresh = () => ref.invalidate(socialProvider(widget.id));

    return PageScaffold(
      bottomBar: BottomNavBar(
        current: _tab.index,
        onChanged: (page) {
          setState(() => _tab = SocialTab.values.elementAt(page));
          _ctrl.scrollToTop();
        },
        onSame: (_) => _ctrl.scrollToTop(),
        items: const {
          'Following': Ionicons.people_circle,
          'Followers': Ionicons.person_circle,
        },
      ),
      child: TabScaffold(
        topBar: TopBar(
          title: _tab.title,
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
          current: _tab.index,
          onChanged: (page) {
            setState(() => _tab = SocialTab.values.elementAt(page));
            _ctrl.scrollToTop();
          },
          children: [
            PagedView<UserItem>(
              provider: socialProvider(widget.id).select((s) => s.following),
              onData: (data) => UserGrid(data.items),
              scrollCtrl: _ctrl,
              onRefresh: onRefresh,
            ),
            PagedView<UserItem>(
              provider: socialProvider(widget.id).select((s) => s.followers),
              onData: (data) => UserGrid(data.items),
              scrollCtrl: _ctrl,
              onRefresh: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}
