import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:otraku/util/theming.dart';
import 'package:otraku/extension/snack_bar_extension.dart';
import 'package:otraku/widget/layout/constrained_view.dart';
import 'package:otraku/feature/review/review_header.dart';
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
      body: Consumer(
        builder: (context, ref, _) {
          final data = ref.watch(reviewProvider(id).select((s) => s.value));

          return CustomScrollView(
            slivers: [
              ReviewHeader(id: id, review: data, bannerUrl: bannerUrl),
              if (data != null) ...[
                SliverConstrainedView(
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      data.summary,
                      style: TextTheme.of(context).labelMedium,
                      textAlign: .center,
                    ),
                  ),
                ),
                SliverConstrainedView(
                  sliver: HtmlContent(data.text, renderMode: RenderMode.sliverList),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      margin: Theming.paddingAll,
                      padding: Theming.paddingAll,
                      decoration: BoxDecoration(
                        color: ColorScheme.of(context).primary,
                        borderRadius: Theming.borderRadiusBig,
                      ),
                      child: Text(
                        '${data.score}/100',
                        style: TextTheme.of(
                          context,
                        ).titleLarge?.copyWith(color: ColorScheme.of(context).onPrimary),
                      ),
                    ),
                  ),
                ),
                _RateButtons(data, ref.read(reviewProvider(id).notifier).rate),
                SliverPadding(
                  padding: .only(
                    top: 20,
                    bottom: MediaQuery.viewPaddingOf(context).bottom + Theming.offset,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      data.createdAt,
                      style: TextTheme.of(context).labelMedium,
                      textAlign: .center,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _RateButtons extends StatefulWidget {
  const _RateButtons(this.review, this.rate);

  final Review review;
  final Future<Object?> Function(bool?) rate;

  @override
  _RateButtonsState createState() => _RateButtonsState();
}

class _RateButtonsState extends State<_RateButtons> {
  @override
  Widget build(BuildContext context) {
    final review = widget.review;

    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: .min,
        children: [
          Row(
            mainAxisAlignment: .center,
            children: [
              IconButton(
                icon: Icon(review.viewerRating == true ? Icons.thumb_up : Icons.thumb_up_outlined),
                color: review.viewerRating == true ? ColorScheme.of(context).primary : null,
                onPressed: () => _rate(review.viewerRating != true ? true : null),
              ),
              IconButton(
                icon: Icon(
                  review.viewerRating == false ? Icons.thumb_down : Icons.thumb_down_outlined,
                ),
                color: review.viewerRating == false ? ColorScheme.of(context).error : null,
                onPressed: () => _rate(review.viewerRating != false ? false : null),
              ),
            ],
          ),
          Text(
            '${review.rating}/${review.totalRating} users liked this review',
            style: TextTheme.of(context).labelMedium,
            textAlign: .center,
          ),
        ],
      ),
    );
  }

  void _rate(bool? rating) async {
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

    final err = await widget.rate(rating);
    if (err == null) return;

    setState(() {
      review.rating = oldRating;
      review.totalRating = oldTotalRating;
      review.viewerRating = oldViewerRating;
    });
    if (mounted) SnackBarExtension.show(context, err.toString());
  }
}
