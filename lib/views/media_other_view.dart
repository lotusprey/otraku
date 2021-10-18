import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:otraku/models/connection_model.dart';
import 'package:otraku/models/related_media_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/layouts/connections_grid.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/navigation/bubble_tabs.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

class MediaOtherView {
  static List<Widget> children(
    BuildContext ctx,
    MediaController ctrl,
    double headerOffset,
  ) =>
      [
        SliverShadowAppBar([
          BubbleTabs(
            items: const {
              'Relations': MediaController.RELATIONS,
              'Characters': MediaController.CHARACTERS,
              'Staff': MediaController.STAFF,
            },
            current: () => ctrl.otherTab,
            onChanged: (int val) {
              ctrl.scrollUpTo(headerOffset);
              ctrl.otherTab = val;
            },
            onSame: () => ctrl.scrollUpTo(headerOffset),
          ),
        ]),
        SliverPadding(
          padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
          sliver: ctrl.otherTab == MediaController.RELATIONS
              ? _RelationsGrid(ctrl.model!.otherMedia)
              : ctrl.otherTab == MediaController.CHARACTERS
                  ? _PeopleGrid(
                      items: ctrl.model!.characters.items,
                      placeholder: 'No Characters',
                      preferredSubtitle:
                          ctrl.language < ctrl.availableLanguages.length
                              ? ctrl.availableLanguages[ctrl.language]
                              : null,
                    )
                  : _PeopleGrid(
                      items: ctrl.model!.staff.items,
                      placeholder: 'No Staff',
                    ),
        ),
      ];
}

class _RelationsGrid extends StatelessWidget {
  _RelationsGrid(this.items);

  final List<RelatedMediaModel> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty)
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'No Relations',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      );

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 300,
        height: 190,
      ),
      delegate: SliverChildBuilderDelegate(
        (_, i) => ExploreIndexer(
          id: items[i].id,
          imageUrl: items[i].imageUrl,
          explorable: items[i].explorable,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Hero(
                tag: items[i].id,
                child: ClipRRect(
                  borderRadius: Config.BORDER_RADIUS,
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: FadeImage(items[i].imageUrl!, width: 125),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[i].relationType!,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        Flexible(
                          child: Text(
                            items[i].text1,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (items[i].format != null)
                          Text(
                            items[i].format!,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        if (items[i].status != null)
                          Text(
                            items[i].status!,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        childCount: items.length,
      ),
    );
  }
}

class _PeopleGrid extends StatelessWidget {
  _PeopleGrid({
    required this.items,
    required this.placeholder,
    this.preferredSubtitle,
  });

  final List<ConnectionModel> items;
  final String placeholder;
  final String? preferredSubtitle;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty)
      return SliverFillRemaining(
        child: Center(
          child: Text(
            placeholder,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      );

    return ConnectionsGrid(
      connections: items,
      preferredSubtitle: preferredSubtitle,
    );
  }
}
