import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/feature/staff/staff_model.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/widget/grid/dual_relation_grid.dart';
import 'package:otraku/widget/paged_view.dart';
import 'package:otraku/feature/staff/staff_provider.dart';

class StaffCharactersSubview extends StatelessWidget {
  const StaffCharactersSubview({
    required this.id,
    required this.scrollCtrl,
  });

  final int id;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return PagedView<(StaffRelatedItem, StaffRelatedItem)>(
      scrollCtrl: scrollCtrl,
      onRefresh: (invalidate) => invalidate(staffRelationsProvider(id)),
      provider: staffRelationsProvider(id).select(
        (s) => s.unwrapPrevious().whenData((data) => data.charactersAndMedia),
      ),
      onData: (data) => DualRelationGrid(
        items: data.items,
        onTapPrimary: (item) => context.push(
          Routes.character(item.tileId, item.tileImageUrl),
        ),
        onTapSecondary: (item) => context.push(
          Routes.media(item.tileId, item.tileImageUrl),
        ),
      ),
    );
  }
}
