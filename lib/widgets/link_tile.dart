import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/constants/discover_type.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/edit/edit_view.dart';
import 'package:otraku/views/home_view.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class LinkTile extends StatelessWidget {
  final DiscoverType discoverType;
  final int id;
  final String? text;
  final Widget child;

  LinkTile({
    required this.id,
    required this.text,
    required this.discoverType,
    required this.child,
  });

  static void openView({
    required BuildContext ctx,
    required int id,
    required String? imageUrl,
    required DiscoverType discoverType,
  }) {
    switch (discoverType) {
      case DiscoverType.anime:
      case DiscoverType.manga:
        Navigator.pushNamed(
          ctx,
          RouteArg.media,
          arguments: RouteArg(id: id, info: imageUrl),
        );
        return;
      case DiscoverType.character:
        Navigator.pushNamed(
          ctx,
          RouteArg.character,
          arguments: RouteArg(id: id, info: imageUrl),
        );
        return;
      case DiscoverType.staff:
        Navigator.pushNamed(
          ctx,
          RouteArg.staff,
          arguments: RouteArg(id: id, info: imageUrl),
        );
        return;
      case DiscoverType.studio:
        Navigator.pushNamed(
          ctx,
          RouteArg.studio,
          arguments: RouteArg(id: id, info: imageUrl),
        );
        return;
      case DiscoverType.user:
        if (id != Settings().id)
          Navigator.pushNamed(
            ctx,
            RouteArg.user,
            arguments: RouteArg(id: id, info: imageUrl),
          );
        else {
          Get.find<HomeController>().homeTab = HomeView.USER;
          Navigator.popUntil(ctx, (r) => r.isFirst);
        }
        return;
      case DiscoverType.review:
        Navigator.pushNamed(
          ctx,
          RouteArg.review,
          arguments: RouteArg(id: id, info: imageUrl),
        );
        return;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openView(
          ctx: context, id: id, imageUrl: text, discoverType: discoverType),
      onLongPress: () {
        if (discoverType == DiscoverType.anime ||
            discoverType == DiscoverType.manga)
          showSheet(context, EditView(id));
      },
      child: child,
    );
  }
}
