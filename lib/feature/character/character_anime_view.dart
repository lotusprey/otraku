import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/model/relation.dart';
import 'package:otraku/widget/grids/relation_grid.dart';
import 'package:otraku/widget/paged_view.dart';
import 'package:otraku/feature/character/character_provider.dart';

class CharacterAnimeSubview extends StatelessWidget {
  const CharacterAnimeSubview({required this.id, required this.scrollCtrl});

  final int id;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) => PagedView<Relation>(
        scrollCtrl: scrollCtrl,
        onRefresh: (invalidate) => invalidate(characterMediaProvider(id)),
        provider: characterMediaProvider(id).select(
          (s) => s.unwrapPrevious().whenData((data) => data.anime),
        ),
        onData: (data) {
          return RelationGrid(
            ref
                .watch(characterMediaProvider(id))
                .requireValue
                .getAnimeAndVoiceActors(),
          );
        },
      ),
    );
  }
}
