import 'package:flutter/material.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/user/user_models.dart';
import 'package:otraku/common/widgets/link_tile.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/grids/sliver_grid_delegates.dart';

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
      discoverType: DiscoverType.User,
      child: Column(
        children: [
          Expanded(
            child: Hero(
              tag: item.id,
              child: ClipRRect(
                borderRadius: Consts.borderRadiusMin,
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
