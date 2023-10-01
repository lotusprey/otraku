import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/extensions.dart';
import 'package:otraku/modules/character/character_models.dart';
import 'package:otraku/modules/character/character_providers.dart';
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
                    ChipSelector(
                      title: 'Sort',
                      options: MediaSort.values.map((s) => s.label).toList(),
                      current: filter.sort.index,
                      mustHaveSelected: true,
                      onChanged: (i) => filter = filter.copyWith(
                        sort: MediaSort.values.elementAt(i!),
                      ),
                    ),
                    ChipSelector(
                      title: 'List Presence',
                      options: const ['On List', 'Not on List'],
                      current: filter.onList == null
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

class CharacterLanguageSelectionButton extends StatelessWidget {
  const CharacterLanguageSelectionButton(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        if (ref.watch(characterMediaProvider(id).select(
          (s) => s.languages.length < 2,
        ))) return const SizedBox();

        return ActionButton(
          tooltip: 'Language',
          icon: Ionicons.globe_outline,
          onTap: () {
            final characterMedia = ref.read(characterMediaProvider(id));
            final languages = characterMedia.languages;
            final language = characterMedia.language;

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
    );
  }
}
