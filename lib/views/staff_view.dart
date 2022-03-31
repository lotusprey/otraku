import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/models/staff_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/controllers/staff_controller.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/scrolling_controller.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/widgets/drag_detector.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/fields/labeled_field.dart';
import 'package:otraku/widgets/layouts/relation_grid.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/navigation/action_button.dart';
import 'package:otraku/widgets/navigation/bubble_tabs.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/top_sliver_header.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class StaffView extends StatelessWidget {
  StaffView(this.id, this.imageUrl);

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

    final offset = (axis == Axis.vertical ? coverHeight * 2 : coverHeight) +
        Consts.PADDING.top * 2;

    return GetBuilder<StaffController>(
      id: StaffController.ID_MAIN,
      init: StaffController(id),
      tag: id.toString(),
      builder: (ctrl) => Scaffold(
        floatingActionButton: ctrl.model != null ? _ActionButton(id) : null,
        floatingActionButtonLocation: Settings().leftHanded
            ? FloatingActionButtonLocation.startFloat
            : FloatingActionButtonLocation.endFloat,
        body: SafeArea(
          bottom: false,
          child: DragDetector(
            onSwipe: (goRight) {
              if (goRight) {
                if (ctrl.onCharacters) ctrl.onCharacters = false;
              } else {
                if (!ctrl.onCharacters) ctrl.onCharacters = true;
              }
            },
            child: CustomScrollView(
              physics: Consts.PHYSICS,
              controller: ctrl.scrollCtrl,
              slivers: [
                TopSliverHeader(
                  toggleFavourite: ctrl.toggleFavourite,
                  isFavourite: ctrl.model?.isFavourite,
                  favourites: ctrl.model?.favourites,
                  text: ctrl.model?.name,
                ),
                SliverPadding(
                  padding: Consts.PADDING,
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
                                  borderRadius: Consts.BORDER_RAD_MIN,
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
                SliverShadowAppBar([
                  GetBuilder<StaffController>(
                    id: StaffController.ID_MEDIA,
                    tag: id.toString(),
                    builder: (ctrl) {
                      return BubbleTabs(
                        items: const {'Characters': true, 'Staff Roles': false},
                        current: () => ctrl.onCharacters,
                        onChanged: (bool value) {
                          ctrl.onCharacters = value;
                          ctrl.scrollCtrl.scrollUpTo(offset);
                        },
                        onSame: () => ctrl.scrollCtrl.scrollUpTo(offset),
                      );
                    },
                  ),
                ]),
                SliverPadding(
                  padding: EdgeInsets.only(
                    top: 10,
                    left: 10,
                    right: 10,
                    bottom: MediaQuery.of(context).viewPadding.bottom + 10,
                  ),
                  sliver: GetBuilder<StaffController>(
                    id: StaffController.ID_MEDIA,
                    tag: id.toString(),
                    builder: (ctrl) => ctrl.onCharacters
                        ? RelationGrid(
                            items: ctrl.characters,
                            connections: ctrl.media,
                            placeholder: 'No characters',
                          )
                        : RelationGrid(
                            items: ctrl.roles,
                            placeholder: 'No Roles',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StaffController>(
      tag: id.toString(),
      builder: (ctrl) => FloatingListener(
        scrollCtrl: ctrl.scrollCtrl,
        child: ActionButton(
          icon: Ionicons.funnel_outline,
          tooltip: 'Filter',
          onTap: () {
            MediaSort sort = ctrl.sort;
            bool? onList = ctrl.onList;

            final sortItems = <String, int>{};
            for (int i = 0; i < MediaSort.values.length; i += 2) {
              String key = Convert.clarifyEnum(MediaSort.values[i].name)!;
              sortItems[key] = i ~/ 2;
            }

            showSheet(
              context,
              OpaqueSheet(
                initialHeight: Consts.MATERIAL_TAP_TARGET_SIZE * 4,
                builder: (context, scrollCtrl) => GridView(
                  controller: scrollCtrl,
                  physics: Consts.PHYSICS,
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
                  ],
                ),
              ),
            ).then((_) => ctrl.filter(sort, onList));
          },
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  final StaffModel model;
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
              child: LabeledField(
                label: 'Description',
                child: Expanded(
                  child: GestureDetector(
                    child: Container(
                      padding: Consts.PADDING,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: Consts.BORDER_RAD_MIN,
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
