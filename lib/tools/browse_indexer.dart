import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/list_status.dart';
import 'package:otraku/pages/pushable/character_page.dart';
import 'package:otraku/pages/pushable/edit_entry_page.dart';
import 'package:otraku/pages/media/media_page.dart';
import 'package:otraku/pages/pushable/review_page.dart';
import 'package:otraku/pages/pushable/staff_page.dart';
import 'package:otraku/pages/pushable/studio_page.dart';
import 'package:otraku/pages/home/user_tab.dart';

class BrowseIndexer extends StatelessWidget {
  final Browsable browsable;
  final int id;
  final String imageUrl;
  final Widget child;

  BrowseIndexer({
    @required this.browsable,
    @required this.id,
    @required this.imageUrl,
    @required this.child,
  });

  static void openPage({
    @required int id,
    @required String imageUrl,
    @required Browsable browsable,
  }) {
    switch (browsable) {
      case Browsable.anime:
      case Browsable.manga:
        Get.toNamed(
          MediaPage.ROUTE,
          arguments: [id, imageUrl],
          parameters: {'id': id.toString()},
          preventDuplicates: false,
        );
        return;
      case Browsable.character:
        Get.toNamed(
          CharacterPage.ROUTE,
          arguments: [id, imageUrl],
          parameters: {'id': id.toString()},
        );
        return;
      case Browsable.staff:
        Get.toNamed(
          StaffPage.ROUTE,
          arguments: [id, imageUrl],
          parameters: {'id': id.toString()},
        );
        return;
      case Browsable.studio:
        Get.toNamed(
          StudioPage.ROUTE,
          arguments: [id, imageUrl],
          parameters: {'id': id.toString()},
        );
        return;
      case Browsable.user:
        Get.toNamed(
          UserTab.ROUTE,
          arguments: [id, imageUrl],
          parameters: {'id': id.toString()},
        );
        return;
      case Browsable.review:
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

  static void openEditPage(int id, [Function(ListStatus) fn]) => Get.toNamed(
        EditEntryPage.ROUTE,
        arguments: [id, fn],
        parameters: {'id': id.toString()},
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openPage(id: id, imageUrl: imageUrl, browsable: browsable),
      onLongPress: () {
        if (browsable == Browsable.anime || browsable == Browsable.manga)
          openEditPage(id);
      },
      child: child,
    );
  }
}
