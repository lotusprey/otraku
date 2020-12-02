import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/staff.dart';
import 'package:otraku/tools/headers/bubble_tab_bar.dart';
import 'package:otraku/tools/headers/person_header.dart';
import 'package:otraku/tools/layouts/media_connection_grid.dart';
import 'package:otraku/tools/overlays/sort_sheet.dart';

class StaffPage extends StatelessWidget {
  final int id;
  final String imageUrlTag;

  StaffPage(this.id, this.imageUrlTag);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            physics: Config.PHYSICS,
            slivers: [
              GetX<Staff>(
                init: Staff(),
                initState: (_) => Get.find<Staff>().fetchStaff(id),
                builder: (staff) => PersonHeader(staff.person, imageUrlTag),
              ),
              Obx(() {
                final person = Get.find<Staff>().person;
                if (person == null) return const SliverToBoxAdapter();
                return PersonInfo(person);
              }),
              Obx(() {
                final staff = Get.find<Staff>();
                if (staff.person == null) return const SliverToBoxAdapter();

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (staff.characterList.connections.isNotEmpty &&
                            staff.roleList.connections.isNotEmpty)
                          BubbleTabBar(
                            options: const ['Characters', 'Staff Roles'],
                            values: const [true, false],
                            initial: true,
                            onNewValue: (value) => staff.onCharacters = value,
                            onSameValue: (_) {},
                            minimised: true,
                            shrinkWrap: true,
                          ),
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
                final staff = Get.find<Staff>();
                final connectionList =
                    staff.onCharacters ? staff.characterList : staff.roleList;

                if (connectionList == null ||
                    connectionList.connections.isEmpty)
                  return const SliverToBoxAdapter();

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  sliver: MediaConnectionGrid(
                    connectionList.connections,
                    () {
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
