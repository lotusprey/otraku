import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/pages/pushable/character_page.dart';
import 'package:otraku/pages/pushable/edit_entry_page.dart';
import 'package:otraku/pages/pushable/media_page.dart';
import 'package:otraku/pages/pushable/staff_page.dart';
import 'package:otraku/pages/pushable/studio_page.dart';

class MediaIndexer extends StatelessWidget {
  final Browsable itemType;
  final int id;
  final String tag;
  final Widget child;

  MediaIndexer({
    @required this.itemType,
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          switch (type) {
            case Browsable.anime:
            case Browsable.manga:
              return MediaPage(id, tag);
            case Browsable.characters:
              return CharacterPage(id, tag);
            case Browsable.staff:
              return StaffPage(id, tag);
            // case Browsable.studios:
            //   return StudioPage(id, tag ?? id, heroTitle);
            default:
              return StudioPage(id, tag);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => MediaIndexer.pushMedia(
        context: context,
        type: itemType,
        id: id,
        tag: tag,
      ),
      onLongPress: () {
        if (itemType == Browsable.anime || itemType == Browsable.manga)
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => EditEntryPage(id, (_) {}),
            ),
          );
      },
      child: child,
    );
  }
}
