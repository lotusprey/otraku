import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/grid/dual_relation_grid.dart';
import 'package:otraku/widget/paged_view.dart';
import 'package:otraku/feature/media/media_provider.dart';
import 'package:otraku/widget/shadowed_overflow_list.dart';

class MediaCharactersSubview extends StatelessWidget {
  const MediaCharactersSubview({
    required this.id,
    required this.scrollCtrl,
    required this.highContrast,
  });

  final int id;
  final ScrollController scrollCtrl;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    return PagedView<(MediaRelatedItem, MediaRelatedItem?)>(
      scrollCtrl: scrollCtrl,
      onRefresh: (invalidate) => invalidate(mediaConnectionsProvider(id)),
      provider: mediaConnectionsProvider(
        id,
      ).select((s) => s.unwrapPrevious().whenData((data) => data.getCharactersAndVoiceActors())),
      onData: (data) {
        return SliverMainAxisGroup(
          slivers: [
            _LanguageSelector(id),
            DualRelationGrid(
              items: data.items,
              onTapPrimary: (item) =>
                  context.push(Routes.character(item.tileId, item.tileImageUrl)),
              onTapSecondary: (item) => context.push(Routes.staff(item.tileId, item.tileImageUrl)),
              highContrast: highContrast,
            ),
          ],
        );
      },
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final selection = ref.watch(
          mediaConnectionsProvider(id).select((s) {
            final value = s.value;
            if (value == null) return null;
            return (value.languageToVoiceActors, value.selectedLanguage);
          }),
        );

        if (selection == null) return const SliverToBoxAdapter();

        final languageMappings = selection.$1;
        final selectedLanguage = selection.$2;

        if (languageMappings.length < 2) return const SliverToBoxAdapter();

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

                  ref.read(mediaConnectionsProvider(id).notifier).changeLanguage(i);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
