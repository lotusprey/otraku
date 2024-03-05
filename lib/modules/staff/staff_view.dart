import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/models/relation.dart';
import 'package:otraku/common/widgets/overlays/sheets.dart';
import 'package:otraku/modules/staff/staff_action_buttons.dart';
import 'package:otraku/modules/staff/staff_info_tab.dart';
import 'package:otraku/modules/staff/staff_providers.dart';
import 'package:otraku/common/utils/paged_controller.dart';
import 'package:otraku/common/widgets/grids/relation_grid.dart';
import 'package:otraku/common/widgets/layouts/bottom_bar.dart';
import 'package:otraku/common/widgets/layouts/floating_bar.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/layouts/top_bar.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/widgets/paged_view.dart';

class StaffView extends ConsumerStatefulWidget {
  const StaffView(this.id, this.imageUrl);

  final int id;
  final String? imageUrl;

  @override
  ConsumerState<StaffView> createState() => _StaffViewState();
}

class _StaffViewState extends ConsumerState<StaffView>
    with SingleTickerProviderStateMixin {
  late final _tabCtrl = TabController(length: 3, vsync: this);
  late final _scrollCtrl = PagedController(loadMore: () {
    if (_tabCtrl.index == 0) return;
    _tabCtrl.index == 1
        ? ref.read(staffRelationsProvider(widget.id).notifier).fetch(true)
        : ref.read(staffRelationsProvider(widget.id).notifier).fetch(false);
  });

  @override
  void initState() {
    super.initState();
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      staffProvider(widget.id),
      (_, s) {
        if (s.hasError) {
          showPopUp(
            context,
            ConfirmationDialog(
              title: 'Failed to load staff',
              content: s.error.toString(),
            ),
          );
        }
      },
    );

    final staff = ref.watch(staffProvider(widget.id));
    ref.watch(staffRelationsProvider(widget.id).select((_) => null));
    final onRefresh = () => ref.invalidate(staffRelationsProvider(widget.id));

    final topBar = staff.valueOrNull != null
        ? TopBar(
            title: staff.valueOrNull!.name,
            trailing: [
              TopBarIcon(
                tooltip: 'More',
                icon: Ionicons.ellipsis_horizontal,
                onTap: () => showSheet(
                  context,
                  GradientSheet.link(context, staff.valueOrNull!.siteUrl!),
                ),
              ),
            ],
          )
        : const TopBar();

    return PageScaffold(
      bottomBar: BottomNavBar(
        current: _tabCtrl.index,
        onChanged: (i) => _tabCtrl.index = i,
        onSame: (_) => _scrollCtrl.scrollToTop(),
        items: const {
          'Bio': Ionicons.information_outline,
          'Characters': Ionicons.mic_outline,
          'Roles': Ionicons.briefcase_outline,
        },
      ),
      child: TabScaffold(
        topBar: topBar,
        floatingBar: FloatingBar(
          scrollCtrl: _scrollCtrl,
          children: [
            if (_tabCtrl.index == 0 && staff.hasValue)
              StaffFavoriteButton(staff.valueOrNull!),
            if (_tabCtrl.index > 0) StaffFilterButton(widget.id, true),
          ],
        ),
        child: TabBarView(
          controller: _tabCtrl,
          children: [
            StaffInfoTab(widget.id, widget.imageUrl, _scrollCtrl),
            PagedView<(Relation, Relation)>(
              provider: staffRelationsProvider(widget.id).select(
                (s) => s
                    .unwrapPrevious()
                    .whenData((data) => data.charactersAndMedia),
              ),
              onData: (data) => RelationGrid(data.items),
              scrollCtrl: _scrollCtrl,
              onRefresh: onRefresh,
            ),
            PagedView<Relation>(
              provider: staffRelationsProvider(widget.id).select(
                (s) => s.unwrapPrevious().whenData((data) => data.roles),
              ),
              onData: (data) => SingleRelationGrid(data.items),
              scrollCtrl: _scrollCtrl,
              onRefresh: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}
