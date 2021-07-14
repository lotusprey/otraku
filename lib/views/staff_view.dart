import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/models/staff_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/staff_controller.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/action_icon.dart';
import 'package:otraku/widgets/fields/input_field_structure.dart';
import 'package:otraku/widgets/navigation/bubble_tabs.dart';
import 'package:otraku/widgets/layouts/connections_grid.dart';
import 'package:otraku/widgets/navigation/opaque_header.dart';
import 'package:otraku/widgets/navigation/top_sliver_header.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class StaffView extends StatelessWidget {
  static const ROUTE = '/staff';

  final int id;
  final String imageUrl;

  StaffView(this.id, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final staff = Get.find<StaffController>(tag: id.toString());
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
          controller: staff.scrollCtrl,
          slivers: [
            GetBuilder<StaffController>(
              tag: id.toString(),
              builder: (s) => TopSliverHeader(
                toggleFavourite: s.toggleFavourite,
                isFavourite: s.model?.isFavourite,
                favourites: s.model?.favourites,
                text:
                    '${s.model?.firstName} ${s.model?.middleName} ${s.model?.lastName}',
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
                        if (s.model != null) _Details(staff.model!, axis),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Obx(() {
              if (staff.characters.items.isEmpty && staff.roles.items.isEmpty)
                return const SliverToBoxAdapter();

              final offset =
                  (axis == Axis.vertical ? coverHeight * 2 : coverHeight) +
                      Config.PADDING.top * 2;

              return OpaqueHeader(
                [
                  staff.characters.items.isNotEmpty &&
                          staff.roles.items.isNotEmpty
                      ? BubbleTabs<bool>(
                          options: const ['Characters', 'Staff Roles'],
                          values: const [true, false],
                          initial: true,
                          onNewValue: (value) {
                            staff.onCharacters = value;
                            staff.scrollTo(offset);
                          },
                          onSameValue: (_) => staff.scrollTo(offset),
                        )
                      : const SizedBox(),
                  const Spacer(),
                  ActionIcon(
                    tooltip: 'Sort',
                    icon: Ionicons.filter_outline,
                    onTap: () => Sheet.show(
                      ctx: context,
                      sheet: MediaSortSheet(
                        staff.sort,
                        (sort) {
                          staff.sort = sort;
                          staff.scrollTo(offset);
                        },
                      ),
                      isScrollControlled: true,
                    ),
                  ),
                ],
              );
            }),
            Obx(() {
              final connections =
                  staff.onCharacters ? staff.characters : staff.roles;

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
          Text(
            '${model.firstName} ${model.middleName} ${model.lastName}',
            style: Theme.of(context).textTheme.headline2,
            textAlign: axis == Axis.vertical ? TextAlign.center : null,
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
                        color: Theme.of(context).primaryColor,
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
