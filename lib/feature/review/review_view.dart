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
              _RateButtons(data),
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
  const _RateButtons(this.review);

  final Review review;

  @override
  _RateButtonsState createState() => _RateButtonsState();
}

class _RateButtonsState extends State<_RateButtons> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  widget.review.viewerRating == true
                      ? Icons.thumb_up
                      : Icons.thumb_up_outlined,
                ),
                color: widget.review.viewerRating == true
                    ? Theme.of(context).colorScheme.primary
                    : null,
                onPressed: () => _rate(
                  widget.review.viewerRating != true ? true : null,
                ),
              ),
              IconButton(
                icon: Icon(
                  widget.review.viewerRating == false
                      ? Icons.thumb_down
                      : Icons.thumb_down_outlined,
                ),
                color: widget.review.viewerRating == false
                    ? Theme.of(context).colorScheme.error
                    : null,
                onPressed: () => _rate(
                  widget.review.viewerRating != false ? false : null,
                ),
              ),
            ],
          ),
          Text(
            '${widget.review.rating}/${widget.review.totalRating} users liked this review',
            style: Theme.of(context).textTheme.labelMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _rate(bool? rating) {
    final oldRating = widget.review.rating;
    final oldTotalRating = widget.review.totalRating;
    final oldViewerRating = widget.review.viewerRating;

    setState(() {
      if (rating == null) {
        if (oldViewerRating == true) {
          widget.review.rating--;
        }
        widget.review.totalRating--;
      } else if (rating) {
        if (oldViewerRating == null) {
          widget.review.totalRating++;
        }
        widget.review.rating++;
      } else {
        if (oldViewerRating == null) {
          widget.review.totalRating++;
        } else {
          widget.review.rating--;
        }
      }

      widget.review.viewerRating = rating;
    });

    rateReview(widget.review.id, rating).then((err) {
      if (err == null) return;

      setState(() {
        widget.review.rating = oldRating;
        widget.review.totalRating = oldTotalRating;
        widget.review.viewerRating = oldViewerRating;
      });

      if (context.mounted) {
        showPopUp(
          context,
          ConfirmationDialog(
            title: 'Could not rate review',
            content: err.toString(),
          ),
        );
      }
    });
  }
}
