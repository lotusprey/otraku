import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/character.dart';
import 'package:otraku/controllers/entry.dart';
import 'package:otraku/controllers/media.dart';
import 'package:otraku/controllers/review.dart';
import 'package:otraku/controllers/staff.dart';
import 'package:otraku/controllers/studio.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/list_status.dart';
import 'package:otraku/pages/pushable/character_page.dart';
import 'package:otraku/pages/pushable/edit_entry_page.dart';
import 'package:otraku/pages/media/media_page.dart';
import 'package:otraku/pages/pushable/review_page.dart';
import 'package:otraku/pages/pushable/staff_page.dart';
import 'package:otraku/pages/pushable/studio_page.dart';
import 'package:otraku/pages/pushable/tab_page.dart';
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
        Get.to(MediaPage(id, imageUrl), binding: BindingsBuilder(() {
          if (!Get.isRegistered<Media>(tag: id.toString()))
            Get.put(Media(), tag: id.toString()).fetchOverview(id);
        }), preventDuplicates: false);
        return;
      case Browsable.character:
        Get.to(CharacterPage(id, imageUrl), binding: BindingsBuilder(() {
          if (!Get.isRegistered<Character>(tag: id.toString()))
            Get.put(Character(), tag: id.toString()).fetchCharacter(id);
        }));
        return;
      case Browsable.staff:
        Get.to(StaffPage(id, imageUrl), binding: BindingsBuilder(() {
          if (!Get.isRegistered<Staff>(tag: id.toString()))
            Get.put(Staff(), tag: id.toString()).fetchStaff(id);
        }));
        return;
      case Browsable.studio:
        Get.to(StudioPage(id, imageUrl), binding: BindingsBuilder(() {
          if (!Get.isRegistered<Studio>(tag: id.toString()))
            Get.put(Studio(), tag: id.toString()).fetchStudio(id);
        }));
        return;
      case Browsable.user:
        Get.to(TabPage(UserTab(id, imageUrl)), binding: BindingsBuilder(() {
          if (!Get.isRegistered<User>(tag: id.toString()))
            Get.put(User(), tag: id.toString()).fetchUser(id);
        }));
        return;
      case Browsable.review:
        Get.to(ReviewPage(id, imageUrl), binding: BindingsBuilder(() {
          if (!Get.isRegistered<Review>(tag: id.toString())) {}
          Get.put(Review(), tag: id.toString()).fetchReview(id);
        }));
        return;
      default:
        return;
    }
  }

  static void openEditPage(int id, [Function(ListStatus) fn]) => Get.to(
        EditEntryPage(id, fn ?? (_) {}),
        binding: BindingsBuilder.put(() => Entry()..fetchEntry(id)),
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
