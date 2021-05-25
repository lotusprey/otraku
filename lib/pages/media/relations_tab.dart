import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/models/related_media_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/media.dart';
import 'package:otraku/widgets/action_icon.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/layouts/connections_grid.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/navigation/bubble_tabs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';

class RelationsTab extends StatelessWidget {
  final Media media;

  RelationsTab(this.media);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
      sliver: Obx(() {
        if (media.relationsTab == Media.REL_MEDIA) {
          final other = media.model!.otherMedia;

          if (other.isEmpty)
            return media.isLoading ? _Empty(null) : _Empty('No related media');

          return _RelationsGrid(media.model!.otherMedia);
        }

        if (media.relationsTab == Media.REL_CHARACTERS) {
          if (media.model!.characters.items.isEmpty)
            return media.isLoading ? _Empty(null) : _Empty('No Characters');

          return ConnectionsGrid(
            connections: media.model!.characters.items,
            preferredSubtitle: media.staffLanguage,
          );
        }

        if (media.model!.staff.items.isEmpty)
          return media.isLoading ? _Empty(null) : _Empty('No Staff');

        return ConnectionsGrid(connections: media.model!.staff.items);
      }),
    );
  }
}

class _RelationsGrid extends StatelessWidget {
  final List<RelatedMediaModel> models;
  _RelationsGrid(this.models);

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 300,
        height: 190,
      ),
      delegate: SliverChildBuilderDelegate(
        (_, index) => ExploreIndexer(
          id: models[index].id,
          imageUrl: models[index].imageUrl,
          browsable: models[index].browsable,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Hero(
                tag: models[index].id,
                child: ClipRRect(
                  borderRadius: Config.BORDER_RADIUS,
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: FadeImage(models[index].imageUrl, width: 125),
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
                          models[index].relationType!,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        Flexible(
                          child: Text(
                            models[index].text1,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (models[index].format != null)
                          Text(
                            models[index].format!,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        if (models[index].status != null)
                          Text(
                            models[index].status!,
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
        childCount: models.length,
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String? text;

  _Empty(this.text);

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
        child: Center(
      child: text == null
          ? Loader()
          : Text(
              text!,
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
  static const _height = 50.0;

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
      padding: const EdgeInsets.symmetric(horizontal: 10),
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
            onNewValue: (dynamic val) {
              scrollUp();
              media.relationsTab = val;
            },
            onSameValue: (dynamic _) => scrollUp(),
          ),
          Obx(() {
            if (media.relationsTab == Media.REL_CHARACTERS &&
                media.model!.characters.items.isNotEmpty &&
                media.availableLanguages.length > 1)
              return ActionIcon(
                tooltip: 'Language',
                icon: Ionicons.globe_outline,
                onTap: () => Sheet.show(
                  ctx: context,
                  sheet: OptionSheet(
                    title: 'Language',
                    options: media.availableLanguages,
                    index: media.languageIndex,
                    onTap: (index) =>
                        media.staffLanguage = media.availableLanguages[index],
                  ),
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
  PersistentHeaderShowOnScreenConfiguration? get showOnScreenConfiguration =>
      null;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration => null;

  @override
  TickerProvider? get vsync => null;
}
