import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/controllers/review.dart';
import 'package:otraku/models/transparent_image.dart';

class ReviewPage extends StatelessWidget {
  final int id;
  final String imageUrlTag;

  ReviewPage(this.id, this.imageUrlTag);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: GetBuilder<Review>(
              tag: id.toString(),
              builder: (review) {
                final data = review.data;
                return CustomScrollView(
                  physics: Config.PHYSICS,
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      stretch: true,
                      leadingWidth: 40,
                      expandedHeight: 150,
                      automaticallyImplyLeading: false,
                      backgroundColor: Theme.of(context).backgroundColor,
                      leading: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).backgroundColor,
                              blurRadius: 10,
                              spreadRadius: -10,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          color: Theme.of(context).dividerColor,
                          onPressed: () => Navigator.of(context).pop(),
                          padding: const EdgeInsets.all(0),
                        ),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.pin,
                        stretchModes: [StretchMode.zoomBackground],
                        background: Hero(
                          tag: imageUrlTag,
                          child: FadeInImage.memoryNetwork(
                            image: imageUrlTag,
                            placeholder: transparentImage,
                            fadeInDuration: Config.FADE_DURATION,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    if (data != null)
                      SliverPadding(
                        padding: Config.PADDING,
                        sliver: SliverList(
                          delegate: SliverChildListDelegate.fixed([
                            Text(
                              data.text,
                              style: Theme.of(context).textTheme.bodyText1,
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
