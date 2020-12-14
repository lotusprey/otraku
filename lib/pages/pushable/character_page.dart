import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/navigators/bubble_tabs.dart';
import 'package:otraku/tools/navigators/person_header.dart';
import 'package:otraku/controllers/character.dart';
import 'package:otraku/tools/layouts/connections_grid.dart';
import 'package:otraku/tools/overlays/option_sheet.dart';
import 'package:otraku/tools/overlays/sort_sheet.dart';

class CharacterPage extends StatelessWidget {
  final int id;
  final String imageUrlTag;

  CharacterPage(this.id, this.imageUrlTag);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            physics: Config.PHYSICS,
            slivers: [
              GetX<Character>(
                init: Character(),
                initState: (_) => Get.find<Character>().fetchCharacter(id),
                builder: (character) =>
                    PersonHeader(character.person, imageUrlTag),
              ),
              Obx(() {
                final person = Get.find<Character>().person;
                if (person == null) return const SliverToBoxAdapter();
                return PersonInfo(person);
              }),
              Obx(() {
                final character = Get.find<Character>();
                if (character.person == null) return const SliverToBoxAdapter();

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (character.anime.connections.isNotEmpty &&
                            character.manga.connections.isNotEmpty)
                          BubbleTabs(
                            options: const ['Anime', 'Manga'],
                            values: const [true, false],
                            initial: true,
                            onNewValue: (value) => character.onAnime = value,
                            onSameValue: (_) {},
                          )
                        else
                          const SizedBox(),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.language),
                              onPressed: () => showModalBottomSheet(
                                context: context,
                                builder: (_) => OptionSheet(
                                  title: 'Language',
                                  options: character.availableLanguages,
                                  index: character.languageIndex,
                                  onTap: (index) => character.staffLanguage =
                                      character.availableLanguages[index],
                                ),
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                FluentSystemIcons.ic_fluent_arrow_sort_filled,
                              ),
                              onPressed: () => showModalBottomSheet(
                                context: context,
                                builder: (_) => MediaSortSheet(
                                  character.sort,
                                  (sort) => character.sort = sort,
                                ),
                                backgroundColor: Colors.transparent,
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
                final character = Get.find<Character>();
                final connectionList =
                    character.onAnime ? character.anime : character.manga;

                if (connectionList == null ||
                    connectionList.connections.isEmpty)
                  return const SliverToBoxAdapter();

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  sliver: ConnectionsGrid(
                    connections: connectionList.connections,
                    loadMore: () {
                      if (connectionList.hasNextPage) character.fetchPage();
                    },
                    preferredSubtitle: character.staffLanguage,
                  ),
                );
              }),
            ],
          ),
        ),
      );
}
