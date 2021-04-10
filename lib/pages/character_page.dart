import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:otraku/models/character_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/widgets/fields/input_field_structure.dart';
import 'package:otraku/widgets/navigation/bubble_tabs.dart';
import 'package:otraku/controllers/character.dart';
import 'package:otraku/widgets/layouts/connections_grid.dart';
import 'package:otraku/widgets/navigation/button_sliver_header.dart';
import 'package:otraku/widgets/navigation/top_sliver_header.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class CharacterPage extends StatelessWidget {
  static const ROUTE = '/character';

  final int id;
  final String imageUrl;

  CharacterPage(this.id, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final character = Get.find<Character>(tag: id.toString());
    final axis = MediaQuery.of(context).size.width > 450
        ? Axis.horizontal
        : Axis.vertical;
    double coverWidth = MediaQuery.of(context).size.width * 0.35;
    if (coverWidth > 300) coverWidth = 300;
    final coverHeight = coverWidth / 0.7;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: Config.PHYSICS,
          controller: character.scrollCtrl,
          slivers: [
            GetBuilder<Character>(
              tag: id.toString(),
              builder: (c) => TopSliverHeader(
                toggleFavourite: c.toggleFavourite,
                isFavourite: c.model?.isFavourite,
                favourites: c.model?.favourites,
                text:
                    '${c.model?.firstName} ${c.model?.middleName} ${c.model?.lastName}',
              ),
            ),
            GetBuilder<Character>(
              tag: id.toString(),
              builder: (c) => SliverPadding(
                padding: Config.PADDING,
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    height:
                        axis == Axis.horizontal ? coverHeight : coverHeight * 2,
                    child: Flex(
                      direction: axis,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          child: Hero(
                            tag: c.id,
                            child: ClipRRect(
                              borderRadius: Config.BORDER_RADIUS,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: coverWidth,
                                height: coverHeight,
                              ),
                            ),
                          ),
                          onTap: () => showDialog(
                            context: context,
                            builder: (ctx) =>
                                PopUpAnimation(ImageDialog(imageUrl)),
                          ),
                        ),
                        const SizedBox(height: 10, width: 10),
                        if (c.model != null) _Details(c.model!, axis),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Obx(() {
              if (character.anime.items.isEmpty &&
                  character.manga.items.isEmpty)
                return const SliverToBoxAdapter();

              final offset =
                  (axis == Axis.vertical ? coverHeight * 2 : coverHeight) +
                      Config.PADDING.top * 2;

              return ButtonSliverHeader(
                leading: character.anime.items.isNotEmpty &&
                        character.manga.items.isNotEmpty
                    ? BubbleTabs<bool>(
                        options: const ['Anime', 'Manga'],
                        values: const [true, false],
                        initial: true,
                        onNewValue: (value) {
                          character.onAnime = value;
                          character.scrollTo(offset);
                        },
                        onSameValue: (_) => character.scrollTo(offset),
                      )
                    : const SizedBox(),
                trailing: [
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
                    icon: const Icon(FluentIcons.arrow_sort_24_filled),
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
              );
            }),
            Obx(() {
              final connections =
                  character.onAnime ? character.anime : character.manga;

              if (connections.items.isEmpty) return const SliverToBoxAdapter();

              return SliverPadding(
                padding: EdgeInsets.only(
                  top: 10,
                  left: 10,
                  right: 10,
                  bottom: MediaQuery.of(context).viewPadding.bottom + 10,
                ),
                sliver: ConnectionsGrid(
                  connections: connections.items,
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

class _Details extends StatelessWidget {
  final CharacterModel model;
  final Axis axis;
  _Details(this.model, this.axis);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Text(
            '${model.firstName} ${model.middleName} ${model.lastName}',
            style: Theme.of(context).textTheme.headline2,
            textAlign: axis == Axis.vertical ? TextAlign.center : null,
          ),
          Text(
            model.altNames.join(', '),
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: axis == Axis.vertical ? TextAlign.center : null,
          ),
          const SizedBox(height: 10),
          if (model.description.isNotEmpty)
            Expanded(
              child: InputFieldStructure(
                title: 'Description',
                child: Expanded(
                  child: GestureDetector(
                    child: Container(
                      padding: Config.PADDING,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: Config.BORDER_RADIUS,
                      ),
                      child: Text(
                        model.description,
                        style: Theme.of(context).textTheme.bodyText1,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => PopUpAnimation(
                        TextDialog(
                          title: 'Description',
                          text: model.description,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
