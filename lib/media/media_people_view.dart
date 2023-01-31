import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/media/media_providers.dart';
import 'package:otraku/common/relation.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/widgets/grids/relation_grid.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/layouts/direct_page_view.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

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

    return PageLayout(
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
            const SizedBox(width: actionButtonSize, height: actionButtonSize)
          else
            _LanguageButton(id, scrollCtrl),
        ],
      ),
      child: DirectPageView(
        onChanged: null,
        current: tabToggled ? 1 : 0,
        children: [
          Consumer(
            child: SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            builder: (context, ref, overlapInjector) {
              return ref
                  .watch(mediaContentProvider(id).select((s) => s.characters))
                  .when(
                    loading: () => const Center(child: Loader()),
                    error: (_, __) => const Center(
                      child: Text('Failed to load characters'),
                    ),
                    data: (data) => CustomScrollView(
                      controller: scrollCtrl,
                      slivers: [
                        overlapInjector!,
                        SliverPadding(
                          padding: const EdgeInsets.only(
                            top: 10,
                            left: 10,
                            right: 10,
                          ),
                          sliver: _CharacterGrid(id, ref, data.items),
                        ),
                        SliverFooter(loading: data.hasNext),
                      ],
                    ),
                  );
            },
          ),
          Consumer(
            child: SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            builder: (context, ref, overlapInjector) {
              return ref
                  .watch(mediaContentProvider(id).select((s) => s.staff))
                  .when(
                    loading: () => const Center(child: Loader()),
                    error: (_, __) => const Center(
                      child: Text('Failed to load staff'),
                    ),
                    data: (data) => CustomScrollView(
                      controller: scrollCtrl,
                      slivers: [
                        overlapInjector!,
                        SliverPadding(
                          padding: const EdgeInsets.only(
                            top: 10,
                            left: 10,
                            right: 10,
                          ),
                          sliver: RelationGrid(
                            placeholder: 'No Staff',
                            items: data.items,
                          ),
                        ),
                        SliverFooter(loading: data.hasNext),
                      ],
                    ),
                  );
            },
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
        final notifier = ref.watch(mediaContentProvider(id));
        if (notifier.languages.length < 2) return const SizedBox();

        return ActionButton(
          tooltip: 'Language',
          icon: Ionicons.globe_outline,
          onTap: () => showSheet(
            context,
            DynamicGradientDragSheet(
              onTap: (i) {
                scrollCtrl.scrollToTop();
                ref.read(mediaContentProvider(id)).languageIndex = i;
              },
              children: [
                for (int i = 0; i < notifier.languages.length; i++)
                  Text(
                    notifier.languages[i],
                    style: i != notifier.languageIndex
                        ? Theme.of(context).textTheme.titleLarge
                        : Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                  ),
              ],
            ),
          ),
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
    final notifier = ref.watch(mediaContentProvider(id));

    if (notifier.languages.isEmpty) {
      return RelationGrid(placeholder: 'No Characters', items: items);
    }

    final characters = <Relation>[];
    final voiceActors = <Relation?>[];
    notifier.selectCharactersAndVoiceActors(characters, voiceActors);

    return RelationGrid(
      placeholder: 'No Characters',
      items: characters,
      connections: voiceActors,
    );
  }
}
