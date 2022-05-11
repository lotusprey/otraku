import 'package:flutter/material.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/models/relation_model.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/widgets/grids/relation_grid.dart';
import 'package:otraku/widgets/navigation/tab_segments.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

class MediaPeopleView {
  static List<Widget> children(BuildContext ctx, MediaController ctrl) {
    late final RelationGrid grid;

    if (!ctrl.peopleTabToggled) {
      if (ctrl.languages.isEmpty) {
        grid = RelationGrid(
          items: ctrl.model!.characters.items,
          placeholder: 'No Characters',
        );
      } else {
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
      }
    } else {
      grid = RelationGrid(
        items: ctrl.model!.staff.items,
        placeholder: 'No Staff',
      );
    }

    return [
      ShadowSliverAppBar([
        Expanded(
          child: TabSegments(
            items: const {'Characters': false, 'Staff': true},
            initial: ctrl.peopleTabToggled,
            onChanged: (bool val) {
              ctrl.scrollCtrl.scrollUpTo(0);
              ctrl.peopleTabToggled = val;
            },
          ),
        ),
      ]),
      SliverPadding(
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        sliver: grid,
      ),
    ];
  }
}
