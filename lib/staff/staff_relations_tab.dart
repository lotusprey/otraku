import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/staff/staff_providers.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/grids/relation_grid.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class StaffCharactersTab extends StatelessWidget {
  StaffCharactersTab(this.id, this.scrollCtrl);

  final int id;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      floatingBar: FloatingBar(
        scrollCtrl: scrollCtrl,
        children: [_FilterButton(id)],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Consts.layoutBig),
            child: Consumer(
              builder: (context, ref, _) {
                ref.listen<AsyncValue>(
                  staffRelationProvider(id).select((s) => s.characters),
                  (_, s) {
                    if (s.hasError)
                      showPopUp(
                        context,
                        ConfirmationDialog(
                          title: 'Could not load characters',
                          content: s.error.toString(),
                        ),
                      );
                  },
                );

                final refreshControl = SliverRefreshControl(
                  onRefresh: () {
                    ref.invalidate(staffRelationProvider(id));
                    return Future.value();
                  },
                );

                final notifier = ref.watch(staffRelationProvider(id));

                return notifier.characters.when(
                  loading: () => const Center(child: Loader()),
                  error: (_, __) => CustomScrollView(
                    physics: Consts.physics,
                    slivers: [
                      refreshControl,
                      const SliverFillRemaining(child: Text('No characters')),
                    ],
                  ),
                  data: (data) {
                    return CustomScrollView(
                      controller: scrollCtrl,
                      physics: Consts.physics,
                      slivers: [
                        refreshControl,
                        const SliverToBoxAdapter(child: SizedBox(height: 10)),
                        RelationGrid(
                          items: data.items,
                          connections: notifier.characterMedia,
                          placeholder: 'No characters',
                        ),
                        SliverFooter(loading: data.hasNext),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class StaffRolesTab extends StatelessWidget {
  StaffRolesTab(this.id, this.scrollCtrl);

  final int id;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      floatingBar: FloatingBar(
        scrollCtrl: scrollCtrl,
        children: [_FilterButton(id)],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Consts.layoutBig),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Consumer(
              builder: (context, ref, _) {
                ref.listen<AsyncValue>(
                  staffRelationProvider(id).select((s) => s.roles),
                  (_, s) {
                    if (s.hasError)
                      showPopUp(
                        context,
                        ConfirmationDialog(
                          title: 'Could not load roles',
                          content: s.error.toString(),
                        ),
                      );
                  },
                );

                final refreshControl = SliverRefreshControl(
                  onRefresh: () {
                    ref.invalidate(staffRelationProvider(id));
                    return Future.value();
                  },
                );

                return ref.watch(staffRelationProvider(id)).roles.when(
                      loading: () => const Center(child: Loader()),
                      error: (_, __) => CustomScrollView(
                        physics: Consts.physics,
                        slivers: [
                          refreshControl,
                          const SliverFillRemaining(child: Text('No roles')),
                        ],
                      ),
                      data: (data) {
                        return CustomScrollView(
                          controller: scrollCtrl,
                          physics: Consts.physics,
                          slivers: [
                            refreshControl,
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 10),
                            ),
                            RelationGrid(
                              items: data.items,
                              placeholder: 'No roles',
                            ),
                            SliverFooter(loading: data.hasNext),
                          ],
                        );
                      },
                    );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  _FilterButton(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return ActionButton(
          icon: Ionicons.funnel_outline,
          tooltip: 'Filter',
          onTap: () {
            var filter = ref.read(staffFilterProvider(id));

            final sortItems = <String, int>{};
            for (int i = 0; i < MediaSort.values.length; i += 2) {
              String key = Convert.clarifyEnum(MediaSort.values[i].name)!;
              sortItems[key] = i ~/ 2;
            }

            final onDone = (_) =>
                ref.read(staffFilterProvider(id).notifier).state = filter;

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
                      value: filter.sort.index ~/ 2,
                      items: sortItems,
                      onChanged: (val) {
                        int index = val * 2;
                        if (filter.sort.index % 2 != 0) index++;
                        filter = filter.copyWith(sort: MediaSort.values[index]);
                      },
                    ),
                    DropDownField<bool>(
                      title: 'Order',
                      value: filter.sort.index % 2 == 0,
                      items: const {'Ascending': true, 'Descending': false},
                      onChanged: (val) {
                        int index = filter.sort.index;
                        if (!val && index % 2 == 0) {
                          index++;
                        } else if (val && index % 2 != 0) {
                          index--;
                        }
                        filter = filter.copyWith(sort: MediaSort.values[index]);
                      },
                    ),
                    DropDownField<bool?>(
                      title: 'List Filter',
                      value: filter.onList,
                      items: const {
                        'Everything': null,
                        'On List': true,
                        'Not On List': false,
                      },
                      onChanged: (val) =>
                          filter = filter.copyWith(onList: () => val),
                    ),
                  ],
                ),
              ),
            ).then(onDone);
          },
        );
      },
    );
  }
}
