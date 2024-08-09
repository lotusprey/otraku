import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/model/relation.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/grids/relation_grid.dart';
import 'package:otraku/widget/paged_view.dart';
import 'package:otraku/feature/character/character_provider.dart';
import 'package:otraku/widget/shadowed_overflow_list.dart';

class CharacterAnimeSubview extends StatelessWidget {
  const CharacterAnimeSubview({required this.id, required this.scrollCtrl});

  final int id;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return PagedView<(Relation, Relation?)>(
      scrollCtrl: scrollCtrl,
      onRefresh: (invalidate) => invalidate(characterMediaProvider(id)),
      provider: characterMediaProvider(id).select(
        (s) => s
            .unwrapPrevious()
            .whenData((data) => data.assembleAnimeWithVoiceActors()),
      ),
      onData: (data) {
        return SliverMainAxisGroup(
          slivers: [
            _LanguageSelected(id),
            RelationGrid(data.items),
          ],
        );
      },
    );
  }
}

class _LanguageSelected extends StatelessWidget {
  const _LanguageSelected(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final selection = ref.watch(characterMediaProvider(id).select((s) {
          final value = s.valueOrNull;
          if (value == null) return null;
          return (value.languageToVoiceActors, value.selectedLanguage);
        }));

        if (selection == null) return const SliverToBoxAdapter();

        final languageMappings = selection.$1;
        final selectedLanguage = selection.$2;

        return SliverToBoxAdapter(
          child: SizedBox(
            height: Theming.normalTapTarget,
            child: ShadowedOverflowList(
              itemCount: languageMappings.length,
              itemBuilder: (context, i) => FilterChip(
                label: Text(languageMappings[i].language),
                selected: i == selectedLanguage,
                onSelected: (selected) {
                  if (!selected) return;

                  ref
                      .read(characterMediaProvider(id).notifier)
                      .changeLanguage(i);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
