import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/pages/pushable/character_page.dart';
import 'package:otraku/pages/pushable/edit_entry_page.dart';
import 'package:otraku/pages/pushable/media_page.dart';
import 'package:otraku/pages/pushable/staff_page.dart';
import 'package:otraku/pages/pushable/studio_page.dart';
import 'package:otraku/pages/tabs/user_tab.dart';
import 'package:otraku/tools/page_transition.dart';

class BrowseIndexer extends StatelessWidget {
  final Browsable browsable;
  final int id;
  final String image;
  final Widget child;

  BrowseIndexer({
    @required this.browsable,
    @required this.id,
    @required this.image,
    @required this.child,
  });

  static void pushMedia({
    @required BuildContext context,
    @required Browsable type,
    @required int id,
    @required String tag,
  }) {
    Widget page;
    switch (type) {
      case Browsable.anime:
      case Browsable.manga:
        page = MediaPage(id, tag);
        break;
      case Browsable.character:
        page = CharacterPage(id, tag);
        break;
      case Browsable.staff:
        page = StaffPage(id, tag);
        break;
      case Browsable.studio:
        page = StudioPage(id, tag);
        break;
      case Browsable.user:
        page = Scaffold(body: SafeArea(child: UserTab(id, tag)));
        break;
      default:
        return;
    }

    Navigator.push(context, PageTransition.to(page));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => BrowseIndexer.pushMedia(
        context: context,
        type: browsable,
        id: id,
        tag: image,
      ),
      onLongPress: () {
        if (browsable == Browsable.anime || browsable == Browsable.manga)
          Navigator.push(context, PageTransition.to(EditEntryPage(id, (_) {})));
      },
      child: child,
    );
  }
}
