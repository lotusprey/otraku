import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/model/relation.dart';
import 'package:otraku/widget/grids/relation_grid.dart';
import 'package:otraku/widget/paged_view.dart';
import 'package:otraku/feature/media/media_provider.dart';

class MediaStaffSubview extends StatelessWidget {
  const MediaStaffSubview({required this.id, required this.scrollCtrl});

  final int id;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return PagedView<Relation>(
      scrollCtrl: scrollCtrl,
      onRefresh: (invalidate) => invalidate(mediaRelationsProvider(id)),
      provider: mediaRelationsProvider(id).select(
        (s) => s.unwrapPrevious().whenData((data) => data.staff),
      ),
      onData: (data) => SingleRelationGrid(data.items),
    );
  }
}
