import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/character.dart';
import 'package:otraku/controllers/media.dart';
import 'package:otraku/controllers/staff.dart';
import 'package:otraku/controllers/studio.dart';
import 'package:otraku/controllers/user.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/pages/pushable/character_page.dart';
import 'package:otraku/pages/pushable/edit_entry_page.dart';
import 'package:otraku/pages/pushable/media_page.dart';
import 'package:otraku/pages/pushable/staff_page.dart';
import 'package:otraku/pages/pushable/studio_page.dart';
import 'package:otraku/pages/pushable/tab_page.dart';
import 'package:otraku/pages/tabs/user_tab.dart';

class BrowseIndexer extends StatelessWidget {
  final Browsable browsable;
  final int id;
  final String tag;
  final Widget child;

  BrowseIndexer({
    @required this.browsable,
    @required this.id,
    @required this.tag,
    @required this.child,
  });

  static void pushMedia({
    @required BuildContext context,
    @required Browsable type,
    @required int id,
    @required String tag,
  }) {
    switch (type) {
      case Browsable.anime:
      case Browsable.manga:
        Get.to(
          MediaPage(id, tag),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<Media>(tag: id.toString()))
              Get.put(Media(), tag: id.toString()).fetchOverview(id);
          }),
          preventDuplicates: false,
        );
        return;
      case Browsable.character:
        Get.to(
          CharacterPage(id, tag),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<Character>(tag: id.toString()))
              Get.put(Character(), tag: id.toString()).fetchCharacter(id);
          }),
        );
        return;
      case Browsable.staff:
        Get.to(
          StaffPage(id, tag),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<Staff>(tag: id.toString()))
              Get.put(Staff(), tag: id.toString()).fetchStaff(id);
          }),
        );
        return;
      case Browsable.studio:
        Get.to(
          StudioPage(id, tag),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<Studio>(tag: id.toString()))
              Get.put(Studio(), tag: id.toString()).fetchStudio(id);
          }),
        );
        return;
      case Browsable.user:
        Get.to(
          TabPage(UserTab(id, tag)),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<User>(tag: id.toString()))
              Get.put(User(), tag: id.toString()).fetchUser(id);
          }),
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
      onTap: () => BrowseIndexer.pushMedia(
        context: context,
        type: browsable,
        id: id,
        tag: tag,
      ),
      onLongPress: () {
        if (browsable == Browsable.anime || browsable == Browsable.manga)
          Get.to(EditEntryPage(id, (_) {}));
      },
      child: child,
    );
  }
}
