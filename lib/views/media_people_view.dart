import 'package:flutter/material.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/models/relation_model.dart';
import 'package:otraku/widgets/layouts/relation_grid.dart';
import 'package:otraku/widgets/navigation/bubble_tabs.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

class MediaPeopleView {
  static List<Widget> children(BuildContext ctx, MediaController ctrl) {
    late final RelationGrid grid;

    if (!ctrl.peopleTabToggled) {
      final characters = <RelationModel>[];
      final voiceActors = <RelationModel?>[];

      ctrl.model!.selectCharactersAndVoiceActors(
        ctrl.languages[ctrl.langIndex],
        characters,
        voiceActors,
      );

      grid = RelationGrid(
        items: characters,
        connections: voiceActors,
        placeholder: 'No Characters',
      );
    } else {
      grid = RelationGrid(
        items: ctrl.model!.staff.items,
        placeholder: 'No Staff',
      );
    }

    return [
      SliverShadowAppBar([
        BubbleTabs(
          items: const {'Characters': false, 'Staff': true},
          current: () => ctrl.peopleTabToggled,
          onChanged: (bool val) {
            ctrl.scrollUpTo(0);
            ctrl.peopleTabToggled = val;
          },
          onSame: () => ctrl.scrollUpTo(0),
        ),
      ]),
      SliverPadding(
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        sliver: grid,
      ),
    ];
  }
}
