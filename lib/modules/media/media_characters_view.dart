import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/models/relation.dart';
import 'package:otraku/common/widgets/grids/relation_grid.dart';
import 'package:otraku/common/widgets/paged_view.dart';
import 'package:otraku/modules/media/media_provider.dart';

class MediaCharactersSubview extends StatelessWidget {
  const MediaCharactersSubview({required this.id, required this.scrollCtrl});

  final int id;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) => PagedView<Relation>(
        withTopOffset: false,
        scrollCtrl: scrollCtrl,
        onRefresh: (invalidate) => invalidate(mediaRelationsProvider(id)),
        provider: mediaRelationsProvider(id).select(
          (s) => s.unwrapPrevious().whenData((data) => data.characters),
        ),
        onData: (data) {
          final mediaRelations = ref.watch(
            mediaRelationsProvider(id).select((s) => s.valueOrNull),
          );

          if (mediaRelations == null || mediaRelations.languages.isEmpty) {
            return SingleRelationGrid(data.items);
          }

          return RelationGrid(
            mediaRelations.getCharactersAndVoiceActors(),
          );
        },
      ),
    );
  }
}
