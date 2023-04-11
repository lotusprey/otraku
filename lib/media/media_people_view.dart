import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/media/media_providers.dart';
import 'package:otraku/common/relation.dart';
import 'package:otraku/widgets/grids/relation_grid.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/direct_page_view.dart';
import 'package:otraku/widgets/layouts/scaffolds.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/paged_view.dart';

class MediaPeopleView extends StatelessWidget {
  const MediaPeopleView(this.id, this.tabToggled, this.toggleTab);

  final int id;
  final bool tabToggled;
  final void Function(bool) toggleTab;

  @override
  Widget build(BuildContext context) {
    final scrollCtrl = context
        .findAncestorStateOfType<NestedScrollViewState>()!
        .innerController;

    return TabScaffold(
      floatingBar: FloatingBar(
        scrollCtrl: scrollCtrl,
        centered: true,
        children: [
          ActionTabSwitcher(
            items: const ['Characters', 'Staff'],
            current: tabToggled ? 1 : 0,
            onChanged: (i) => toggleTab(i == 1),
          ),
          if (tabToggled)
            const SizedBox(
                width: floatingBarItemHeight, height: floatingBarItemHeight)
          else
            _LanguageButton(id, scrollCtrl),
        ],
      ),
      child: DirectPageView(
        onChanged: null,
        current: tabToggled ? 1 : 0,
        children: [
          Consumer(
            builder: (context, ref, _) => PagedView<Relation>(
              provider: mediaRelationsProvider(id).select((s) => s.characters),
              onData: (data) => _CharacterGrid(id, ref, data.items),
              scrollCtrl: scrollCtrl,
              onRefresh: () => ref.invalidate(mediaRelationsProvider(id)),
            ),
          ),
          Consumer(
            builder: (context, ref, _) => PagedView<Relation>(
              provider: mediaRelationsProvider(id).select((s) => s.staff),
              onData: (data) => RelationGrid(items: data.items),
              scrollCtrl: scrollCtrl,
              onRefresh: () => ref.invalidate(mediaRelationsProvider(id)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton(this.id, this.scrollCtrl);

  final int id;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        if (ref.watch(mediaRelationsProvider(id).select(
          (s) => s.languages.length < 2,
        ))) return const SizedBox();

        return ActionButton(
          tooltip: 'Language',
          icon: Ionicons.globe_outline,
          onTap: () {
            final mediaRelations = ref.read(mediaRelationsProvider(id));
            final languages = mediaRelations.languages;
            final language = mediaRelations.language;

            showSheet(
              context,
              DynamicGradientDragSheet(
                onTap: (i) => ref
                    .read(mediaRelationsProvider(id).notifier)
                    .changeLanguage(languages.elementAt(i)),
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

class _CharacterGrid extends StatelessWidget {
  const _CharacterGrid(this.id, this.ref, this.items);

  final int id;
  final WidgetRef ref;
  final List<Relation> items;

  @override
  Widget build(BuildContext context) {
    final mediaRelations = ref.watch(mediaRelationsProvider(id));

    if (mediaRelations.languages.isEmpty) {
      return RelationGrid(items: items);
    }

    final characters = <Relation>[];
    final voiceActors = <Relation?>[];
    mediaRelations.getCharactersAndVoiceActors(characters, voiceActors);

    return RelationGrid(items: characters, connections: voiceActors);
  }
}
