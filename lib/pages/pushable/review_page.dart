import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/review.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/tools/browse_indexer.dart';
import 'package:otraku/tools/fade_image.dart';
import 'package:otraku/tools/html_content.dart';
import 'package:otraku/tools/navigation/custom_sliver_header.dart';

class ReviewPage extends StatelessWidget {
  static const ROUTE = '/review';

  final int id;
  final String bannerUrl;

  ReviewPage(this.id, this.bannerUrl);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: GetBuilder<Review>(
              tag: id.toString(),
              builder: (review) {
                final data = review.data;
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
                    if (data != null)
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
                                id: data.mediaId,
                                imageUrl: data.mediaCover,
                                browsable: data.browsable,
                              ),
                              child: Text(
                                data.mediaTitle,
                                style: Theme.of(context).textTheme.headline2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 5),
                            GestureDetector(
                              onTap: () => BrowseIndexer.openPage(
                                id: data.userId,
                                imageUrl: data.userAvatar,
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
                                          Theme.of(context).textTheme.headline4,
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
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
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
