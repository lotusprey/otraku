import 'package:flutter/material.dart';
import 'package:otraku/models/recommended_model.dart';
import 'package:otraku/models/related_media_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/navigation/tab_segments.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

class MediaOtherView {
  static List<Widget> children(BuildContext ctx, MediaController ctrl) => [
        ShadowSliverAppBar([
          Expanded(
            child: TabSegments(
              items: const {'Relations': false, 'Recommendations': true},
              initial: ctrl.otherTabToggled,
              onChanged: (bool val) {
                ctrl.scrollCtrl.scrollUpTo(0);
                ctrl.otherTabToggled = val;
              },
            ),
          ),
        ]),
        SliverPadding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          sliver: !ctrl.otherTabToggled
              ? _RelationsGrid(ctrl.model!.otherMedia)
              : _RecommendationsGrid(
                  ctrl.model!.recommendations.items,
                  ctrl.rateRecommendation,
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
        minWidth: 230,
        height: 100,
      ),
      delegate: SliverChildBuilderDelegate(
        (_, i) {
          final details = <TextSpan>[
            TextSpan(
              text: items[i].relationType,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            if (items[i].format != null)
              TextSpan(text: ' • ${items[i].format!}'),
            if (items[i].status != null)
              TextSpan(text: ' • ${items[i].status!}'),
          ];

          return ExploreIndexer(
            id: items[i].id,
            imageUrl: items[i].imageUrl,
            explorable: items[i].type,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: Consts.borderRadiusMin,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Hero(
                    tag: items[i].id,
                    child: ClipRRect(
                      borderRadius: Consts.borderRadiusMin,
                      child: Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: FadeImage(
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
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.subtitle1,
                              children: details,
                            ),
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
        childCount: items.length,
      ),
    );
  }
}

class _RecommendationsGrid extends StatelessWidget {
  _RecommendationsGrid(this.items, this.rate);

  final List<RecommendedModel> items;
  final Future<bool> Function(int, bool?) rate;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty)
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'No Recommendations',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      );

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMinWidthAndExtraHeight(
        minWidth: 100,
        extraHeight: 70,
        rawHWRatio: Consts.coverHtoWRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        (_, i) => DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: Consts.borderRadiusMin,
          ),
          child: ExploreIndexer(
            id: items[i].id,
            explorable: items[i].type,
            imageUrl: items[i].imageUrl,
            child: Column(
              children: [
                Expanded(
                  child: Hero(
                    tag: items[i].id,
                    child: ClipRRect(
                      borderRadius: Consts.borderRadiusMin,
                      child: Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: FadeImage(items[i].imageUrl!),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: SizedBox(
                    height: 35,
                    child: Text(
                      items[i].title,
                      overflow: TextOverflow.fade,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                  child: _Rating(items[i], rate),
                ),
              ],
            ),
          ),
        ),
        childCount: items.length,
      ),
    );
  }
}

class _Rating extends StatefulWidget {
  _Rating(this.model, this.rate);

  final RecommendedModel model;
  final Future<bool> Function(int, bool?) rate;

  @override
  State<_Rating> createState() => __RatingState();
}

class __RatingState extends State<_Rating> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            final oldRating = widget.model.rating;
            final oldUserRating = widget.model.userRating;

            setState(() {
              switch (widget.model.userRating) {
                case true:
                  widget.model.rating--;
                  widget.model.userRating = null;
                  break;
                case false:
                  widget.model.rating += 2;
                  widget.model.userRating = true;
                  break;
                case null:
                  widget.model.rating++;
                  widget.model.userRating = true;
                  break;
              }
            });

            widget.rate(widget.model.id, widget.model.userRating).then((ok) {
              if (!ok)
                setState(() {
                  widget.model.rating = oldRating;
                  widget.model.userRating = oldUserRating;
                });
            });
          },
          child: Icon(
            Icons.thumb_up_outlined,
            size: Consts.iconSmall,
            color: widget.model.userRating == true
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(width: 5),
        Text(widget.model.rating.toString(), overflow: TextOverflow.fade),
        const SizedBox(width: 5),
        GestureDetector(
          onTap: () {
            final oldRating = widget.model.rating;
            final oldUserRating = widget.model.userRating;

            setState(() {
              switch (widget.model.userRating) {
                case true:
                  widget.model.rating -= 2;
                  widget.model.userRating = false;
                  break;
                case false:
                  widget.model.rating++;
                  widget.model.userRating = null;
                  break;
                case null:
                  widget.model.rating--;
                  widget.model.userRating = false;
                  break;
              }
            });

            widget.rate(widget.model.id, widget.model.userRating).then((ok) {
              if (!ok)
                setState(() {
                  widget.model.rating = oldRating;
                  widget.model.userRating = oldUserRating;
                });
            });
          },
          child: Icon(
            Icons.thumb_down_outlined,
            size: Consts.iconSmall,
            color: widget.model.userRating == false
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ],
    );
  }
}
