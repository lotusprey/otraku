import 'package:flutter/material.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/user/user_models.dart';
import 'package:otraku/widgets/link_tile.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';

class UserGrid extends StatelessWidget {
  UserGrid(this.items);

  final List<UserItem> items;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMinWidthAndExtraHeight(
          minWidth: 100,
          extraHeight: 40,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) => _Tile(items[i]),
          childCount: items.length,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  _Tile(this.item);

  final UserItem item;

  @override
  Widget build(BuildContext context) {
    return LinkTile(
      id: item.id,
      text: item.imageUrl,
      discoverType: DiscoverType.user,
      child: Column(
        children: [
          Expanded(
            child: Hero(
              tag: item.id,
              child: ClipRRect(
                borderRadius: Consts.borderRadiusMin,
                child: FadeImage(item.imageUrl, fit: BoxFit.contain),
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
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ],
      ),
    );
  }
}
