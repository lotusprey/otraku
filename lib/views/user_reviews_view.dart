import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/user_reviews_controller.dart';
import 'package:otraku/widgets/layouts/review_grid.dart';
import 'package:otraku/widgets/loaders.dart/loader.dart';
import 'package:otraku/widgets/navigation/custom_app_bar.dart';

class UserReviewsView extends StatelessWidget {
  static const ROUTE = '/reviews';

  final int id;
  UserReviewsView(this.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Reviews'),
      body: SafeArea(
        child: GetBuilder<UserReviewsController>(
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
