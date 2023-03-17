import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/review/review_header.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/review/review_providers.dart';
import 'package:otraku/widgets/link_tile.dart';
import 'package:otraku/widgets/html_content.dart';

class ReviewView extends StatelessWidget {
  const ReviewView(this.id, this.bannerUrl);

  final int id;
  final String? bannerUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Consumer(builder: (context, ref, _) {
          final data = ref.watch(reviewProvider(id).select((s) => s.value));

          return CustomScrollView(
            slivers: [
              ReviewHeader(
                id: id,
                bannerUrl: bannerUrl,
                mediaTitle: data?.mediaTitle,
                siteUrl: data?.siteUrl,
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
                        onTap: () => LinkTile.openView(
                          context: context,
                          id: data.mediaId,
                          imageUrl: data.mediaCover,
                          discoverType: DiscoverType.anime,
                        ),
                        child: Text(
                          data.mediaTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () => LinkTile.openView(
                          context: context,
                          id: data.userId,
                          imageUrl: data.userAvatar,
                          discoverType: DiscoverType.user,
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.titleMedium,
                            children: [
                              TextSpan(
                                text: 'review by ',
                                style: Theme.of(context).textTheme.labelMedium,
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
                          style: Theme.of(context).textTheme.labelMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      HtmlContent(data.text),
                      Center(
                        child: Container(
                          margin: Consts.padding,
                          padding: Consts.padding,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: Consts.borderRadiusMax,
                          ),
                          child: Text(
                            '${data.score}/100',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: Consts.fontBig,
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
                          style: Theme.of(context).textTheme.labelMedium,
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

class _RateButtons extends StatefulWidget {
  const _RateButtons(this.id);

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
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
