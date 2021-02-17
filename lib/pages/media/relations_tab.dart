import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/media.dart';
import 'package:otraku/tools/browse_indexer.dart';
import 'package:otraku/tools/fade_image.dart';
import 'package:otraku/tools/layouts/connections_grid.dart';
import 'package:otraku/tools/layouts/sliver_grid_delegates.dart';
import 'package:otraku/tools/loader.dart';
import 'package:otraku/tools/navigation/bubble_tabs.dart';
import 'package:otraku/tools/overlays/option_sheet.dart';

class RelationsTab extends StatelessWidget {
  final Media media;

  RelationsTab(this.media);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
      sliver: Obx(() {
        if (media.relationsTab == Media.REL_MEDIA)
          return media.otherMedia.isNotEmpty
              ? SliverGrid(
                  gridDelegate: SliverGridDelegateWithMinWidthAndFixedHeight(
                    minWidth: 300,
                    height:
                        Config.highTile.maxWidth / Config.highTile.imgWHRatio,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, index) => BrowseIndexer(
                      id: media.otherMedia[index].id,
                      imageUrl: media.otherMedia[index].imageUrl,
                      browsable: media.otherMedia[index].browsable,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Hero(
                            tag: media.otherMedia[index].id,
                            child: ClipRRect(
                              borderRadius: Config.BORDER_RADIUS,
                              child: Container(
                                color: Theme.of(context).primaryColor,
                                child: FadeImage(
                                  media.otherMedia[index].imageUrl,
                                  width: Config.highTile.maxWidth,
                                ),
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
                                      media.otherMedia[index].relationType,
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                    ),
                                    Flexible(
                                      child: Text(
                                        media.otherMedia[index].text1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (media.otherMedia[index].format != null)
                                      Text(
                                        media.otherMedia[index].format,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                    if (media.otherMedia[index].status != null)
                                      Text(
                                        media.otherMedia[index].status,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    childCount: media.otherMedia.length,
                  ),
                )
              : _Empty('No related media');

        if (media.relationsTab == Media.REL_CHARACTERS &&
            media.characters != null) {
          return media.characters.items.isNotEmpty
              ? ConnectionsGrid(
                  connections: media.characters.items,
                  loadMore: () => media.fetchRelationPage(true),
                  preferredSubtitle: media.staffLanguage,
                )
              : _Empty('No Characters');
        }

        if (media.relationsTab == Media.REL_STAFF && media.staff != null) {
          return media.staff.items.isNotEmpty
              ? ConnectionsGrid(
                  connections: media.staff.items,
                  loadMore: () => media.fetchRelationPage(false),
                )
              : _Empty('No Staff');
        }

        return const SliverFillRemaining(child: Center(child: Loader()));
      }),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;

  _Empty(this.text);

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
        child: Center(
      child: Text(
        text,
        style: Theme.of(context).textTheme.subtitle1,
      ),
    ));
  }
}

class RelationControls extends StatelessWidget {
  final Media media;
  final Function scrollUp;

  RelationControls(this.media, this.scrollUp);

  @override
  Widget build(BuildContext context) => SliverPersistentHeader(
        delegate: _RelationControlsDelegate(media, scrollUp),
        pinned: true,
      );
}

class _RelationControlsDelegate implements SliverPersistentHeaderDelegate {
  static const _height = Config.MATERIAL_TAP_TARGET_SIZE + 5;

  final Media media;
  final Function scrollUp;

  _RelationControlsDelegate(this.media, this.scrollUp);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).backgroundColor,
            blurRadius: 7,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BubbleTabs(
            options: ['Media', 'Characters', 'Staff'],
            values: [
              Media.REL_MEDIA,
              Media.REL_CHARACTERS,
              Media.REL_STAFF,
            ],
            initial: media.relationsTab,
            onNewValue: (val) {
              scrollUp();
              media.relationsTab = val;
            },
            onSameValue: (_) => scrollUp(),
          ),
          Obx(() {
            if (media.relationsTab == Media.REL_CHARACTERS &&
                media.characters != null &&
                media.characters.items.isNotEmpty &&
                media.availableLanguages.length > 1)
              return IconButton(
                icon: const Icon(Icons.language),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => OptionSheet(
                    title: 'Language',
                    options: media.availableLanguages,
                    index: media.languageIndex,
                    onTap: (index) =>
                        media.staffLanguage = media.availableLanguages[index],
                  ),
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                ),
              );
            return const SizedBox();
          }),
        ],
      ),
    );
  }

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;

  @override
  PersistentHeaderShowOnScreenConfiguration get showOnScreenConfiguration =>
      null;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;

  @override
  TickerProvider get vsync => null;
}
