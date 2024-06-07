import 'package:flutter/material.dart';
import 'package:otraku/feature/discover/discover_models.dart';
import 'package:otraku/feature/user/user_models.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/widget/link_tile.dart';
import 'package:otraku/widget/cached_image.dart';
import 'package:otraku/widget/grids/sliver_grid_delegates.dart';

class UserGrid extends StatelessWidget {
  const UserGrid(this.items);

  final List<UserItem> items;

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

  final UserItem item;

  @override
  Widget build(BuildContext context) {
    return LinkTile(
      id: item.id,
      info: item.imageUrl,
      discoverType: DiscoverType.user,
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
