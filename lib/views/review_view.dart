import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/models/review_model.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/controllers/review_controller.dart';
import 'package:otraku/enums/explorable.dart';
import 'package:otraku/widgets/explore_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/navigation/custom_sliver_header.dart';

class ReviewView extends StatelessWidget {
  final int id;
  final String? bannerUrl;

  ReviewView(this.id, this.bannerUrl);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: GetBuilder<ReviewController>(
              tag: id.toString(),
              builder: (review) {
                final model = review.model;
                return CustomScrollView(
                  physics: Config.PHYSICS,
                  slivers: [
                    _Header(id, bannerUrl),
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
                              onTap: () => ExploreIndexer.openPage(
                                id: model.mediaId,
                                imageUrl: model.mediaCover,
                                explorable: model.explorable,
                              ),
                              child: Text(
                                model.mediaTitle,
                                style: Theme.of(context).textTheme.headline5,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 5),
                            GestureDetector(
                              onTap: () => ExploreIndexer.openPage(
                                id: model.userId,
                                imageUrl: model.userAvatar,
                                explorable: Explorable.user,
                              ),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.headline5,
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
                                    fontSize: Style.FONT_BIG,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            _RateButtons(model),
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

class _Header extends StatelessWidget {
  final int id;
  final String? bannerUrl;
  _Header(this.id, this.bannerUrl);

  @override
  Widget build(BuildContext context) {
    return CustomSliverHeader(
      height: 150,
      background: Hero(
        tag: id,
        child: bannerUrl != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  FadeImage(bannerUrl),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 15,
                            spreadRadius: 25,
                            color: Theme.of(context).backgroundColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox(),
      ),
    );
  }
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
