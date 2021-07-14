import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/models/entry_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/views/home_view.dart';
import 'package:otraku/views/character_view.dart';
import 'package:otraku/views/entry_view.dart';
import 'package:otraku/views/media_view.dart';
import 'package:otraku/views/review_view.dart';
import 'package:otraku/views/staff_view.dart';
import 'package:otraku/views/studio_view.dart';
import 'package:otraku/views/user_view.dart';

class ExploreIndexer extends StatelessWidget {
  final Explorable browsable;
  final int id;
  final String? imageUrl;
  final Widget child;

  ExploreIndexer({
    required this.browsable,
    required this.id,
    required this.imageUrl,
    required this.child,
  });

  static void openPage({
    required int id,
    required String? imageUrl,
    required Explorable browsable,
  }) {
    switch (browsable) {
      case Explorable.anime:
      case Explorable.manga:
        Get.toNamed(
          MediaView.ROUTE,
          arguments: [id, imageUrl],
          parameters: {'id': id.toString()},
          preventDuplicates: false,
        );
        return;
      case Explorable.character:
        Get.toNamed(
          CharacterView.ROUTE,
          arguments: [id, imageUrl],
          parameters: {'id': id.toString()},
        );
        return;
      case Explorable.staff:
        Get.toNamed(
          StaffView.ROUTE,
          arguments: [id, imageUrl],
          parameters: {'id': id.toString()},
        );
        return;
      case Explorable.studio:
        Get.toNamed(
          StudioView.ROUTE,
          arguments: [id, imageUrl],
          parameters: {'id': id.toString()},
        );
        return;
      case Explorable.user:
        if (id != Client.viewerId)
          Get.toNamed(
            UserView.ROUTE,
            arguments: [id, imageUrl],
            parameters: {'id': id.toString()},
          );
        else {
          Config.setHomeIndex(HomeView.PROFILE);
          Get.until((route) => route.isFirst);
        }
        return;
      case Explorable.review:
        Get.toNamed(
          ReviewView.ROUTE,
          arguments: [id, imageUrl],
          parameters: {'id': id.toString()},
        );
        return;
      default:
        return;
    }
  }

  static void openEditPage(
    int id, [
    EntryModel? entry,
    Function(EntryModel)? fn,
  ]) =>
      Get.toNamed(
        EntryView.ROUTE,
        arguments: [id, entry, fn],
        parameters: {'id': id.toString()},
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openPage(id: id, imageUrl: imageUrl, browsable: browsable),
      onLongPress: () {
        if (browsable == Explorable.anime || browsable == Explorable.manga)
          openEditPage(id);
      },
      child: child,
    );
  }
}
