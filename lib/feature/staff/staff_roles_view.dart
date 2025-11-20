import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/feature/staff/staff_model.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/widget/grid/mono_relation_grid.dart';
import 'package:otraku/widget/paged_view.dart';
import 'package:otraku/feature/staff/staff_provider.dart';

class StaffRolesSubview extends StatelessWidget {
  const StaffRolesSubview({required this.id, required this.scrollCtrl});

  final int id;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return PagedView<StaffRelatedItem>(
      scrollCtrl: scrollCtrl,
      onRefresh: (invalidate) => invalidate(staffRelationsProvider(id)),
      provider: staffRelationsProvider(
        id,
      ).select((s) => s.unwrapPrevious().whenData((data) => data.roles)),
      onData: (data) => MonoRelationGrid(
        items: data.items,
        onTap: (item) => context.push(Routes.media(item.tileId, item.tileImageUrl)),
      ),
    );
  }
}
