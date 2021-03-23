import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/models/review_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/review.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/widgets/browse_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/navigation/custom_sliver_header.dart';

class ReviewPage extends StatelessWidget {
  static const ROUTE = '/review';

  final int id;
  final String? bannerUrl;

  ReviewPage(this.id, this.bannerUrl);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: GetBuilder<Review>(
              tag: id.toString(),
              builder: (review) {
                final model = review.model;
                return CustomScrollView(
                  physics: Config.PHYSICS,
                  slivers: [
                    CustomSliverHeader(
                      height: 150,
                      background: Hero(
                        tag: id,
                        child: bannerUrl != null
                            ? FadeImage(bannerUrl)
                            : const SizedBox(),
                      ),
                    ),
                    if (model != null)
                      SliverPadding(
                        padding: EdgeInsets.only(
                          top: 15,
                          left: 10,
                          right: 10,
                          bottom:
                              MediaQuery.of(context).viewPadding.bottom + 10,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate.fixed([
                            GestureDetector(
                              onTap: () => BrowseIndexer.openPage(
                                id: model.mediaId,
                                imageUrl: model.mediaCover,
                                browsable: model.browsable,
                              ),
                              child: Text(
                                model.mediaTitle,
                                style: Theme.of(context).textTheme.headline2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 5),
                            GestureDetector(
                              onTap: () => BrowseIndexer.openPage(
                                id: model.userId,
                                imageUrl: model.userAvatar,
                                browsable: Browsable.user,
                              ),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.headline5,
                                  children: [
                                    TextSpan(
                                      text: 'review by ',
                                      style:
                                          Theme.of(context).textTheme.headline6,
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
                                    fontSize: Style.FONT_BIG,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            _RateButtons(model),
                            Text(
                              '${model.rating}/${model.totalRating} users liked this review',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10, top: 20),
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

class _RateButtons extends StatefulWidget {
  final ReviewModel model;
  _RateButtons(this.model);

  @override
  _RateButtonsState createState() => _RateButtonsState();
}

class _RateButtonsState extends State<_RateButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            widget.model.viewerRating == true
                ? Icons.thumb_up
                : Icons.thumb_up_outlined,
          ),
          color: widget.model.viewerRating == true
              ? Theme.of(context).accentColor
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
              ? Theme.of(context).errorColor
              : null,
          onPressed: () =>
              _rate(widget.model.viewerRating != false ? false : null)
                  .then((_) => setState(() {})),
        ),
      ],
    );
  }

  Future<void> _rate(bool? rating) async =>
      await Get.find<Review>(tag: widget.model.id.toString()).rate(rating);
}
