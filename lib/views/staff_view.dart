import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/models/staff_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/staff_controller.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/fields/input_field_structure.dart';
import 'package:otraku/widgets/navigation/bubble_tabs.dart';
import 'package:otraku/widgets/layouts/connections_grid.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/top_sliver_header.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class StaffView extends StatelessWidget {
  final int id;
  final String imageUrl;

  StaffView(this.id, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<StaffController>(tag: id.toString());
    final axis = MediaQuery.of(context).size.width > 450
        ? Axis.horizontal
        : Axis.vertical;
    double coverWidth = MediaQuery.of(context).size.width * 0.35;
    if (coverWidth > 200) coverWidth = 200;
    final coverHeight = coverWidth / 0.7;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: Config.PHYSICS,
          controller: ctrl.scrollCtrl,
          slivers: [
            GetBuilder<StaffController>(
              tag: id.toString(),
              builder: (s) => TopSliverHeader(
                toggleFavourite: s.toggleFavourite,
                isFavourite: s.model?.isFavourite,
                favourites: s.model?.favourites,
                text: s.model?.name,
              ),
            ),
            GetBuilder<StaffController>(
              tag: id.toString(),
              builder: (s) => SliverPadding(
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
                            tag: s.id,
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
                          onTap: () =>
                              showPopUp(context, ImageDialog(imageUrl)),
                        ),
                        const SizedBox(height: 10, width: 10),
                        if (s.model != null) _Details(ctrl.model!, axis),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Obx(() {
              if (ctrl.characters.items.isEmpty && ctrl.roles.items.isEmpty)
                return const SliverToBoxAdapter();

              final offset =
                  (axis == Axis.vertical ? coverHeight * 2 : coverHeight) +
                      Config.PADDING.top * 2;

              return SliverShadowAppBar([
                ctrl.characters.items.isNotEmpty && ctrl.roles.items.isNotEmpty
                    ? BubbleTabs(
                        items: const {'Characters': true, 'Staff Roles': false},
                        current: () => true,
                        onChanged: (bool value) {
                          ctrl.onCharacters = value;
                          ctrl.scrollTo(offset);
                        },
                        onSame: () => ctrl.scrollTo(offset),
                        itemWidth: 100,
                      )
                    : const SizedBox(),
                const Spacer(),
                AppBarIcon(
                  tooltip: 'Sort',
                  icon: Ionicons.filter_outline,
                  onTap: () => Sheet.show(
                    ctx: context,
                    sheet: MediaSortSheet(
                      ctrl.sort,
                      (sort) {
                        ctrl.sort = sort;
                        ctrl.scrollTo(offset);
                      },
                    ),
                    isScrollControlled: true,
                  ),
                ),
              ]);
            }),
            Obx(() {
              final connections =
                  ctrl.onCharacters ? ctrl.characters : ctrl.roles;

              if (connections.items.isEmpty) return const SliverToBoxAdapter();

              return SliverPadding(
                padding: EdgeInsets.only(
                  top: 10,
                  left: 10,
                  right: 10,
                  bottom: MediaQuery.of(context).viewPadding.bottom + 10,
                ),
                sliver: ConnectionsGrid(connections: connections.items),
              );
            }),
          ],
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
              style: Theme.of(context).textTheme.headline2,
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
