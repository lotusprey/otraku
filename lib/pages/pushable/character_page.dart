import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/navigation/bubble_tabs.dart';
import 'package:otraku/tools/navigation/person_header.dart';
import 'package:otraku/controllers/character.dart';
import 'package:otraku/tools/layouts/connections_grid.dart';
import 'package:otraku/tools/overlays/sheets.dart';

class CharacterPage extends StatelessWidget {
  static const ROUTE = '/character';

  final int id;
  final String imageUrl;

  CharacterPage(this.id, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final character = Get.find<Character>(tag: id.toString());

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: Config.PHYSICS,
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
                          onNewValue: (value) => character.onAnime = value,
                          onSameValue: (_) {},
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
                              FluentSystemIcons.ic_fluent_arrow_sort_filled,
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
              final connectionList =
                  character.onAnime ? character.anime : character.manga;

              if (connectionList == null || connectionList.items.isEmpty)
                return const SliverToBoxAdapter();

              return SliverPadding(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  bottom: MediaQuery.of(context).viewPadding.bottom + 10,
                ),
                sliver: ConnectionsGrid(
                  connections: connectionList.items,
                  loadMore: character.fetchPage,
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
