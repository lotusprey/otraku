import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/model/relation.dart';
import 'package:otraku/widget/grids/relation_grid.dart';
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
    return PagedView<(Relation, Relation)>(
      scrollCtrl: scrollCtrl,
      onRefresh: (invalidate) => invalidate(staffRelationsProvider(id)),
      provider: staffRelationsProvider(id).select(
        (s) => s.unwrapPrevious().whenData((data) => data.charactersAndMedia),
      ),
      onData: (data) => RelationGrid(data.items),
    );
  }
}
