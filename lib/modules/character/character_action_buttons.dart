import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/modules/character/character_filter_provider.dart';
import 'package:otraku/modules/character/character_models.dart';
import 'package:otraku/modules/character/character_provider.dart';
import 'package:otraku/modules/filter/chip_selector.dart';
import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/widgets/layouts/floating_bar.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';

class CharacterFavoriteButton extends StatefulWidget {
  const CharacterFavoriteButton(this.data);

  final Character data;

  @override
  State<CharacterFavoriteButton> createState() =>
      _CharacterFavoriteButtonState();
}

class _CharacterFavoriteButtonState extends State<CharacterFavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: widget.data.isFavorite ? Icons.favorite : Icons.favorite_border,
      tooltip: widget.data.isFavorite ? 'Unfavourite' : 'Favourite',
      onTap: () {
        setState(
          () => widget.data.isFavorite = !widget.data.isFavorite,
        );
        toggleFavoriteCharacter(widget.data.id).then((ok) {
          if (!ok) {
            setState(
              () => widget.data.isFavorite = !widget.data.isFavorite,
            );
          }
        });
      },
    );
  }
}

class CharacterMediaFilterButton extends StatelessWidget {
  const CharacterMediaFilterButton(this.id);

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
              String key = MediaSort.values[i].name.noScreamingSnakeCase;
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
                    ChipSelector.ensureSelected(
                      title: 'Sort',
                      items: MediaSort.values.map((v) => (v.label, v)).toList(),
                      value: filter.sort,
                      onChanged: (v) => filter = filter.copyWith(sort: v),
                    ),
                    ChipSelector(
                      title: 'List Presence',
                      items: const [
                        ('In Lists', true),
                        ('Not in Lists', false),
                      ],
                      value: filter.inLists,
                      onChanged: (v) => filter = filter.copyWith(
                        inLists: () => v,
                      ),
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

class CharacterLanguageSelectionButton extends StatelessWidget {
  const CharacterLanguageSelectionButton(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return ref.watch(characterMediaProvider(id)).maybeWhen(
              data: (data) {
                if (data.languages.length < 2) return const SizedBox();

                return ActionButton(
                  tooltip: 'Language',
                  icon: Ionicons.globe_outline,
                  onTap: () {
                    final languages = data.languages;
                    final language = data.language;

                    showSheet(
                      context,
                      GradientSheet([
                        for (int i = 0; i < languages.length; i++)
                          GradientSheetButton(
                            text: languages.elementAt(i),
                            selected: languages.elementAt(i) == language,
                            onTap: () => ref
                                .read(characterMediaProvider(id).notifier)
                                .changeLanguage(languages.elementAt(i)),
                          ),
                      ]),
                    );
                  },
                );
              },
              orElse: () => const SizedBox(),
            );
      },
    );
  }
}
