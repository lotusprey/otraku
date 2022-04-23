import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/constants/consts.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/providers/review.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';
import 'package:otraku/widgets/navigation/custom_sliver_header.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';

class ReviewView extends StatelessWidget {
  ReviewView(this.id, this.bannerUrl);

  final int id;
  final String? bannerUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Consumer(builder: (context, ref, _) {
          final data =
              ref.watch(reviewProvider(id).select((s) => s.asData))?.value;

          return CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _HeaderDelegate(id, bannerUrl, data?.mediaTitle),
              ),
              if (data != null)
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
                          id: data.mediaId,
                          imageUrl: data.mediaCover,
                          explorable: Explorable.anime,
                        ),
                        child: Text(
                          data.mediaTitle,
                          style: Theme.of(context).textTheme.headline2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () => ExploreIndexer.openView(
                          ctx: context,
                          id: data.userId,
                          imageUrl: data.userAvatar,
                          explorable: Explorable.user,
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.headline2,
                            children: [
                              TextSpan(
                                text: 'review by ',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              TextSpan(text: data.userName),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          data.summary,
                          style: Theme.of(context).textTheme.subtitle1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      HtmlContent(data.text),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: null,
                          child: Text('${data.score}/100'),
                          style: ElevatedButton.styleFrom(
                            textStyle: TextStyle(
                              fontSize: Consts.FONT_BIG,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      _RateButtons(id),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, top: 20),
                        child: Text(
                          data.createdAt,
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
              background: bannerUrl != null
                  ? GestureDetector(
                      child: Hero(tag: id, child: FadeImage(bannerUrl!)),
                      onTap: () => showPopUp(context, ImageDialog(bannerUrl!)),
                    )
                  : null,
            ),
            // TODO fix weird gap
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0, 0.2, 0.3],
                  colors: [
                    Theme.of(context).colorScheme.background,
                    Theme.of(context).colorScheme.background.withAlpha(150),
                    Theme.of(context).colorScheme.background.withAlpha(0),
                  ],
                ),
              ),
            ),
            Opacity(
              opacity: opacity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
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
  _RateButtons(this.id);

  final int id;

  @override
  _RateButtonsState createState() => _RateButtonsState();
}

class _RateButtonsState extends State<_RateButtons> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final value = ref.watch(
          reviewProvider(widget.id).select((s) => s.asData!.value),
        );

        final rate = ref.watch(reviewProvider(widget.id).notifier).rate;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    value.viewerRating == true
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                  ),
                  color: value.viewerRating == true
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  onPressed: () =>
                      rate(value.viewerRating != true ? true : null),
                ),
                IconButton(
                  icon: Icon(
                    value.viewerRating == false
                        ? Icons.thumb_down
                        : Icons.thumb_down_outlined,
                  ),
                  color: value.viewerRating == false
                      ? Theme.of(context).colorScheme.error
                      : null,
                  onPressed: () =>
                      rate(value.viewerRating != false ? false : null),
                ),
              ],
            ),
            Text(
              '${value.rating}/${value.totalRating} users liked this review',
              style: Theme.of(context).textTheme.subtitle1,
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
