import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/pages/pushable/person_page.dart';
import 'package:otraku/pages/pushable/edit_entry_page.dart';
import 'package:otraku/pages/pushable/media_page.dart';
import 'package:otraku/pages/pushable/studio_page.dart';

class MediaIndexer extends StatelessWidget {
  final Browsable itemType;
  final int id;
  final String heroTitle;
  final Widget child;

  MediaIndexer({
    @required this.itemType,
    @required this.id,
    @required this.child,
    this.heroTitle,
  });

  static void pushMedia({
    @required BuildContext context,
    @required Browsable type,
    @required int id,
    String heroTitle,
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
            // case Browsable.studios:
            //   return StudioPage(id, tag ?? id, heroTitle);
            default:
              return StudioPage(id, tag ?? id, heroTitle);
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
        heroTitle: heroTitle,
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
