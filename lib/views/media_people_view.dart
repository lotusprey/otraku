import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/models/relation.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/widgets/grids/relation_grid.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/layouts/direct_page_view.dart';
import 'package:otraku/widgets/layouts/segment_switcher.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class MediaPeopleView extends StatelessWidget {
  MediaPeopleView(this.ctrl);

  final MediaController ctrl;

  @override
  Widget build(BuildContext context) {
    late final RelationGrid characterGrid;

    if (ctrl.languages.isEmpty) {
      characterGrid = RelationGrid(
        placeholder: 'No Characters',
        items: ctrl.model!.characters.items,
      );
    } else {
      final characters = <Relation>[];
      final voiceActors = <Relation?>[];

      ctrl.model!.selectCharactersAndVoiceActors(
        ctrl.languages[ctrl.langIndex],
        characters,
        voiceActors,
      );

      characterGrid = RelationGrid(
        placeholder: 'No Characters',
        items: characters,
        connections: voiceActors,
      );
    }

    final scrollCtrl = context
        .findAncestorStateOfType<NestedScrollViewState>()!
        .innerController;

    return PageLayout(
      floatingBar: FloatingBar(
        scrollCtrl: scrollCtrl,
        centered: true,
        children: [
          SegmentSwitcher(
            items: const ['Characters', 'Staff'],
            current: ctrl.peopleTabToggled ? 1 : 0,
            onChanged: (i) {
              scrollCtrl.scrollToTop();
              ctrl.peopleTabToggled = i == 1;
            },
          ),
          _LanguageButton(ctrl.id, scrollCtrl),
        ],
      ),
      child: DirectPageView(
        onChanged: null,
        current: ctrl.peopleTabToggled ? 1 : 0,
        children: [
          CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                sliver: characterGrid,
              ),
              SliverFooter(loading: ctrl.model!.characters.hasNextPage),
            ],
          ),
          CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                sliver: RelationGrid(
                  placeholder: 'No Staff',
                  items: ctrl.model!.staff.items,
                ),
              ),
              SliverFooter(loading: ctrl.model!.staff.hasNextPage),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  _LanguageButton(this.id, this.scrollCtrl);

  final int id;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MediaController>(
      id: MediaController.ID_LANG,
      tag: id.toString(),
      builder: (ctrl) {
        if (ctrl.peopleTabToggled || ctrl.languages.length < 2)
          return const SizedBox(
            width: actionButtonSize,
            height: actionButtonSize,
          );

        return ActionButton(
          tooltip: 'Language',
          icon: Ionicons.globe_outline,
          onTap: () => showSheet(
            context,
            DynamicGradientDragSheet(
              onTap: (i) {
                scrollCtrl.scrollToTop();
                ctrl.langIndex = i;
              },
              children: [
                for (int i = 0; i < ctrl.languages.length; i++)
                  Text(
                    ctrl.languages[i],
                    style: i != ctrl.langIndex
                        ? Theme.of(context).textTheme.headline1
                        : Theme.of(context).textTheme.headline1?.copyWith(
                            color: Theme.of(context).colorScheme.primary),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
