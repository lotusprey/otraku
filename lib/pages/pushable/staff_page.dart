import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/staff.dart';
import 'package:otraku/tools/navigation/bubble_tabs.dart';
import 'package:otraku/tools/navigation/person_header.dart';
import 'package:otraku/tools/layouts/connections_grid.dart';
import 'package:otraku/tools/overlays/sort_sheet.dart';

class StaffPage extends StatelessWidget {
  final int id;
  final String imageUrl;

  StaffPage(this.id, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final staff = Get.find<Staff>(tag: id.toString());

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: Config.PHYSICS,
          slivers: [
            Obx(() => PersonHeader(
                  staff.person,
                  imageUrl,
                  staff.toggleFavourite,
                )),
            Obx(() {
              if (staff.person == null) return const SliverToBoxAdapter();
              return PersonInfo(staff.person);
            }),
            Obx(() {
              if (staff.person == null) return const SliverToBoxAdapter();

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (staff.characterList.items.isNotEmpty &&
                          staff.roleList.items.isNotEmpty)
                        BubbleTabs(
                          options: const ['Characters', 'Staff Roles'],
                          values: const [true, false],
                          initial: true,
                          onNewValue: (value) => staff.onCharacters = value,
                          onSameValue: (_) {},
                        )
                      else
                        const SizedBox(),
                      IconButton(
                        icon: const Icon(
                          FluentSystemIcons.ic_fluent_arrow_sort_filled,
                        ),
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          builder: (_) => MediaSortSheet(
                            staff.sort,
                            (sort) => staff.sort = sort,
                          ),
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            Obx(() {
              final connectionList =
                  staff.onCharacters ? staff.characterList : staff.roleList;

              if (connectionList == null || connectionList.items.isEmpty)
                return const SliverToBoxAdapter();

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                sliver: ConnectionsGrid(
                  connections: connectionList.items,
                  loadMore: () {
                    if (connectionList.hasNextPage) staff.fetchPage();
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
