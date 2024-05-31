import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/util/routing.dart';
import 'package:otraku/widget/layouts/constrained_view.dart';
import 'package:otraku/widget/overlays/dialogs.dart';
import 'package:otraku/feature/review/review_header.dart';
import 'package:otraku/util/consts.dart';
import 'package:otraku/feature/review/review_models.dart';
import 'package:otraku/feature/review/review_provider.dart';
import 'package:otraku/widget/html_content.dart';

class ReviewView extends StatelessWidget {
  const ReviewView(this.id, this.bannerUrl);

  final int id;
  final String? bannerUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(builder: (context, ref, _) {
        final data = ref.watch(reviewProvider(id).select((s) => s.valueOrNull));

        return CustomScrollView(
          slivers: [
            ReviewHeader(
              id: id,
              bannerUrl: bannerUrl,
              mediaTitle: data?.mediaTitle,
              siteUrl: data?.siteUrl,
            ),
            if (data != null) ...[
              SliverPadding(
                padding: const EdgeInsets.only(top: 15, bottom: 5),
                sliver: SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: () => context.push(
                      Routes.media(data.mediaId, data.mediaCover),
                    ),
                    child: Text(
                      data.mediaTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () => context.push(
                    Routes.user(data.userId, data.userAvatar),
                  ),
                  child: Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
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
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    data.summary,
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SliverConstrainedView(
                sliver: HtmlContent(
                  data.text,
                  renderMode: RenderMode.sliverList,
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    margin: Consts.padding,
                    padding: Consts.padding,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: Consts.borderRadiusMax,
                    ),
                    child: Text(
                      '${data.score}/100',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: Consts.fontBig,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ),
              ),
              _RateButtons(data, ref.read(reviewProvider(id).notifier).rate),
              SliverPadding(
                padding: EdgeInsets.only(
                  top: 20,
                  bottom: MediaQuery.viewPaddingOf(context).bottom + 10,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    data.createdAt,
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}

class _RateButtons extends StatefulWidget {
  const _RateButtons(this.review, this.rate);

  final Review review;
  final Future<bool> Function(bool?) rate;

  @override
  _RateButtonsState createState() => _RateButtonsState();
}

class _RateButtonsState extends State<_RateButtons> {
  @override
  Widget build(BuildContext context) {
    final review = widget.review;

    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  review.viewerRating == true
                      ? Icons.thumb_up
                      : Icons.thumb_up_outlined,
                ),
                color: review.viewerRating == true
                    ? Theme.of(context).colorScheme.primary
                    : null,
                onPressed: () => _rate(
                  review.viewerRating != true ? true : null,
                ),
              ),
              IconButton(
                icon: Icon(
                  review.viewerRating == false
                      ? Icons.thumb_down
                      : Icons.thumb_down_outlined,
                ),
                color: review.viewerRating == false
                    ? Theme.of(context).colorScheme.error
                    : null,
                onPressed: () => _rate(
                  review.viewerRating != false ? false : null,
                ),
              ),
            ],
          ),
          Text(
            '${review.rating}/${review.totalRating} users liked this review',
            style: Theme.of(context).textTheme.labelMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _rate(bool? rating) {
    final review = widget.review;
    final oldRating = review.rating;
    final oldTotalRating = review.totalRating;
    final oldViewerRating = review.viewerRating;

    setState(() {
      if (rating == null) {
        if (oldViewerRating == true) {
          review.rating--;
        }
        review.totalRating--;
      } else if (rating) {
        if (oldViewerRating == null) {
          review.totalRating++;
        }
        review.rating++;
      } else {
        if (oldViewerRating == null) {
          review.totalRating++;
        } else {
          review.rating--;
        }
      }

      review.viewerRating = rating;
    });

    widget.rate(rating).then((ok) {
      if (ok) return;

      setState(() {
        review.rating = oldRating;
        review.totalRating = oldTotalRating;
        review.viewerRating = oldViewerRating;
      });

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => const ConfirmationDialog(
            title: 'Could not rate review',
          ),
        );
      }
    });
  }
}
