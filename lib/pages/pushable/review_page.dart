import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                                id: model.mediaId!,
                                imageUrl: model.mediaCover,
                                browsable: model.browsable,
                              ),
                              child: Text(
                                model.mediaTitle!,
                                style: Theme.of(context).textTheme.headline2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 5),
                            GestureDetector(
                              onTap: () => BrowseIndexer.openPage(
                                id: model.userId!,
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
                                model.summary!,
                                style: Theme.of(context).textTheme.subtitle1,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            HtmlContent(model.text),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
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
