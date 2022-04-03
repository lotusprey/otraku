import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/models/review_model.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/controllers/review_controller.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/custom_sliver_header.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class ReviewView extends StatelessWidget {
  final int id;
  final String? bannerUrl;

  ReviewView(this.id, this.bannerUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: GetBuilder<ReviewController>(
            init: ReviewController(id),
            tag: id.toString(),
            builder: (ctrl) {
              final model = ctrl.model;
              return CustomScrollView(
                physics: Consts.PHYSICS,
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _HeaderDelegate(id, bannerUrl, model?.mediaTitle),
                  ),
                  // _Header(id, bannerUrl),
                  if (model != null)
                    SliverPadding(
                      padding: EdgeInsets.only(
                        top: 15,
                        left: 10,
                        right: 10,
                        bottom: MediaQuery.of(context).viewPadding.bottom + 10,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate.fixed([
                          GestureDetector(
                            onTap: () => ExploreIndexer.openView(
                              ctx: context,
                              id: model.mediaId,
                              imageUrl: model.mediaCover,
                              explorable: model.explorable,
                            ),
                            child: Text(
                              model.mediaTitle,
                              style: Theme.of(context).textTheme.headline2,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: () => ExploreIndexer.openView(
                              ctx: context,
                              id: model.userId,
                              imageUrl: model.userAvatar,
                              explorable: Explorable.user,
                            ),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: Theme.of(context).textTheme.headline2,
                                children: [
                                  TextSpan(
                                    text: 'review by ',
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  ),
                                  TextSpan(text: model.userName),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              model.summary,
                              style: Theme.of(context).textTheme.subtitle1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          HtmlContent(model.text),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: null,
                              child: Text('${model.score}/100'),
                              style: ElevatedButton.styleFrom(
                                textStyle: TextStyle(
                                  fontSize: Consts.FONT_BIG,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          _RateButtons(model),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10, top: 20),
                            child: Text(
                              model.createdAt,
                              style: Theme.of(context).textTheme.subtitle1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ]),
                      ),
                    ),
                ],
              );
            }),
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  _HeaderDelegate(this.id, this.bannerUrl, this.title);

  final int id;
  final String? bannerUrl;
  final String? title;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final extent = maxExtent - shrinkOffset;
    final opacity = shrinkOffset < (maxExtent - minExtent)
        ? shrinkOffset / (maxExtent - minExtent)
        : 1.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 10,
            color: Theme.of(context).colorScheme.background,
          ),
        ],
      ),
      child: FlexibleSpaceBar.createSettings(
        minExtent: minExtent,
        maxExtent: maxExtent,
        currentExtent: extent > minExtent ? extent : minExtent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              stretchModes: [StretchMode.zoomBackground],
              background: Column(
                children: [
                  bannerUrl != null
                      ? Expanded(
                          child: GestureDetector(
                            child: Hero(child: FadeImage(bannerUrl!), tag: id),
                            onTap: () =>
                                showPopUp(context, ImageDialog(bannerUrl!)),
                          ),
                        )
                      : DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                          ),
                        ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 15,
                      spreadRadius: 25,
                      offset: const Offset(0, -15),
                      color: Theme.of(context).colorScheme.background,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: const SizedBox(),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: minExtent,
              child: Opacity(
                opacity: opacity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        spreadRadius: 10,
                        color: Theme.of(context).colorScheme.background,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: minExtent,
              child: Row(
                children: [
                  IconShade(
                    AppBarIcon(
                      tooltip: 'Close',
                      icon: Ionicons.chevron_back_outline,
                      onTap: Navigator.of(context).pop,
                    ),
                  ),
                  if (title != null)
                    Expanded(
                      child: Opacity(
                        opacity: opacity,
                        child: Text(
                          title!,
                          style: Theme.of(context).textTheme.headline2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 150;

  @override
  double get minExtent => Consts.TAP_TARGET_SIZE;

  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration =>
      OverScrollHeaderStretchConfiguration(stretchTriggerOffset: 100);

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;

  @override
  PersistentHeaderShowOnScreenConfiguration? get showOnScreenConfiguration =>
      null;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration => null;

  @override
  TickerProvider? get vsync => null;
}

class _RateButtons extends StatefulWidget {
  final ReviewModel model;
  _RateButtons(this.model);

  @override
  _RateButtonsState createState() => _RateButtonsState();
}

class _RateButtonsState extends State<_RateButtons> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                widget.model.viewerRating == true
                    ? Icons.thumb_up
                    : Icons.thumb_up_outlined,
              ),
              color: widget.model.viewerRating == true
                  ? Theme.of(context).colorScheme.primary
                  : null,
              onPressed: () =>
                  _rate(widget.model.viewerRating != true ? true : null)
                      .then((_) => setState(() {})),
            ),
            IconButton(
              icon: Icon(
                widget.model.viewerRating == false
                    ? Icons.thumb_down
                    : Icons.thumb_down_outlined,
              ),
              color: widget.model.viewerRating == false
                  ? Theme.of(context).colorScheme.error
                  : null,
              onPressed: () =>
                  _rate(widget.model.viewerRating != false ? false : null)
                      .then((_) => setState(() {})),
            ),
          ],
        ),
        Text(
          '${widget.model.rating}/${widget.model.totalRating} users liked this review',
          style: Theme.of(context).textTheme.subtitle1,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _rate(bool? rating) async =>
      await Get.find<ReviewController>(tag: widget.model.id.toString())
          .rate(rating);
}
