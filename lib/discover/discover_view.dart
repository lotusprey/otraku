import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/character/character_grid.dart';
import 'package:otraku/character/character_models.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/discover/discover_providers.dart';
import 'package:otraku/filter/filter_providers.dart';
import 'package:otraku/filter/filter_view.dart';
import 'package:otraku/media/media_grid.dart';
import 'package:otraku/media/media_item.dart';
import 'package:otraku/review/review_models.dart';
import 'package:otraku/review/review_providers.dart';
import 'package:otraku/staff/staff_grid.dart';
import 'package:otraku/staff/staff_models.dart';
import 'package:otraku/studio/studio_grid.dart';
import 'package:otraku/studio/studio_models.dart';
import 'package:otraku/user/user_grid.dart';
import 'package:otraku/user/user_models.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/review/review_grid.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/filter/filter_tools.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/pagination_view.dart';

class DiscoverView extends ConsumerWidget {
  const DiscoverView(this.scrollCtrl);

  final PaginationController scrollCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onRefresh = () {
      final type = ref.read(discoverTypeProvider);
      switch (type) {
        case DiscoverType.anime:
          ref.invalidate(discoverAnimeProvider);
          break;
        case DiscoverType.manga:
          ref.invalidate(discoverMangaProvider);
          break;
        case DiscoverType.character:
          ref.invalidate(discoverCharacterProvider);
          break;
        case DiscoverType.staff:
          ref.invalidate(discoverStaffProvider);
          break;
        case DiscoverType.studio:
          ref.invalidate(discoverStudioProvider);
          break;
        case DiscoverType.user:
          ref.invalidate(discoverUserProvider);
          break;
        case DiscoverType.review:
          ref.invalidate(discoverReviewProvider);
          break;
      }
      return Future.value();
    };

    return PageLayout(
      topBar: const PreferredSize(
        preferredSize: Size.fromHeight(Consts.tapTargetSize),
        child: _TopBar(),
      ),
      floatingBar: FloatingBar(
        scrollCtrl: scrollCtrl,
        children: const [_ActionButton()],
      ),
      child: _Grid(scrollCtrl, onRefresh),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final type = ref.watch(discoverTypeProvider);

        return TopBar(
          canPop: false,
          items: [
            SearchFilterField(
              title: Convert.clarifyEnum(type.name)!,
              enabled: type != DiscoverType.review,
            ),
            if (type == DiscoverType.anime || type == DiscoverType.manga)
              TopBarIcon(
                tooltip: 'Filter',
                icon: Ionicons.funnel_outline,
                onTap: () {
                  final ofAnime = type == DiscoverType.anime;
                  final notifier = ref.read(
                    discoverFilterProvider(ofAnime).notifier,
                  );

                  showSheet(
                    context,
                    DiscoverFilterView(
                      filter: notifier.state,
                      onChanged: (filter) => notifier.state = filter,
                    ),
                  );
                },
              )
            else if (type == DiscoverType.character ||
                type == DiscoverType.staff)
              _BirthdayFilter(ref)
            else if (type == DiscoverType.review)
              TopBarIcon(
                tooltip: 'Sort',
                icon: Ionicons.funnel_outline,
                onTap: () {
                  final notifier = ref.read(reviewSortProvider(null).notifier);
                  final theme = Theme.of(context);

                  showSheet(
                    context,
                    DynamicGradientDragSheet(
                      onTap: (i) =>
                          notifier.state = ReviewSort.values.elementAt(i),
                      children: [
                        for (int i = 0; i < ReviewSort.values.length; i++)
                          Text(
                            ReviewSort.values.elementAt(i).text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: i != notifier.state.index
                                ? theme.textTheme.headline1
                                : theme.textTheme.headline1?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                          ),
                      ],
                    ),
                  );
                },
              )
            else
              const SizedBox(width: 10),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final type = ref.watch(discoverTypeProvider);

        return ActionButton(
          tooltip: 'Types',
          icon: type.icon,
          onTap: () {
            final theme = Theme.of(context);

            showSheet(
              context,
              DynamicGradientDragSheet(
                onTap: (i) => ref.read(discoverTypeProvider.notifier).state =
                    DiscoverType.values[i],
                children: [
                  for (int i = 0; i < DiscoverType.values.length; i++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          DiscoverType.values[i].icon,
                          color: i != type.index
                              ? Theme.of(context).colorScheme.onBackground
                              : Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          Convert.clarifyEnum(DiscoverType.values[i].name)!,
                          style: i != type.index
                              ? theme.textTheme.headline1
                              : theme.textTheme.headline1?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
          onSwipe: (goRight) {
            final notifier = ref.read(discoverTypeProvider.notifier);

            if (goRight) {
              if (type.index < DiscoverType.values.length - 1) {
                notifier.state = DiscoverType.values.elementAt(
                  type.index + 1,
                );
              } else {
                notifier.state = DiscoverType.values.first;
              }
            } else {
              if (type.index > 0) {
                notifier.state = DiscoverType.values.elementAt(
                  type.index - 1,
                );
              } else {
                notifier.state = DiscoverType.values.last;
              }
            }

            return type.icon;
          },
        );
      },
    );
  }
}

class _BirthdayFilter extends StatelessWidget {
  const _BirthdayFilter(this.ref);

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(birthdayFilterProvider);

    return TopBarIcon(
      icon: Icons.cake_outlined,
      tooltip: 'Birthday Filter',
      color: value ? Theme.of(context).colorScheme.primary : null,
      onTap: () => ref.read(birthdayFilterProvider.notifier).state = !value,
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid(this.scrollCtrl, this.onRefresh);

  final ScrollController scrollCtrl;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final type = ref.watch(discoverTypeProvider);

        switch (type) {
          case DiscoverType.anime:
            return PaginationView<MediaItem>(
              provider: discoverAnimeProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              dataType: 'anime',
              onData: (data) => MediaGrid(data.items),
            );
          case DiscoverType.manga:
            return PaginationView<MediaItem>(
              provider: discoverMangaProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              dataType: 'manga',
              onData: (data) => MediaGrid(data.items),
            );
          case DiscoverType.character:
            return PaginationView<CharacterItem>(
              provider: discoverCharacterProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              dataType: 'characters',
              onData: (data) => CharacterGrid(data.items),
            );
          case DiscoverType.staff:
            return PaginationView<StaffItem>(
              provider: discoverStaffProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              dataType: 'staff',
              onData: (data) => StaffGrid(data.items),
            );
          case DiscoverType.studio:
            return PaginationView<StudioItem>(
              provider: discoverStudioProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              dataType: 'studios',
              onData: (data) => StudioGrid(data.items),
            );
          case DiscoverType.user:
            return PaginationView<UserItem>(
              provider: discoverUserProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              dataType: 'users',
              onData: (data) => UserGrid(data.items),
            );
          case DiscoverType.review:
            return PaginationView<ReviewItem>(
              provider: discoverReviewProvider,
              scrollCtrl: scrollCtrl,
              onRefresh: onRefresh,
              dataType: 'reviews',
              onData: (data) => ReviewGrid(data.items),
            );
        }
      },
    );
  }
}
