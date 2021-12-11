import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/reviews_controller.dart';
import 'package:otraku/widgets/layouts/review_grid.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/navigation/app_bars.dart';

class ReviewsView extends StatelessWidget {
  ReviewsView(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShadowAppBar(title: 'Reviews'),
      body: SafeArea(
        child: GetBuilder<ReviewsController>(
          init: ReviewsController(id),
          tag: id.toString(),
          builder: (feed) {
            if (feed.reviews.isEmpty) {
              if (feed.hasNextPage) return const Center(child: Loader());

              return Center(
                child: Text(
                  'No Reviews',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              );
            }

            return ReviewGrid(feed.reviews, scrollCtrl: feed.scrollCtrl);
          },
        ),
      ),
    );
  }
}
