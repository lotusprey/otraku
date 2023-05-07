import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/models/relation.dart';
import 'package:otraku/modules/staff/staff_action_buttons.dart';
import 'package:otraku/modules/staff/staff_info_tab.dart';
import 'package:otraku/modules/staff/staff_providers.dart';
import 'package:otraku/common/utils/paged_controller.dart';
import 'package:otraku/common/widgets/grids/relation_grid.dart';
import 'package:otraku/common/widgets/layouts/bottom_bar.dart';
import 'package:otraku/common/widgets/layouts/floating_bar.dart';
import 'package:otraku/common/widgets/layouts/scaffolds.dart';
import 'package:otraku/common/widgets/layouts/direct_page_view.dart';
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

class _StaffViewState extends ConsumerState<StaffView> {
  int _tab = 0;
  late final _ctrl = PagedController(loadMore: () {
    if (_tab == 0) return;
    _tab == 1
        ? ref.read(staffRelationsProvider(widget.id).notifier).fetch(true)
        : ref.read(staffRelationsProvider(widget.id).notifier).fetch(false);
  });

  @override
  void dispose() {
    _ctrl.dispose();
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

    return PageScaffold(
      bottomBar: BottomNavBar(
        current: _tab,
        onChanged: (i) => setState(() => _tab = i),
        onSame: (_) => _ctrl.scrollToTop(),
        items: const {
          'Bio': Ionicons.book_outline,
          'Characters': Ionicons.mic_outline,
          'Roles': Ionicons.briefcase_outline,
        },
      ),
      child: TabScaffold(
        topBar: TopBar(
          title: staff.valueOrNull?.name,
        ),
        floatingBar: FloatingBar(
          scrollCtrl: _ctrl,
          children: [
            if (_tab == 0 && staff.hasValue)
              StaffFavoriteButton(staff.valueOrNull!),
            if (_tab > 0) StaffFilterButton(widget.id, true),
          ],
        ),
        child: DirectPageView(
          current: _tab,
          onChanged: (i) => setState(() => _tab = i),
          children: [
            StaffInfoTab(widget.id, widget.imageUrl, _ctrl),
            PagedView<Relation>(
              provider:
                  staffRelationsProvider(widget.id).select((s) => s.characters),
              onData: (data) => RelationGrid(
                items: data.items,
                connections:
                    ref.read(staffRelationsProvider(widget.id)).characterMedia,
              ),
              scrollCtrl: _ctrl,
              onRefresh: onRefresh,
            ),
            PagedView<Relation>(
              provider:
                  staffRelationsProvider(widget.id).select((s) => s.roles),
              onData: (data) => RelationGrid(items: data.items),
              scrollCtrl: _ctrl,
              onRefresh: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}
