import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/characters/character_media.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/models/relation.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/grids/relation_grid.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class CharacterMediaView extends StatelessWidget {
  const CharacterMediaView(this.id, this.scrollCtrl, this.ofAnime);

  final int id;
  final ScrollController scrollCtrl;
  final bool ofAnime;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        ref.listen<AsyncValue>(
          characterMediaProvider(id).select((s) => s.state),
          (_, s) {
            if (s.hasError)
              showPopUp(
                context,
                ConfirmationDialog(
                  title: 'Could not load notifications',
                  content: s.error.toString(),
                ),
              );
          },
        );

        final refreshControl = SliverRefreshControl(
          onRefresh: () {
            ref.invalidate(characterMediaProvider(id));
            return Future.value();
          },
        );

        return ref
            .watch(characterMediaProvider(id).select((s) => s.state))
            .when(
              loading: () => const Center(child: Loader()),
              error: (_, __) => CustomScrollView(
                slivers: [
                  refreshControl,
                  SliverFillRemaining(
                    child: Text(ofAnime ? 'No anime' : 'No manga'),
                  ),
                ],
              ),
              data: (_) => ofAnime
                  ? _AnimeTab(id, scrollCtrl, refreshControl)
                  : _MangaTab(id, scrollCtrl, refreshControl),
            );
      },
    );
  }
}

class _AnimeTab extends StatelessWidget {
  const _AnimeTab(this.id, this.scrollCtrl, this.refreshControl);

  final int id;
  final ScrollController scrollCtrl;
  final Widget refreshControl;

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      floatingBar: FloatingBar(
        scrollCtrl: scrollCtrl,
        children: [_LanguageButton(id), _FilterButton(id)],
      ),
      child: Consumer(
        builder: (context, ref, _) {
          final anime = <Relation>[];
          final voiceActors = <Relation?>[];
          final notifier = ref.watch(characterMediaProvider(id));
          notifier.getMediaAndVoiceActors(anime, voiceActors);

          return CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              refreshControl,
              RelationGrid(
                items: anime,
                connections: voiceActors,
                placeholder: 'No anime',
              ),
              SliverFooter(loading: notifier.anime.hasNext),
            ],
          );
        },
      ),
    );
  }
}

class _MangaTab extends StatelessWidget {
  const _MangaTab(this.id, this.scrollCtrl, this.refreshControl);

  final int id;
  final ScrollController scrollCtrl;
  final Widget refreshControl;

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      floatingBar: FloatingBar(
        scrollCtrl: scrollCtrl,
        children: [_FilterButton(id)],
      ),
      child: Consumer(
        builder: (context, ref, _) {
          final manga = ref.watch(
            characterMediaProvider(id).select((s) => s.manga),
          );

          return CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              refreshControl,
              RelationGrid(items: manga.items, placeholder: 'No manga'),
              SliverFooter(loading: manga.hasNext),
            ],
          );
        },
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final languages =
            ref.watch(characterMediaProvider(id).select((s) => s.languages));
        if (languages.isEmpty) return const SizedBox();

        final language =
            ref.watch(characterMediaProvider(id).select((s) => s.language));

        return ActionButton(
          tooltip: 'Language',
          icon: Ionicons.globe_outline,
          onTap: () {
            showSheet(
              context,
              DynamicGradientDragSheet(
                onTap: (i) =>
                    ref.read(characterMediaProvider(id)).language = language,
                children: [
                  for (int i = 0; i < languages.length; i++)
                    Text(
                      languages.elementAt(i),
                      style: languages.elementAt(i) != language
                          ? Theme.of(context).textTheme.headline1
                          : Theme.of(context).textTheme.headline1?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _FilterButton extends StatelessWidget {
  _FilterButton(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return ActionButton(
          icon: Ionicons.funnel_outline,
          tooltip: 'Filter',
          onTap: () {
            var filter = ref.read(characterFilterProvider(id));

            final sortItems = <String, int>{};
            for (int i = 0; i < MediaSort.values.length; i += 2) {
              String key = Convert.clarifyEnum(MediaSort.values[i].name)!;
              sortItems[key] = i ~/ 2;
            }

            final onDone = (_) =>
                ref.read(characterFilterProvider(id).notifier).state = filter;

            showSheet(
              context,
              OpaqueSheet(
                initialHeight: Consts.tapTargetSize * 4,
                builder: (context, scrollCtrl) => GridView(
                  controller: scrollCtrl,
                  physics: Consts.physics,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 20,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithMinWidthAndFixedHeight(
                    minWidth: 155,
                    height: 75,
                  ),
                  children: [
                    DropDownField<int>(
                      title: 'Sort',
                      value: filter.sort.index ~/ 2,
                      items: sortItems,
                      onChanged: (val) {
                        int index = val * 2;
                        if (filter.sort.index % 2 != 0) index++;
                        filter = filter.copyWith(sort: MediaSort.values[index]);
                      },
                    ),
                    DropDownField<bool>(
                      title: 'Order',
                      value: filter.sort.index % 2 == 0,
                      items: const {'Ascending': true, 'Descending': false},
                      onChanged: (val) {
                        int index = filter.sort.index;
                        if (!val && index % 2 == 0) {
                          index++;
                        } else if (val && index % 2 != 0) {
                          index--;
                        }
                        filter = filter.copyWith(sort: MediaSort.values[index]);
                      },
                    ),
                    DropDownField<bool?>(
                      title: 'List Filter',
                      value: filter.onList,
                      items: const {
                        'Everything': null,
                        'On List': true,
                        'Not On List': false,
                      },
                      onChanged: (val) =>
                          filter = filter.copyWith(onList: () => val),
                    ),
                  ],
                ),
              ),
            ).then(onDone);
          },
        );
      },
    );
  }
}
