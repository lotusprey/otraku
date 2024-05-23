import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/util/routing.dart';
import 'package:otraku/feature/discover/discover_models.dart';
import 'package:otraku/feature/edit/edit_view.dart';
import 'package:otraku/widget/overlays/sheets.dart';

class LinkTile extends StatelessWidget {
  const LinkTile({
    required this.id,
    required this.info,
    required this.discoverType,
    required this.child,
    super.key,
  });

  final DiscoverType discoverType;
  final int id;
  final String? info;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push(switch (discoverType) {
        DiscoverType.anime || DiscoverType.manga => Routes.media(id, info),
        DiscoverType.character => Routes.character(id, info),
        DiscoverType.staff => Routes.staff(id, info),
        DiscoverType.studio => Routes.studio(id, info),
        DiscoverType.user => Routes.user(id, info),
        DiscoverType.review => Routes.review(id, info),
      }),
      onLongPress: () {
        if (discoverType == DiscoverType.anime ||
            discoverType == DiscoverType.manga) {
          showSheet(context, EditView((id: id, setComplete: false)));
        }
      },
      child: child,
    );
  }
}
