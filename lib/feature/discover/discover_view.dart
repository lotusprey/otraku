import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/feature/character/character_item_grid.dart';
import 'package:otraku/feature/discover/discover_filter_provider.dart';
import 'package:otraku/feature/discover/discover_media_grid.dart';
import 'package:otraku/feature/discover/discover_media_simple_grid.dart';
import 'package:otraku/feature/discover/discover_model.dart';
import 'package:otraku/feature/discover/discover_provider.dart';
import 'package:otraku/feature/staff/staff_item_grid.dart';
import 'package:otraku/feature/studio/studio_item_grid.dart';
import 'package:otraku/feature/user/user_item_grid.dart';
import 'package:otraku/feature/review/review_grid.dart';
import 'package:otraku/feature/viewer/persistence_provider.dart';
import 'package:otraku/widget/input/pill_selector.dart';
import 'package:otraku/widget/paged_view.dart';

class DiscoverSubview extends StatelessWidget {
  const DiscoverSubview(this.scrollCtrl, this.compact);

  final ScrollController scrollCtrl;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final options = ref.watch(persistenceProvider.select((s) => s.options));
        final type = ref.watch(discoverFilterProvider.select((s) => s.type));
        final onRefresh = (invalidate) => invalidate(discoverProvider);

        final content = switch (type) {
          DiscoverType.anime => PagedView(
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              provider: discoverProvider.select(
                (s) => s.whenData((data) => (data as DiscoverAnimeItems).pages),
              ),
              onData: (data) =>
                  options.discoverItemView == DiscoverItemView.simple
                      ? DiscoverMediaSimpleGrid(data.items)
                      : DiscoverMediaGrid(data.items),
            ),
          DiscoverType.manga => PagedView(
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              provider: discoverProvider.select(
                (s) => s.whenData((data) => (data as DiscoverMangaItems).pages),
              ),
              onData: (data) =>
                  options.discoverItemView == DiscoverItemView.simple
                      ? DiscoverMediaSimpleGrid(data.items)
                      : DiscoverMediaGrid(data.items),
            ),
          DiscoverType.character => PagedView(
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              provider: discoverProvider.select(
                (s) => s.whenData(
                  (data) => (data as DiscoverCharacterItems).pages,
                ),
              ),
              onData: (data) => CharacterItemGrid(data.items),
            ),
          DiscoverType.staff => PagedView(
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              provider: discoverProvider.select(
                (s) => s.whenData((data) => (data as DiscoverStaffItems).pages),
              ),
              onData: (data) => StaffItemGrid(data.items),
            ),
          DiscoverType.studio => PagedView(
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              provider: discoverProvider.select(
                (s) => s.whenData(
                  (data) => (data as DiscoverStudioItems).pages,
                ),
              ),
              onData: (data) => StudioItemGrid(data.items),
            ),
          DiscoverType.user => PagedView(
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              provider: discoverProvider.select(
                (s) => s.whenData((data) => (data as DiscoverUserItems).pages),
              ),
              onData: (data) => UserItemGrid(data.items),
            ),
          DiscoverType.review => PagedView(
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              provider: discoverProvider.select(
                (s) => s.whenData(
                  (data) => (data as DiscoverReviewItems).pages,
                ),
              ),
              onData: (data) => ReviewGrid(data.items),
            ),
        };

        if (compact) return content;

        return Row(
          children: [
            PillSelector(
              selected: type.index,
              maxWidth: 130,
              items: DiscoverType.values.map((v) => Text(v.label)).toList(),
              onTap: (i) => ref.read(discoverFilterProvider.notifier).update(
                    (s) => s.copyWith(type: DiscoverType.values[i]),
                  ),
            ),
            Expanded(child: content),
          ],
        );
      },
    );
  }
}
