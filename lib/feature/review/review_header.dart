import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:otraku/feature/review/review_models.dart';
import 'package:otraku/util/routes.dart';
import 'package:otraku/widget/layout/content_header.dart';

class ReviewHeader extends StatelessWidget {
  const ReviewHeader({required this.id, required this.review, required this.bannerUrl});

  final int id;
  final Review? review;
  final String? bannerUrl;

  @override
  Widget build(BuildContext context) {
    return CustomContentHeader(
      title: review?.mediaTitle,
      siteUrl: review?.siteUrl,
      bannerUrl: review?.banner ?? bannerUrl,
      content: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Column(
          crossAxisAlignment: .stretch,
          children: review != null
              ? [
                  Flexible(
                    child: GestureDetector(
                      onTap: () => context.push(Routes.media(review!.mediaId, review!.mediaCover)),
                      child: Text(
                        review!.mediaTitle,
                        overflow: .fade,
                        textAlign: .center,
                        style: TextTheme.of(context).bodyMedium,
                      ),
                    ),
                  ),
                  Flexible(
                    child: GestureDetector(
                      behavior: .opaque,
                      onTap: () => context.push(Routes.user(review!.userId, review!.userAvatar)),
                      child: Text.rich(
                        textAlign: .center,
                        TextSpan(
                          style: TextTheme.of(context).bodyMedium,
                          children: [
                            TextSpan(text: 'review by ', style: TextTheme.of(context).labelMedium),
                            TextSpan(text: review!.userName),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]
              : const [],
        ),
      ),
    );
  }
}
