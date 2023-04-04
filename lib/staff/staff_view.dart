import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/staff/staff_info_tab.dart';
import 'package:otraku/staff/staff_relations_tab.dart';
import 'package:otraku/staff/staff_providers.dart';
import 'package:otraku/utils/paged_controller.dart';
import 'package:otraku/widgets/layouts/bottom_bar.dart';
import 'package:otraku/widgets/layouts/scaffolds.dart';
import 'package:otraku/widgets/layouts/direct_page_view.dart';
import 'package:otraku/widgets/layouts/top_bar.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

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
        ? ref.read(staffRelationProvider(widget.id)).fetchPage(true)
        : ref.read(staffRelationProvider(widget.id)).fetchPage(false);
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

    ref.watch(staffRelationProvider(widget.id).select((_) => null));
    final name = ref.watch(staffProvider(widget.id)).valueOrNull?.name;
    final topBar = TopBar(title: name);

    return PageScaffold(
      bottomBar: BottomBarIconTabs(
        current: _tab,
        onChanged: (i) => setState(() => _tab = i),
        onSame: (_) => _ctrl.scrollToTop(),
        items: const {
          'Bio': Ionicons.book_outline,
          'Characters': Ionicons.mic_outline,
          'Roles': Ionicons.briefcase_outline,
        },
      ),
      child: DirectPageView(
        current: _tab,
        onChanged: (i) => setState(() => _tab = i),
        children: [
          StaffInfoTab(widget.id, widget.imageUrl, _ctrl, topBar),
          StaffCharactersTab(widget.id, _ctrl, topBar),
          StaffRolesTab(widget.id, _ctrl, topBar),
        ],
      ),
    );
  }
}
