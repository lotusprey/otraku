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
import 'package:otraku/util/persistence.dart';
import 'package:otraku/widget/field/pill_selector.dart';
import 'package:otraku/widget/paged_view.dart';

class DiscoverSubview extends StatelessWidget {
  const DiscoverSubview(this.scrollCtrl, this.compact);

  final ScrollController scrollCtrl;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final type = ref.watch(discoverFilterProvider.select((s) => s.type));
        final onRefresh = (invalidate) => invalidate(discoverProvider);

        final content = switch (type) {
          DiscoverType.anime => PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverAnimeItems).pages,
              onData: (data) => Persistence().discoverItemView == 0
                  ? DiscoverMediaGrid(data.items)
                  : DiscoverMediaSimpleGrid(data.items),
            ),
          DiscoverType.manga => PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverMangaItems).pages,
              onData: (data) => Persistence().discoverItemView == 0
                  ? DiscoverMediaGrid(data.items)
                  : DiscoverMediaSimpleGrid(data.items),
            ),
          DiscoverType.character => PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverCharacterItems).pages,
              onData: (data) => CharacterItemGrid(data.items),
            ),
          DiscoverType.staff => PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverStaffItems).pages,
              onData: (data) => StaffItemGrid(data.items),
            ),
          DiscoverType.studio => PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverStudioItems).pages,
              onData: (data) => StudioItemGrid(data.items),
            ),
          DiscoverType.user => PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverUserItems).pages,
              onData: (data) => UserItemGrid(data.items),
            ),
          DiscoverType.review => PagedSelectionView(
              provider: discoverProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              select: (data) => (data as DiscoverReviewItems).pages,
              onData: (data) => ReviewGrid(data.items),
            ),
        };

        if (compact) return content;

        return Row(
          children: [
            PillSelector(
              selected: type.index,
              maxWidth: 130,
              onTap: (i) => ref.read(discoverFilterProvider.notifier).update(
                    (s) => s.copyWith(type: DiscoverType.values[i]),
                  ),
              items: DiscoverType.values
                  .map((v) => (title: Text(v.label), subtitle: null))
                  .toList(),
            ),
            Expanded(child: content),
          ],
        );
      },
    );
  }
}
