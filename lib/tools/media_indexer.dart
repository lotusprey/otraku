import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/pages/pushable/person_page.dart';
import 'package:otraku/pages/pushable/edit_entry_page.dart';
import 'package:otraku/pages/pushable/media_page.dart';

class MediaIndexer extends StatelessWidget {
  final Browsable itemType;
  final int id;
  final Widget child;

  MediaIndexer({
    @required this.itemType,
    @required this.id,
    @required this.child,
  });

  static void pushMedia({
    @required BuildContext context,
    @required Browsable type,
    @required int id,
    Object tag,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          switch (type) {
            case Browsable.anime:
            case Browsable.manga:
              return MediaPage(id, tag ?? id);
            case Browsable.characters:
            case Browsable.staff:
              return PersonPage(id, tag ?? id, type);
            default:
              return null;
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => MediaIndexer.pushMedia(
        context: context,
        type: itemType,
        id: id,
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
