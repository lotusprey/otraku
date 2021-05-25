import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/models/entry_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/enums/list_status.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/pages/home/home_page.dart';
import 'package:otraku/pages/character_page.dart';
import 'package:otraku/pages/entry_page.dart';
import 'package:otraku/pages/media/media_page.dart';
import 'package:otraku/pages/review_page.dart';
import 'package:otraku/pages/staff_page.dart';
import 'package:otraku/pages/studio_page.dart';
import 'package:otraku/pages/home/user_page.dart';

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
          MediaPage.ROUTE,
          arguments: [id, imageUrl],
          parameters: {'id': id.toString()},
          preventDuplicates: false,
        );
        return;
      case Explorable.character:
        Get.toNamed(
          CharacterPage.ROUTE,
          arguments: [id, imageUrl],
          parameters: {'id': id.toString()},
        );
        return;
      case Explorable.staff:
        Get.toNamed(
          StaffPage.ROUTE,
          arguments: [id, imageUrl],
          parameters: {'id': id.toString()},
        );
        return;
      case Explorable.studio:
        Get.toNamed(
          StudioPage.ROUTE,
          arguments: [id, imageUrl],
          parameters: {'id': id.toString()},
        );
        return;
      case Explorable.user:
        if (id != Client.viewerId)
          Get.toNamed(
            UserPage.ROUTE,
            arguments: [id, imageUrl],
            parameters: {'id': id.toString()},
          );
        else {
          Config.setIndex(HomePage.PROFILE);
          Get.until((route) => route.isFirst);
        }
        return;
      case Explorable.review:
        Get.toNamed(
          ReviewPage.ROUTE,
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
    Function(ListStatus?)? fn,
  ]) =>
      Get.toNamed(
        EntryPage.ROUTE,
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
