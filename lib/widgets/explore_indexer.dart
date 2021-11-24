import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/home_controller.dart';
import 'package:otraku/models/entry_model.dart';
import 'package:otraku/utils/navigation.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/utils/local_settings.dart';
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

  static void openView({
    required int id,
    required String? imageUrl,
    required Explorable explorable,
  }) {
    switch (explorable) {
      case Explorable.anime:
      case Explorable.manga:
        Navigation().push(Navigation.mediaRoute, args: [id, imageUrl]);
        return;
      case Explorable.character:
        Navigation().push(Navigation.characterRoute, args: [id, imageUrl]);
        return;
      case Explorable.staff:
        Navigation().push(Navigation.staffRoute, args: [id, imageUrl]);
        return;
      case Explorable.studio:
        Navigation().push(Navigation.studioRoute, args: [id, imageUrl]);
        return;
      case Explorable.user:
        if (id != LocalSettings().id)
          Navigation().push(Navigation.userRoute, args: [id, imageUrl]);
        else {
          Get.find<HomeController>().homeTab = HomeView.PROFILE;
          Navigation().popToFirst();
        }
        return;
      case Explorable.review:
        Navigation().push(Navigation.reviewRoute, args: [id, imageUrl]);
        return;
      default:
        return;
    }
  }

  static void openEditView(
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
      onTap: () => openView(id: id, imageUrl: imageUrl, explorable: explorable),
      onLongPress: () {
        if (explorable == Explorable.anime || explorable == Explorable.manga)
          openEditView(id, context);
      },
      child: child,
    );
  }
}
