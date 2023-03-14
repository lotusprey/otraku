import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/character/character_providers.dart';
import 'package:otraku/filter/chip_selector.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/media/media_constants.dart';
import 'package:otraku/common/relation.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/grids/relation_grid.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/scaffolds.dart';
import 'package:otraku/widgets/layouts/top_bar.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class CharacterAnimeTab extends StatelessWidget {
  const CharacterAnimeTab(this.id, this.scrollCtrl, this.topBar);

  final int id;
  final ScrollController scrollCtrl;
  final TopBar topBar;

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      topBar: topBar,
      floatingBar: FloatingBar(
        scrollCtrl: scrollCtrl,
        children: [_FilterButton(id), _LanguageButton(id)],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Consts.layoutBig),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Consumer(
              builder: (context, ref, _) {
                ref.listen<AsyncValue>(
                  characterMediaProvider(id).select((s) => s.anime),
                  (_, s) {
                    if (s.hasError) {
                      showPopUp(
                        context,
                        ConfirmationDialog(
                          title: 'Failed to load anime',
                          content: s.error.toString(),
                        ),
                      );
                    }
                  },
                );

                final refreshControl = SliverRefreshControl(
                  onRefresh: () => ref.invalidate(characterMediaProvider(id)),
                );

                return ref.watch(characterMediaProvider(id)).anime.when(
                      loading: () => const Center(child: Loader()),
                      error: (_, __) => CustomScrollView(
                        physics: Consts.physics,
                        slivers: [
                          refreshControl,
                          const SliverFillRemaining(
                            child: Text('Failed to load anime'),
                          ),
                        ],
                      ),
                      data: (data) {
                        final anime = <Relation>[];
                        final voiceActors = <Relation?>[];
                        ref
                            .watch(characterMediaProvider(id).notifier)
                            .getAnimeAndVoiceActors(anime, voiceActors);

                        return CustomScrollView(
                          controller: scrollCtrl,
                          physics: Consts.physics,
                          slivers: [
                            refreshControl,
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 10),
                            ),
                            RelationGrid(
                              items: anime,
                              connections: voiceActors,
                              placeholder: 'No anime',
                            ),
                            SliverFooter(loading: data.hasNext),
                          ],
                        );
                      },
                    );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CharacterMangaTab extends StatelessWidget {
  const CharacterMangaTab(this.id, this.scrollCtrl, this.topBar);

  final int id;
  final ScrollController scrollCtrl;
  final TopBar topBar;

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      topBar: topBar,
      floatingBar: FloatingBar(
        scrollCtrl: scrollCtrl,
        children: [_FilterButton(id)],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Consts.layoutBig),
            child: Consumer(
              builder: (context, ref, _) {
                ref.listen<AsyncValue>(
                  characterMediaProvider(id).select((s) => s.manga),
                  (_, s) {
                    if (s.hasError) {
                      showPopUp(
                        context,
                        ConfirmationDialog(
                          title: 'Failed to load manga',
                          content: s.error.toString(),
                        ),
                      );
                    }
                  },
                );

                final refreshControl = SliverRefreshControl(
                  onRefresh: () => ref.invalidate(characterMediaProvider(id)),
                );

                return ref.watch(characterMediaProvider(id)).manga.when(
                      loading: () => const Center(child: Loader()),
                      error: (_, __) => CustomScrollView(
                        physics: Consts.physics,
                        slivers: [
                          refreshControl,
                          const SliverFillRemaining(
                            child: Text('Failed to load manga'),
                          ),
                        ],
                      ),
                      data: (data) {
                        return CustomScrollView(
                          controller: scrollCtrl,
                          physics: Consts.physics,
                          slivers: [
                            refreshControl,
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 10),
                            ),
                            RelationGrid(
                              items: data.items,
                              placeholder: 'No manga',
                            ),
                            SliverFooter(loading: data.hasNext),
                          ],
                        );
                      },
                    );
              },
            ),
          ),
        ),
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
        if (ref.watch(characterMediaProvider(id).select(
          (s) => s.languages.isEmpty,
        ))) return const SizedBox();

        return ActionButton(
          tooltip: 'Language',
          icon: Ionicons.globe_outline,
          onTap: () {
            final notifier = ref.read(characterMediaProvider(id));
            final languages = notifier.languages;
            final language = notifier.language;

            showSheet(
              context,
              DynamicGradientDragSheet(
                onTap: (i) {
                  ref.read(characterMediaProvider(id)).language =
                      languages.elementAt(i);
                },
                children: [
                  for (int i = 0; i < languages.length; i++)
                    Text(
                      languages.elementAt(i),
                      style: languages.elementAt(i) != language
                          ? Theme.of(context).textTheme.titleLarge
                          : Theme.of(context).textTheme.titleLarge?.copyWith(
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
  const _FilterButton(this.id);

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
                builder: (context, scrollCtrl) => ListView(
                  controller: scrollCtrl,
                  physics: Consts.physics,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  children: [
                    ChipSelector(
                      title: 'Sort',
                      options: MediaSort.values.map((s) => s.label).toList(),
                      selected: filter.sort.index,
                      mustHaveSelected: true,
                      onChanged: (i) => filter = filter.copyWith(
                        sort: MediaSort.values.elementAt(i!),
                      ),
                    ),
                    ChipSelector(
                      title: 'List Presence',
                      options: const ['On List', 'Not on List'],
                      selected: filter.onList == null
                          ? null
                          : filter.onList!
                              ? 0
                              : 1,
                      onChanged: (val) => filter = filter.copyWith(onList: () {
                        if (val == null) return null;
                        return val == 0 ? true : false;
                      }),
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
