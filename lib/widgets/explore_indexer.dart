import 'package:flutter/material.dart';
import 'package:otraku/models/entry_model.dart';
import 'package:otraku/routing/navigation.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/utils/client.dart';
import 'package:otraku/views/entry_view.dart';
import 'package:otraku/views/home_view.dart';
import 'package:otraku/widgets/overlays/drag_sheets.dart';

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

  static void openPage({
    required int id,
    required String? imageUrl,
    required Explorable explorable,
  }) {
    switch (explorable) {
      case Explorable.anime:
      case Explorable.manga:
        Navigation.it.push(Navigation.mediaRoute, args: [id, imageUrl]);
        return;
      case Explorable.character:
        Navigation.it.push(Navigation.characterRoute, args: [id, imageUrl]);
        return;
      case Explorable.staff:
        Navigation.it.push(Navigation.staffRoute, args: [id, imageUrl]);
        return;
      case Explorable.studio:
        Navigation.it.push(Navigation.studioRoute, args: [id, imageUrl]);
        return;
      case Explorable.user:
        if (id != Client.viewerId)
          Navigation.it.push(Navigation.userRoute, args: [id, imageUrl]);
        else {
          Config.homeIndex = HomeView.PROFILE;
          Navigation.it.popToFirst();
        }
        return;
      case Explorable.review:
        Navigation.it.push(Navigation.reviewRoute, args: [id, imageUrl]);
        return;
      default:
        return;
    }
  }

  static void openEditPage(
    int id,
    BuildContext context, [
    EntryModel? model,
    Function(EntryModel)? callback,
  ]) =>
      DragSheet.show(context, EntryView(id, model, callback));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openPage(id: id, imageUrl: imageUrl, explorable: explorable),
      onLongPress: () {
        if (explorable == Explorable.anime || explorable == Explorable.manga)
          openEditPage(id, context);
      },
      child: child,
    );
  }
}
