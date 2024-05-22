import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/common/models/relation.dart';
import 'package:otraku/common/widgets/grids/relation_grid.dart';
import 'package:otraku/common/widgets/paged_view.dart';
import 'package:otraku/modules/character/character_provider.dart';

class CharacterMangaSubview extends StatelessWidget {
  const CharacterMangaSubview({required this.id, required this.scrollCtrl});

  final int id;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return PagedView<Relation>(
      scrollCtrl: scrollCtrl,
      onRefresh: (invalidate) => invalidate(characterMediaProvider(id)),
      provider: characterMediaProvider(id).select(
        (s) => s.unwrapPrevious().whenData((data) => data.manga),
      ),
      onData: (data) => SingleRelationGrid(data.items),
    );
  }
}
