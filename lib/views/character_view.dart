import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/models/character_model.dart';
import 'package:otraku/constants/config.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/fields/input_field_structure.dart';
import 'package:otraku/widgets/navigation/bubble_tabs.dart';
import 'package:otraku/controllers/character_controller.dart';
import 'package:otraku/widgets/layouts/connections_grid.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/top_sliver_header.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/drag_sheets.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class CharacterView extends StatelessWidget {
  final int id;
  final String? imageUrl;

  CharacterView(this.id, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final axis = MediaQuery.of(context).size.width > 450
        ? Axis.horizontal
        : Axis.vertical;
    double coverWidth = MediaQuery.of(context).size.width * 0.35;
    if (coverWidth > 200) coverWidth = 200;
    final coverHeight = coverWidth / 0.7;

    final offset = (axis == Axis.vertical ? coverHeight * 2 : coverHeight) +
        Config.PADDING.top * 2;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: GetBuilder<CharacterController>(
          init: CharacterController(id),
          tag: id.toString(),
          builder: (ctrl) => CustomScrollView(
            physics: Config.PHYSICS,
            controller: ctrl.scrollCtrl,
            slivers: [
              GetBuilder<CharacterController>(
                id: CharacterController.ID_MAIN,
                tag: id.toString(),
                builder: (c) => TopSliverHeader(
                  toggleFavourite: c.toggleFavourite,
                  isFavourite: c.model?.isFavourite,
                  favourites: c.model?.favourites,
                  text: c.model?.name,
                ),
              ),
              GetBuilder<CharacterController>(
                id: CharacterController.ID_MAIN,
                tag: id.toString(),
                builder: (c) => SliverPadding(
                  padding: Config.PADDING,
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: axis == Axis.horizontal
                          ? coverHeight
                          : coverHeight * 2,
                      child: Flex(
                        direction: axis,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (imageUrl != null)
                            GestureDetector(
                              child: Hero(
                                tag: c.id,
                                child: ClipRRect(
                                  borderRadius: Config.BORDER_RADIUS,
                                  child: Image.network(
                                    imageUrl!,
                                    fit: BoxFit.cover,
                                    width: coverWidth,
                                    height: coverHeight,
                                  ),
                                ),
                              ),
                              onTap: () =>
                                  showPopUp(context, ImageDialog(imageUrl!)),
                            ),
                          const SizedBox(height: 10, width: 10),
                          if (c.model != null) _Details(c.model!, axis),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverShadowAppBar([
                BubbleTabs(
                  items: const {'Anime': true, 'Manga': false},
                  current: () => true,
                  onChanged: (bool val) {
                    ctrl.onAnime = val;
                    ctrl.scrollUpTo(offset);
                  },
                  onSame: () => ctrl.scrollUpTo(offset),
                ),
                const Spacer(),
                GetBuilder<CharacterController>(
                  id: CharacterController.ID_MEDIA,
                  tag: id.toString(),
                  builder: (ctrl) {
                    if (!ctrl.onAnime || ctrl.availableLanguages.length < 2)
                      return const SizedBox();

                    return AppBarIcon(
                      tooltip: 'Language',
                      icon: Ionicons.globe_outline,
                      onTap: () => DragSheet.show(
                        context,
                        OptionDragSheet(
                          options: ctrl.availableLanguages,
                          index: ctrl.language,
                          onTap: (val) => ctrl.language = val,
                        ),
                      ),
                    );
                  },
                ),
                AppBarIcon(
                  tooltip: 'Filter',
                  icon: Ionicons.funnel_outline,
                  onTap: () => DragSheet.show(
                    context,
                    OptionDragSheet(
                      options: const ['Everything', 'On List', 'Not On List'],
                      index: ctrl.onList == null
                          ? 0
                          : ctrl.onList!
                              ? 1
                              : 2,
                      onTap: (val) => ctrl.onList = val == 0
                          ? null
                          : val == 1
                              ? true
                              : false,
                    ),
                  ),
                ),
                AppBarIcon(
                  tooltip: 'Sort',
                  icon: Ionicons.filter_outline,
                  onTap: () => Sheet.show(
                    ctx: context,
                    sheet: MediaSortSheet(ctrl.sort, (s) => ctrl.sort = s),
                  ),
                ),
              ]),
              GetBuilder<CharacterController>(
                id: CharacterController.ID_MEDIA,
                tag: id.toString(),
                builder: (ctrl) {
                  final connections = ctrl.onAnime ? ctrl.anime : ctrl.manga;

                  if (connections.isEmpty)
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No resuts',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                    );

                  return SliverPadding(
                    padding: EdgeInsets.only(
                      top: 10,
                      left: 10,
                      right: 10,
                      bottom: MediaQuery.of(context).viewPadding.bottom + 10,
                    ),
                    sliver: ConnectionsGrid(
                      connections: connections,
                      preferredSubtitle:
                          ctrl.language < ctrl.availableLanguages.length
                              ? ctrl.availableLanguages[ctrl.language]
                              : null,
                    ),
                  );
                },
              ),
            ],
          ),
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
          GestureDetector(
            onTap: () => Toast.copy(context, model.name),
            child: Text(
              model.name,
              style: Theme.of(context).textTheme.headline1,
              textAlign: axis == Axis.vertical ? TextAlign.center : null,
            ),
          ),
          Text(
            model.altNames.join(', '),
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
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: Config.BORDER_RADIUS,
                      ),
                      child: Text(
                        Convert.clearHtml(model.description),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    onTap: () => showPopUp(
                      context,
                      HtmlDialog(title: 'Description', text: model.description),
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
