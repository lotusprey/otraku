import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/navigation/bubble_tabs.dart';
import 'package:otraku/widgets/navigation/person_header.dart';
import 'package:otraku/controllers/character.dart';
import 'package:otraku/widgets/layouts/connections_grid.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class CharacterPage extends StatelessWidget {
  static const ROUTE = '/character';

  final int id;
  final String? imageUrl;

  CharacterPage(this.id, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final character = Get.find<Character>(tag: id.toString());

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: Config.PHYSICS,
          controller: character.scrollCtrl,
          slivers: [
            Obx(() => PersonHeader(
                  person: character.person,
                  personId: id,
                  imageUrl: imageUrl,
                  toggleFavourite: character.toggleFavourite,
                )),
            Obx(() {
              if (character.person == null) return const SliverToBoxAdapter();
              return PersonInfo(character.person);
            }),
            Obx(() {
              if (character.person == null) return const SliverToBoxAdapter();

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (character.anime.items.isNotEmpty &&
                          character.manga.items.isNotEmpty)
                        BubbleTabs(
                          options: const ['Anime', 'Manga'],
                          values: const [true, false],
                          initial: true,
                          onNewValue: (dynamic value) =>
                              character.onAnime = value,
                          onSameValue: (dynamic _) {},
                        )
                      else
                        const SizedBox(),
                      Row(
                        children: [
                          if (character.availableLanguages.length > 1)
                            IconButton(
                              tooltip: 'Language',
                              icon: const Icon(Icons.language),
                              onPressed: () => Sheet.show(
                                ctx: context,
                                sheet: OptionSheet(
                                  title: 'Language',
                                  options: character.availableLanguages,
                                  index: character.languageIndex,
                                  onTap: (index) => character.staffLanguage =
                                      character.availableLanguages[index],
                                ),
                                isScrollControlled: true,
                              ),
                            ),
                          IconButton(
                            tooltip: 'Sort',
                            icon: const Icon(
                              FluentIcons.arrow_sort_24_filled,
                            ),
                            onPressed: () => Sheet.show(
                              ctx: context,
                              sheet: MediaSortSheet(
                                character.sort,
                                (sort) => character.sort = sort,
                              ),
                              isScrollControlled: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            Obx(() {
              final connections =
                  character.onAnime ? character.anime : character.manga;

              if (connections.items.isEmpty) return const SliverToBoxAdapter();

              return SliverPadding(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  bottom: MediaQuery.of(context).viewPadding.bottom + 10,
                ),
                sliver: ConnectionsGrid(
                  connections: connections.items.cast(),
                  preferredSubtitle: character.staffLanguage,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
