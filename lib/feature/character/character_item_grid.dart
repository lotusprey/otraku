import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/feature/character/character_item_model.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/grid/sliver_grid_delegates.dart';

class CharacterItemGrid extends StatelessWidget {
  const CharacterItemGrid(this.items);

  final List<CharacterItem> items;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndExtraHeight(
        minWidth: 100,
        extraHeight: 40,
      ),
      delegate: SliverChildBuilderDelegate(
        (_, i) => _Tile(items[i]),
        childCount: items.length,
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.item);

  final CharacterItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push(Routes.staff(item.id, item.imageUrl)),
      child: Column(
        children: [
          Expanded(
            child: Hero(
              tag: item.id,
              child: ClipRRect(
                borderRadius: Theming.borderRadiusSmall,
                child: CachedImage(item.imageUrl, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 35,
            child: Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.fade,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
