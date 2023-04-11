import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/media/media_models.dart';
import 'package:otraku/media/media_providers.dart';
import 'package:otraku/widgets/layouts/constrained_view.dart';
import 'package:otraku/widgets/link_tile.dart';
import 'package:otraku/widgets/cached_image.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/scaffolds.dart';
import 'package:otraku/widgets/layouts/direct_page_view.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/paged_view.dart';
import 'package:otraku/widgets/text_rail.dart';

class MediaOtherView extends StatelessWidget {
  const MediaOtherView(this.id, this.related, this.tabToggled, this.toggleTab);

  final int id;
  final List<RelatedMedia> related;
  final bool tabToggled;
  final void Function(bool) toggleTab;

  @override
  Widget build(BuildContext context) {
    final scrollCtrl = context
        .findAncestorStateOfType<NestedScrollViewState>()!
        .innerController;

    return TabScaffold(
      floatingBar: FloatingBar(
        scrollCtrl: scrollCtrl,
        centered: true,
        children: [
          ActionTabSwitcher(
            items: const ['Related', 'Recommended'],
            current: tabToggled ? 1 : 0,
            onChanged: (i) => toggleTab(i == 1),
          ),
        ],
      ),
      child: DirectPageView(
        onChanged: null,
        current: tabToggled ? 1 : 0,
        children: [
          ConstrainedView(
            child: CustomScrollView(
              physics: Consts.physics,
              controller: scrollCtrl,
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                _RelatedGrid(related),
                const SliverFooter(),
              ],
            ),
          ),
          Consumer(
            builder: (context, ref, _) => PagedView<Recommendation>(
              provider: mediaRelationsProvider(id).select((s) => s.recommended),
              onData: (data) => _RecommendationsGrid(id, data.items),
              onRefresh: () => ref.invalidate(mediaRelationsProvider(id)),
              scrollCtrl: scrollCtrl,
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedGrid extends StatelessWidget {
  const _RelatedGrid(this.items);

  final List<RelatedMedia> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No Relations')),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
        minWidth: 230,
        height: 100,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) {
          final details = <String, bool>{
            if (items[i].relationType != null) items[i].relationType!: true,
            if (items[i].format != null) items[i].format!: false,
            if (items[i].status != null) items[i].status!: false,
          };

          return LinkTile(
            id: items[i].id,
            info: items[i].imageUrl,
            discoverType: items[i].type,
            child: Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Hero(
                    tag: items[i].id,
                    child: ClipRRect(
                      borderRadius: Consts.borderRadiusMin,
                      child: Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: CachedImage(
                          items[i].imageUrl,
                          width: 100 / Consts.coverHtoWRatio,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: Consts.padding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              items[i].title,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          const SizedBox(height: 5),
                          TextRail(
                            details,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecommendationsGrid extends StatelessWidget {
  const _RecommendationsGrid(this.mediaId, this.items);

  final int mediaId;
  final List<Recommendation> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No Recommendations')),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndExtraHeight(
        minWidth: 100,
        extraHeight: 70,
        rawHWRatio: Consts.coverHtoWRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: items.length,
        (context, i) => Card(
          child: LinkTile(
            id: items[i].id,
            discoverType: items[i].type,
            info: items[i].imageUrl,
            child: Column(
              children: [
                Expanded(
                  child: Hero(
                    tag: items[i].id,
                    child: ClipRRect(
                      borderRadius: Consts.borderRadiusMin,
                      child: Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: CachedImage(items[i].imageUrl!),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
                  child: SizedBox(
                    height: 35,
                    child: Text(
                      items[i].title,
                      overflow: TextOverflow.fade,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: _Rating(mediaId, items[i]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Rating extends StatefulWidget {
  const _Rating(this.mediaId, this.item);

  final int mediaId;
  final Recommendation item;

  @override
  State<_Rating> createState() => __RatingState();
}

class __RatingState extends State<_Rating> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Tooltip(
            message: 'Agree',
            child: InkResponse(
              onTap: () {
                final oldRating = widget.item.rating;
                final oldUserRating = widget.item.userRating;

                setState(() {
                  switch (widget.item.userRating) {
                    case true:
                      widget.item.rating--;
                      widget.item.userRating = null;
                      break;
                    case false:
                      widget.item.rating += 2;
                      widget.item.userRating = true;
                      break;
                    case null:
                      widget.item.rating++;
                      widget.item.userRating = true;
                      break;
                  }
                });

                rateRecommendation(
                  widget.mediaId,
                  widget.item.id,
                  widget.item.userRating,
                ).then((ok) {
                  if (!ok) {
                    setState(() {
                      widget.item.rating = oldRating;
                      widget.item.userRating = oldUserRating;
                    });
                  }
                });
              },
              child: widget.item.userRating == true
                  ? Icon(
                      Icons.thumb_up,
                      size: Consts.iconSmall,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : Icon(
                      Icons.thumb_up_outlined,
                      size: Consts.iconSmall,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
            ),
          ),
          const SizedBox(width: 5),
          Text(widget.item.rating.toString(), overflow: TextOverflow.fade),
          const SizedBox(width: 5),
          Tooltip(
            message: 'Disagree',
            child: InkResponse(
              onTap: () {
                final oldRating = widget.item.rating;
                final oldUserRating = widget.item.userRating;

                setState(() {
                  switch (widget.item.userRating) {
                    case true:
                      widget.item.rating -= 2;
                      widget.item.userRating = false;
                      break;
                    case false:
                      widget.item.rating++;
                      widget.item.userRating = null;
                      break;
                    case null:
                      widget.item.rating--;
                      widget.item.userRating = false;
                      break;
                  }
                });

                rateRecommendation(
                  widget.mediaId,
                  widget.item.id,
                  widget.item.userRating,
                ).then((ok) {
                  if (!ok) {
                    setState(() {
                      widget.item.rating = oldRating;
                      widget.item.userRating = oldUserRating;
                    });
                  }
                });
              },
              child: widget.item.userRating == false
                  ? Icon(
                      Icons.thumb_down,
                      size: Consts.iconSmall,
                      color: Theme.of(context).colorScheme.error,
                    )
                  : Icon(
                      Icons.thumb_down_outlined,
                      size: Consts.iconSmall,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
