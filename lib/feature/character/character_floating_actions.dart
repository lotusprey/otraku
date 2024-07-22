import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/feature/character/character_filter_provider.dart';
import 'package:otraku/feature/character/character_model.dart';
import 'package:otraku/feature/character/character_provider.dart';
import 'package:otraku/feature/filter/chip_selector.dart';
import 'package:otraku/feature/media/media_models.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/util/toast.dart';
import 'package:otraku/widget/overlays/sheets.dart';

class CharacterFavoriteButton extends StatefulWidget {
  const CharacterFavoriteButton(this.character, this.toggleFavorite)
      : super(key: const Key('favoriteCharacter'));

  final Character character;
  final Future<Object?> Function() toggleFavorite;

  @override
  State<CharacterFavoriteButton> createState() =>
      _CharacterFavoriteButtonState();
}

class _CharacterFavoriteButtonState extends State<CharacterFavoriteButton> {
  @override
  Widget build(BuildContext context) {
    final character = widget.character;

    return FloatingActionButton(
      tooltip: character.isFavorite ? 'Unfavourite' : 'Favourite',
      heroTag: 'favorite',
      child: character.isFavorite
          ? const Icon(Icons.favorite)
          : const Icon(Icons.favorite_border),
      onPressed: () async {
        setState(() => character.isFavorite = !character.isFavorite);

        final err = await widget.toggleFavorite();
        if (err == null) return;

        setState(() => character.isFavorite = !character.isFavorite);
        if (context.mounted) Toast.show(context, err.toString());
      },
    );
  }
}

class CharacterMediaFilterButton extends StatelessWidget {
  const CharacterMediaFilterButton(this.id, this.ref)
      : super(key: const Key('filterCharacter'));

  final int id;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: 'Filter',
      heroTag: 'filter',
      child: const Icon(Ionicons.funnel_outline),
      onPressed: () {
        var filter = ref.read(characterFilterProvider(id));

        final onDone = (_) =>
            ref.read(characterFilterProvider(id).notifier).state = filter;

        showSheet(
          context,
          SimpleSheet(
            initialHeight: Theming.minTapTarget * 3.5,
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
  }
}

class CharacterLanguageSelectionButton extends StatelessWidget {
  const CharacterLanguageSelectionButton(this.id)
      : super(key: const Key('languageCharacter'));

  final int id;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return ref.watch(characterMediaProvider(id)).maybeWhen(
              data: (data) {
                if (data.languages.length < 2) return const SizedBox();

                return FloatingActionButton(
                  tooltip: 'Language',
                  heroTag: 'language',
                  child: const Icon(Ionicons.globe_outline),
                  onPressed: () {
                    final languages = data.languages;
                    final language = data.language;

                    showSheet(
                      context,
                      SimpleSheet.list([
                        for (int i = 0; i < languages.length; i++)
                          ListTile(
                            title: Text(languages.elementAt(i)),
                            selected: languages.elementAt(i) == language,
                            onTap: () {
                              ref
                                  .read(characterMediaProvider(id).notifier)
                                  .changeLanguage(languages.elementAt(i));
                              Navigator.pop(context);
                            },
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
