import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/models/relation.dart';
import 'package:otraku/common/widgets/grids/relation_grid.dart';
import 'package:otraku/common/widgets/paged_view.dart';
import 'package:otraku/modules/media/media_provider.dart';

class MediaStaffSubview extends StatelessWidget {
  const MediaStaffSubview({required this.id, required this.scrollCtrl});

  final int id;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return PagedView<Relation>(
      withTopOffset: false,
      scrollCtrl: scrollCtrl,
      onRefresh: (invalidate) => invalidate(mediaRelationsProvider(id)),
      provider: mediaRelationsProvider(id).select(
        (s) => s.unwrapPrevious().whenData((data) => data.staff),
      ),
      onData: (data) => SingleRelationGrid(data.items),
    );
  }
}
