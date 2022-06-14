import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/models/character_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/models/relation_model.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/drag_detector.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/fields/labeled_field.dart';
import 'package:otraku/widgets/grids/relation_grid.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/action_button.dart';
import 'package:otraku/widgets/navigation/tab_segments.dart';
import 'package:otraku/controllers/character_controller.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/top_sliver_header.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class CharacterView extends StatelessWidget {
  CharacterView(this.id, this.imageUrl);

  final int id;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final axis = MediaQuery.of(context).size.width > 450
        ? Axis.horizontal
        : Axis.vertical;
    double coverWidth = MediaQuery.of(context).size.width * 0.35;
    if (coverWidth > 200) coverWidth = 200;
    final coverHeight = coverWidth / 0.7;

    return GetBuilder<CharacterController>(
      id: CharacterController.ID_MAIN,
      init: CharacterController(id),
      tag: id.toString(),
      builder: (ctrl) {
        return Scaffold(
          floatingActionButton: ctrl.model != null ? _ActionButton(id) : null,
          floatingActionButtonLocation: Settings().leftHanded
              ? FloatingActionButtonLocation.startFloat
              : FloatingActionButtonLocation.endFloat,
          body: SafeArea(
            bottom: false,
            child: DragDetector(
              onSwipe: (goRight) {
                if (goRight) {
                  if (ctrl.onAnime) ctrl.onAnime = false;
                } else {
                  if (!ctrl.onAnime) ctrl.onAnime = true;
                }
              },
              child: CustomScrollView(
                controller: ctrl.scrollCtrl,
                slivers: [
                  TopSliverHeader(
                    toggleFavourite: ctrl.toggleFavourite,
                    isFavourite: ctrl.model?.isFavourite,
                    favourites: ctrl.model?.favourites,
                    text: ctrl.model?.name,
                  ),
                  SliverPadding(
                    padding: Consts.padding,
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
                                  tag: ctrl.id,
                                  child: ClipRRect(
                                    borderRadius: Consts.borderRadiusMin,
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
                            if (ctrl.model != null) _Details(ctrl.model!, axis),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ShadowSliverAppBar([
                    Expanded(
                      child: GetBuilder<CharacterController>(
                        id: CharacterController.ID_MEDIA,
                        tag: id.toString(),
                        builder: (ctrl) {
                          return TabSegments(
                            items: const {'Anime': true, 'Manga': false},
                            initial: ctrl.onAnime,
                            onChanged: (bool val) {
                              ctrl.onAnime = val;
                              ctrl.scrollCtrl.scrollToTop();
                            },
                          );
                        },
                      ),
                    ),
                  ]),
                  SliverPadding(
                    padding: EdgeInsets.only(
                      top: 10,
                      left: 10,
                      right: 10,
                      bottom: MediaQuery.of(context).viewPadding.bottom + 10,
                    ),
                    sliver: GetBuilder<CharacterController>(
                      id: CharacterController.ID_MEDIA,
                      tag: id.toString(),
                      builder: (ctrl) {
                        if (ctrl.onAnime) {
                          final anime = <RelationModel>[];
                          final voiceActors = <RelationModel?>[];
                          ctrl.selectMediaAndVoiceActors(anime, voiceActors);

                          return RelationGrid(
                            items: anime,
                            connections: voiceActors,
                            placeholder: 'No anime',
                          );
                        }

                        return RelationGrid(
                          items: ctrl.manga,
                          placeholder: 'No manga',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CharacterController>(
      id: CharacterController.ID_MEDIA,
      tag: id.toString(),
      builder: (ctrl) {
        List<Widget> children = [
          if (ctrl.onAnime && ctrl.languages.length > 1) ...[
            ActionButtonOld(
              tooltip: 'Language',
              icon: Ionicons.globe_outline,
              onTap: () => showSheet(
                context,
                DynamicGradientDragSheet(
                  onTap: (i) {
                    ctrl.scrollCtrl.scrollToTop();
                    ctrl.langIndex = i;
                  },
                  children: [
                    for (int i = 0; i < ctrl.languages.length; i++)
                      Text(
                        ctrl.languages[i],
                        style: i != ctrl.langIndex
                            ? Theme.of(context).textTheme.headline1
                            : Theme.of(context).textTheme.headline1?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          ActionButtonOld(
            icon: Ionicons.funnel_outline,
            tooltip: 'Filter',
            onTap: () {
              MediaSort sort = ctrl.sort;
              bool? onList = ctrl.onList;
              int language = ctrl.langIndex;

              final sortItems = <String, int>{};
              for (int i = 0; i < MediaSort.values.length; i += 2) {
                String key = Convert.clarifyEnum(MediaSort.values[i].name)!;
                sortItems[key] = i ~/ 2;
              }

              final languageItems = <String, int>{};
              for (int i = 0; i < ctrl.languages.length; i++)
                languageItems[ctrl.languages[i]] = i;

              showSheet(
                context,
                OpaqueSheet(
                  initialHeight: Consts.tapTargetSize * 4,
                  builder: (context, scrollCtrl) => GridView(
                    controller: scrollCtrl,
                    physics: Consts.physics,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 20,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMinWidthAndFixedHeight(
                      minWidth: 155,
                      height: 75,
                    ),
                    children: [
                      DropDownField<int>(
                        title: 'Sort',
                        value: sort.index ~/ 2,
                        items: sortItems,
                        onChanged: (val) {
                          int index = val * 2;
                          if (sort.index % 2 != 0) index++;
                          sort = MediaSort.values[index];
                        },
                      ),
                      DropDownField<bool>(
                        title: 'Order',
                        value: sort.index % 2 == 0,
                        items: const {'Ascending': true, 'Descending': false},
                        onChanged: (val) {
                          int index = sort.index;
                          if (!val && index % 2 == 0) {
                            index++;
                          } else if (val && index % 2 != 0) {
                            index--;
                          }
                          sort = MediaSort.values[index];
                        },
                      ),
                      DropDownField<bool?>(
                        title: 'List Filter',
                        value: onList,
                        items: const {
                          'Everything': null,
                          'On List': true,
                          'Not On List': false,
                        },
                        onChanged: (val) => onList = val,
                      ),
                      DropDownField<int>(
                        title: 'Language',
                        value: language,
                        items: languageItems,
                        onChanged: (val) => language = val,
                      ),
                    ],
                  ),
                ),
              ).then((_) => ctrl.filter(language, sort, onList));
            },
          )
        ];

        if (Settings().leftHanded) children = children.reversed.toList();

        return FloatingActionListener(
          scrollCtrl: ctrl.scrollCtrl,
          child: Row(mainAxisSize: MainAxisSize.min, children: children),
        );
      },
    );
  }
}

class _Details extends StatelessWidget {
  _Details(this.model, this.axis);

  final CharacterModel model;
  final Axis axis;

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
              child: LabeledField(
                label: 'Description',
                child: Expanded(
                  child: GestureDetector(
                    child: Container(
                      padding: Consts.padding,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: Consts.borderRadiusMin,
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
