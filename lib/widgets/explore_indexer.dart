import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/utils/settings.dart';
import 'package:otraku/utils/route_arg.dart';
import 'package:otraku/views/edit_view.dart';
import 'package:otraku/views/home_view.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class ExploreIndexer extends StatelessWidget {
  final Explorable explorable;
  final int id;
  final String? imageUrl;
  final Widget child;

  ExploreIndexer({
    required this.explorable,
    required this.id,
    required this.imageUrl,
    required this.child,
  });

  static void openView({
    required BuildContext ctx,
    required int id,
    required String? imageUrl,
    required Explorable explorable,
  }) {
    switch (explorable) {
      case Explorable.anime:
      case Explorable.manga:
        Navigator.pushNamed(
          ctx,
          RouteArg.media,
          arguments: RouteArg(id: id, info: imageUrl),
        );
        return;
      case Explorable.character:
        Navigator.pushNamed(
          ctx,
          RouteArg.character,
          arguments: RouteArg(id: id, info: imageUrl),
        );
        return;
      case Explorable.staff:
        Navigator.pushNamed(
          ctx,
          RouteArg.staff,
          arguments: RouteArg(id: id, info: imageUrl),
        );
        return;
      case Explorable.studio:
        Navigator.pushNamed(
          ctx,
          RouteArg.studio,
          arguments: RouteArg(id: id, info: imageUrl),
        );
        return;
      case Explorable.user:
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
      case Explorable.review:
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
          ctx: context, id: id, imageUrl: imageUrl, explorable: explorable),
      onLongPress: () {
        if (explorable == Explorable.anime || explorable == Explorable.manga)
          showSheet(context, EditView(id));
      },
      child: child,
    );
  }
}
