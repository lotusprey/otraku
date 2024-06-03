import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/character/character_filter_provider.dart';
import 'package:otraku/feature/character/character_model.dart';
import 'package:otraku/feature/character/character_provider.dart';
import 'package:otraku/feature/filter/chip_selector.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/layouts/floating_bar.dart';
import 'package:otraku/widget/overlays/sheets.dart';

class CharacterFavoriteButton extends StatefulWidget {
  const CharacterFavoriteButton(this.character, this.toggleFavorite);

  final Character character;
  final Future<bool> Function() toggleFavorite;

  @override
  State<CharacterFavoriteButton> createState() =>
      _CharacterFavoriteButtonState();
}

class _CharacterFavoriteButtonState extends State<CharacterFavoriteButton> {
  @override
  Widget build(BuildContext context) {
    final character = widget.character;

    return ActionButton(
      icon: character.isFavorite ? Icons.favorite : Icons.favorite_border,
      tooltip: character.isFavorite ? 'Unfavourite' : 'Favourite',
      onTap: () {
        setState(
          () => character.isFavorite = !character.isFavorite,
        );
        widget.toggleFavorite().then((ok) {
          if (!ok) {
            setState(
              () => character.isFavorite = !character.isFavorite,
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

            final onDone = (_) =>
                ref.read(characterFilterProvider(id).notifier).state = filter;

            showSheet(
              context,
              OpaqueSheet(
                initialHeight: MediaQuery.paddingOf(context).bottom +
                    Theming.tapTargetSize * 2.5,
                builder: (context, scrollCtrl) => ListView(
                  controller: scrollCtrl,
                  physics: Theming.bouncyPhysics,
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
