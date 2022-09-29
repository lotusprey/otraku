import 'package:flutter/material.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/edit/edit_view.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

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

  static void openView({
    required BuildContext context,
    required DiscoverType discoverType,
    required int id,
    required String? imageUrl,
  }) {
    String route = '';
    switch (discoverType) {
      case DiscoverType.anime:
      case DiscoverType.manga:
        route = RouteArg.media;
        break;
      case DiscoverType.character:
        route = RouteArg.character;
        break;
      case DiscoverType.staff:
        route = RouteArg.staff;
        break;
      case DiscoverType.studio:
        route = RouteArg.studio;
        break;
      case DiscoverType.user:
        route = RouteArg.user;
        break;
      case DiscoverType.review:
        route = RouteArg.review;
        break;
    }

    Navigator.pushNamed(
      context,
      route,
      arguments: RouteArg(id: id, info: imageUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openView(
        context: context,
        discoverType: discoverType,
        id: id,
        imageUrl: info,
      ),
      onLongPress: () {
        if (discoverType == DiscoverType.anime ||
            discoverType == DiscoverType.manga) {
          showSheet(context, EditView(id));
        }
      },
      child: child,
    );
  }
}
