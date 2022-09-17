import 'package:flutter/material.dart';
import 'package:otraku/models/recommended_model.dart';
import 'package:otraku/models/related_media_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/controllers/media_controller.dart';
import 'package:otraku/utils/pagination_controller.dart';
import 'package:otraku/widgets/link_tile.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/layouts/direct_page_view.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';

class MediaOtherView extends StatelessWidget {
  const MediaOtherView(this.ctrl);

  final MediaController ctrl;

  @override
  Widget build(BuildContext context) {
    final scrollCtrl = context
        .findAncestorStateOfType<NestedScrollViewState>()!
        .innerController;

    return PageLayout(
      floatingBar: FloatingBar(
        scrollCtrl: scrollCtrl,
        centered: true,
        children: [
          ActionTabSwitcher(
            items: const ['Related', 'Recommended'],
            current: ctrl.otherTabToggled ? 1 : 0,
            onChanged: (i) {
              scrollCtrl.scrollToTop();
              ctrl.otherTabToggled = i == 1;
            },
          ),
        ],
      ),
      child: DirectPageView(
        onChanged: null,
        current: ctrl.otherTabToggled ? 1 : 0,
        children: [
          CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              _RelatedGrid(ctrl.model!.otherMedia),
              const SliverFooter(),
            ],
          ),
          CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              _RecommendationsGrid(
                ctrl.model!.recommendations.items,
                ctrl.rateRecommendation,
              ),
              SliverFooter(loading: ctrl.model!.recommendations.hasNextPage),
            ],
          ),
        ],
      ),
    );
  }
}

class _RelatedGrid extends StatelessWidget {
  const _RelatedGrid(this.items);

  final List<RelatedMediaModel> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No Relations')),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
          minWidth: 230,
          height: 100,
        ),
        delegate: SliverChildBuilderDelegate(
          childCount: items.length,
          (context, i) {
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
        ),
      ),
    );
  }
}

class _RecommendationsGrid extends StatelessWidget {
  const _RecommendationsGrid(this.items, this.rate);

  final List<RecommendedModel> items;
  final Future<bool> Function(int, bool?) rate;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No Recommendations')),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      sliver: SliverGrid(
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
                          child: FadeImage(items[i].imageUrl!),
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
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: _Rating(items[i], rate),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Rating extends StatefulWidget {
  const _Rating(this.model, this.rate);

  final RecommendedModel model;
  final Future<bool> Function(int, bool?) rate;

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

                widget
                    .rate(widget.model.id, widget.model.userRating)
                    .then((ok) {
                  if (!ok) {
                    setState(() {
                      widget.model.rating = oldRating;
                      widget.model.userRating = oldUserRating;
                    });
                  }
                });
              },
              child: widget.model.userRating == true
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
          Text(widget.model.rating.toString(), overflow: TextOverflow.fade),
          const SizedBox(width: 5),
          Tooltip(
            message: 'Disagree',
            child: InkResponse(
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

                widget
                    .rate(widget.model.id, widget.model.userRating)
                    .then((ok) {
                  if (!ok) {
                    setState(() {
                      widget.model.rating = oldRating;
                      widget.model.userRating = oldUserRating;
                    });
                  }
                });
              },
              child: widget.model.userRating == false
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
